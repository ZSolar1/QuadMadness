package states;

import states.songselect.SongSelectState;
import skin.SkinLoader;
import flixel.util.FlxStringUtil;
import maps.OsuParser;
import flixel.util.FlxTimer;
import QMAssets.QMAssets;
import SongSaveData.Scores;
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import maps.Convert;
import maps.FunkinParser.Song;
import maps.MapChart;
import openfl.events.KeyboardEvent;
import states.MenuState;
import gameplay.Conductor;
import gameplay.Note;
import gameplay.NoteParticle;
import gameplay.StrumNote;

enum SongType
{
	OsuMania;
	FridayNightFunkin;
	QuadMadness;
	ProjectDiva; // unsure
}

class SongState extends BPMState
{
	public static var STRUM_X = 640 - 256;
	public static var STRUM_Y = 16;
	public static var STRUM_SIZE = 16;
	public static var songName:String = '';
	public static var songDiff:String = '';
	public static var songType:SongType = SongType.OsuMania;

	var formattedName:String = '';
	var formattedDiff:String = '';

	var background:FlxSprite;

	var chart:MapChart;

	// All song types:
	// native:  Idk
	// mania:   Almost
	// etterna: CANCELED (maybe)
	// fnf:     Almost
	var strums:FlxTypedGroup<StrumNote>;
	var particles:FlxTypedGroup<NoteParticle>;
	var allNotes:Array<Note>;
	var notes:FlxTypedGroup<Note>;

	var songEnded:Bool = false;

	var dead:Bool = false;

	var stats:FlxText;
	var positionBar:FlxBar;
	var healthBar:FlxBar;
	var healthText:FlxText;
	var autoplayText:FlxText;
	var autoplay:Bool = false;

	var rank:FlxSprite;
	var rankNum:Int = 0;

	var downscroll:Bool;

	var clampSongPos:Float = 1.0;
	var scrollSpeed:Float = 0.0;
	var paused:Bool = false;
	var voices:FlxSound;

	var music:openfl.media.Sound;

	var startedSong:Bool = false;

	var totalNotes:Int = 0;

	var totalHit:Int = 0;
	var hitRating:Float = 0;
	var accuracy:Float = 0;
	var misses:Int = 0;
	var score:Int = 0;
	var combo:Int = 0;
	var maxCombo:Int = 0;
	var health:Float = 1;

	var controlPressed:Array<Bool> = [false, false, false, false];
	var controlHold:Array<Bool> = [false, false, false, false];
	var controlRelease:Array<Bool> = [false, false, false, false];

	// All of the debug stuff sits here
	var debugText:FlxText;

	public static var instance:SongState;

	override function onResize(Width:Int, Height:Int)
	{
		FlxG.camera.zoom = 1.0;
		super.onResize(Width, Height);
		STRUM_X = Math.floor(Width / 2 - 256);
		background.setGraphicSize(Width, Height);
		background.updateHitbox();

		positionBar.setPosition(STRUM_X, FlxG.height - 8);
		healthBar.setPosition(STRUM_X + 512, FlxG.height - 512);
		healthText.x = STRUM_X + 512 + 12;
		for (i in 0...4)
		{
			strums.members[i].x = STRUM_X + (i * 128);
		}
		for (note in notes)
		{
			note.x = STRUM_X + (note.direction * 128);
		}
	}

	override public function create()
	{
		super.create();
		STRUM_X = Math.floor(FlxG.width / 2 - 256);

		instance = this;
		if (songType == SongType.FridayNightFunkin)
		{
			formattedName = FlxStringUtil.toTitleCase(StringTools.replace(songName, '-', ' '));
			formattedDiff = FlxStringUtil.toTitleCase(StringTools.replace(songDiff, '-', ' '));
		}
		else
		{
			formattedName = FlxStringUtil.toTitleCase(songName);
			formattedDiff = FlxStringUtil.toTitleCase(songDiff);
		}

		QMDiscordRpc.changeStatus('Starting $formattedName ($formattedDiff)', null);
		scrollSpeed = Preferences.scrollSpeed;

		background = new FlxSprite(0, 0).loadGraphic(SkinLoader.getSkinnedImage('menu/background.png'));
		background.color = 0xFF333333;
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.updateHitbox();
		add(background);

		rank = new FlxSprite(15, 25).loadGraphic(SkinLoader.getSkinnedImage('menu/ranks.png'), true, 128, 128);
		stats = new FlxText(15, FlxG.height, STRUM_X - 15);
		stats.setFormat(Fonts.NotoSans.Light, 28);
		stats.antialiasing = true;
		updateScore();

		if (Globals.debugMode)
			debugText = new FlxText(15, 35, STRUM_X - 15, 'Debug text', 16);

		positionBar = new FlxBar(STRUM_X, FlxG.height - 8, LEFT_TO_RIGHT, 512, 8, this, 'clampSongPos', 0, 1);
		positionBar.numDivisions = 2048;
		positionBar.createFilledBar(FlxColor.fromInt(0xFF333333), FlxColor.WHITE);

		healthBar = new FlxBar(STRUM_X + 512, FlxG.height - 512, BOTTOM_TO_TOP, 8, 512, this, 'health', 0, 1);
		healthBar.numDivisions = 512;
		healthBar.createFilledBar(FlxColor.fromInt(0xFF333333), FlxColor.WHITE);

		positionBar.antialiasing = true;
		healthBar.antialiasing = true;

		healthText = new FlxText(STRUM_X + 512 + 12, FlxG.height, STRUM_X - 15);
		healthText.setFormat(Fonts.NotoSans.Light, 28);
		healthText.antialiasing = true;

		autoplayText = new FlxText(20, rank.height + 10, FlxG.width, 'Autoplay', 28);
		autoplayText.alignment = LEFT;
		autoplayText.antialiasing = true;
		autoplayText.font = Fonts.NotoSans.Light;
		updateHealthText();

		if (Globals.debugMode)
			add(debugText);
		add(stats);
		add(positionBar);
		add(healthBar);
		add(healthText);
		add(rank);
		if (autoplay)
			add(autoplayText);

		downscroll = Preferences.downscroll;
		if (downscroll)
			STRUM_Y = FlxG.height - 16 - 128;
		else
			STRUM_Y = 16;
		trace('Ready to load song');
		if (songType == SongType.FridayNightFunkin)
		{
			if (songDiff == 'normal' && !QMAssets.exists('mods/fnf/$songName/$songName-normal.json'))
				chart = Convert.Funkin(Song.loadFromJson('$songName.json', songName));
			else
				chart = Convert.Funkin(Song.loadFromJson('$songName-$songDiff.json', songName));
		}
		else if (songType == SongType.OsuMania)
		{
			chart = Convert.OsuMania(OsuParser.parseMap(songName, songDiff));
			trace('Loaded an osu!mania map');
		}
		allNotes = new Array<Note>();
		allNotes = chart.notes;

		bpm = chart.bpm[0];
		updateCrochet();

		trace("All Notes: " + allNotes.length);

		strums = new FlxTypedGroup<StrumNote>();
		particles = new FlxTypedGroup<NoteParticle>();
		for (i in 0...4)
		{
			var strum:StrumNote = new StrumNote(STRUM_X, 0);
			strum.x += i * 128;
			strum.y += STRUM_Y;
			strum.alpha = 0;
			strums.add(strum);
		}
		add(strums);
		if (songType == SongType.FridayNightFunkin)
		{
			music = Sound.fromFile('mods/fnf/$songName/Inst.ogg');
			voices = new FlxSound().loadEmbedded(Sound.fromFile('mods/fnf/$songName/Voices.ogg'), false);
		}
		else if (songType == SongType.OsuMania)
		{
			trace('mods/mania/$songName/${chart.additionalData[0]}');
			music = Sound.fromFile('mods/mania/$songName/${chart.additionalData[0]}');
		}

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			startCountdown();
			trace('Started Countdown');
		});
	}

	override function beatHit()
	{
		super.beatHit();
		if (curBeat % 4 == 0 && startedSong)
		{
			if (songType == SongType.FridayNightFunkin)
				resyncVocals();
			FlxG.camera.zoom += 0.02;
		}
	}

	override function stepHit()
	{
		super.stepHit();
	}

	private function updateHealthText()
	{
		if (!dead)
		{
			healthText.y = FlxG.height - Math.round(health * 512) - (healthText.height / 2);
			healthText.text = Std.string(Math.round(health * 100)) + '%';
		}
	}

	private function generateNotes()
	{
		notes = new FlxTypedGroup<Note>();
		for (note in allNotes)
		{
			var sustainLength = note.sustainLength / stepCrochet;
			note.x = STRUM_X + (note.direction * note.width);
			notes.add(note);
			if (note.sustainLength > 0)
			{
				// Sustain Itself
				var sustainNote = new Note(note.strumTime, note.direction, 0, true);
				var sustainHeight = note.sustainLength;
				sustainNote.scale.y = sustainHeight / sustainNote.height / 2;
				sustainNote.updateHitbox();
				sustainNote.offset.y = -(sustainNote.height / 2) + 64;
				sustainNote.x = STRUM_X + (sustainNote.direction * sustainNote.width);
				sustainNote.sustainParent = note;
				// Sustain Note Tail
				var sustainEnd = new Note(note.strumTime + note.sustainLength, note.direction, 0, true);
				sustainEnd.animation.frameIndex = 4;
				sustainEnd.isSustainEnd = true;
				sustainEnd.updateHitbox();
				sustainEnd.offset.y = 128;
				sustainEnd.x = STRUM_X + (sustainEnd.direction * sustainEnd.width);
				sustainEnd.sustainParent = note;
				notes.add(sustainNote);
				notes.add(sustainEnd);
			}
		}
		trace("Active notes: " + notes.length);
		add(notes);
	}

	private function startCountdown()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut((crochet / 1000) * 3, 0);
		new FlxTimer().start(crochet / 1000, function(tmr:FlxTimer)
		{
			if (tmr.loopsLeft > 0)
			{
				var counter:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.ImagePath('gameplay/countdown.png'), true, 85, 128, false);
				counter.screenCenter(XY);
				add(counter);
				switch (tmr.loopsLeft)
				{
					case 3:
						counter.animation.frameIndex = 0;
					case 2:
						counter.animation.frameIndex = 1;
					case 1:
						counter.animation.frameIndex = 2;
				}
				var leanDirection = FlxG.random.bool(50);
				counter.acceleration.y = 550;
				counter.velocity.y -= FlxG.random.int(140, 175);
				counter.velocity.x -= FlxG.random.int(-50, 50);
				FlxTween.tween(counter, {
					alpha: 0,
					'scale.x': FlxG.random.float(0.45, 0.65),
					'scale.y': FlxG.random.float(0.45, 0.65),
					angle: leanDirection ? FlxG.random.int(15, 35) : FlxG.random.int(-15, -35)
				}, 1, {
					ease: FlxEase.quadIn,
					onComplete: function(twn)
					{
						counter.kill();
					}
				});
			}
			else
			{
				for (strum in strums)
				{
					FlxTween.tween(strum, {alpha: 1}, 1);
				}
				startSong();
			}
		}, 4);
	}

	private function startSong():Void
	{
		generateNotes();
		trace('Generated Notes');
		if (songType == SongType.FridayNightFunkin)
		{
			FlxG.sound.playMusic(music, 1, false);
			FlxG.sound.list.add(voices);
			voices.play(true, 0.0);

			FlxG.sound.music.onComplete = endSong;
		}
		else if (songType == SongType.OsuMania)
		{
			FlxG.sound.playMusic(music, 1, false);
			FlxG.sound.music.onComplete = endSong;
		}
		startedSong = true;
		trace('Started Song');
	}

	private function createParticle(x:Float, y:Float)
	{
		var particle:NoteParticle = new NoteParticle(x, y);
		add(particle);
	}

	private function calculateJudgement(note:Note):Array<Dynamic>
	{
		var score:Int = 0;
		var rating:Float = 0;
		var diff = Math.abs(note.strumTime - songPos);
		if (!note.isSustain)
		{
			if (QMath.isBetween(diff, Conductor.hitFrame * 0.75, Conductor.hitFrame, true))
			{
				score = 100;
				rating = 0.5;
			}
			else if (QMath.isBetween(diff, Conductor.hitFrame * 0.35, Conductor.hitFrame * 0.75, false))
			{
				score = 200;
				rating = 0.75;
			}
			else if (QMath.isBetween(diff, 0, Conductor.hitFrame * 0.35, true))
			{
				score = 350;
				rating = 1;
			}
			else
			{
				score = 0;
				rating = 1;
				trace('Got a weird diff of: $diff, to make the game fair, gonna count that as a 350 press but with no score');
			}
			popUpRating(score);
		}
		else
		{
			score = 350;
			rating = 1;
		}
		return [score, rating];
	}

	private function popUpRating(score:Int)
	{
		var rating:FlxSprite = new FlxSprite(STRUM_X - 192, STRUM_Y).loadGraphic(Paths.ImagePath('gameplay/rating.png'), true, 192, 96, false);
		rating.antialiasing = true;
		add(rating);
		switch (score)
		{
			case 350:
				rating.animation.frameIndex = 0;
				rating.color = FlxColor.fromInt(0xFFDBF1FF);
			case 200:
				rating.animation.frameIndex = 1;
				rating.color = FlxColor.fromInt(0xFFDCFFDB);
			case 100:
				rating.animation.frameIndex = 2;
				rating.color = FlxColor.fromInt(0xFFFDFFDB);
			default:
				trace('Got an unreachable score of $score');
		}
		var leanDirection = FlxG.random.bool(50);
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(-50, 50);
		FlxTween.tween(rating, {
			alpha: 0,
			'scale.x': FlxG.random.float(0.45, 0.65),
			'scale.y': FlxG.random.float(0.45, 0.65),
			angle: leanDirection ? FlxG.random.int(15, 35) : FlxG.random.int(-15, -35)
		}, 1, {
			ease: FlxEase.quadIn,
			onComplete: function(twn)
			{
				rating.destroy();
			}
		});
	}

	private function changeHealth(amount:Float)
	{
		health = FlxMath.bound(health + amount, 0, 1);
		updateHealthText();
		if (health == 0)
			lose();
	}

	private function lose()
	{
		dead = true;
		healthBar.percent = 0;
		remove(healthText);
		FlxG.sound.music.pause();
		if (songType == SongType.FridayNightFunkin)
			voices.pause();
		startedSong = false;
		FlxTween.tween(healthBar, {angle: 5, y: 2000}, 2, {ease: FlxEase.quadIn});
		FlxTween.tween(positionBar, {angle: -5, y: 1000}, 4, {ease: FlxEase.quadIn});

		notes.forEachAlive(function(note:Note)
		{
			FlxTween.tween(note, {alpha: 0}, 2);
			note.velocity.x -= FlxG.random.int(-50, 50);
			note.velocity.y -= FlxG.random.int(140, 175);
			note.acceleration.y = 550;
		});
		strums.forEachAlive(function(strum:StrumNote)
		{
			FlxTween.tween(strum, {alpha: 0}, 2);
			strum.velocity.x -= FlxG.random.int(-50, 50);
			strum.velocity.y -= FlxG.random.int(140, 175);
			strum.acceleration.y = 550;
		});
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			openSubState(new LostSubState(0, 0, [formattedName, formattedDiff, misses, accuracy, score, totalHit, combo, maxCombo]));
		});
	}

	private function hitNote(note:Note)
	{
		var judge = calculateJudgement(note);
		createParticle(strums.members[note.direction].x, strums.members[note.direction].y);
		if (note.isSustain)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		else
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
			totalHit += 1;
			score += judge[0];
			combo += 1;

			new FlxSound().loadEmbedded(Sound.fromFile('assets/sounds/hitsound.ogg'), false).play(true);
		}
		hitRating += judge[1];
		changeHealth(0.0125);

		totalNotes += 1;
		if (combo > maxCombo)
			maxCombo = combo;
		updateScore();
	}

	private function missNote(note:Note)
	{
		totalNotes += 1;
		hitRating -= 1;
		note.kill();
		notes.remove(note, true);
		note.destroy();
		misses += 1;
		changeHealth(-0.05);
		if (combo > maxCombo)
			maxCombo = combo;
		combo = 0;
		updateScore();
		new FlxSound().loadEmbedded(Sound.fromFile('assets/sounds/miss.ogg'), false).play(true);
	}

	var prevRank = 0;

	private function updateScore()
	{
		accuracy = hitRating != 0 || totalNotes != 0 ? FlxMath.roundDecimal((hitRating / totalNotes) * 100, 2) : 0;
		if (QMath.isBetween(accuracy, 0, 60, true))
			rankNum = 0;
		else if (QMath.isBetween(accuracy, 60, 70, true))
			rankNum = 1;
		else if (QMath.isBetween(accuracy, 70, 80, true))
			rankNum = 2;
		else if (QMath.isBetween(accuracy, 80, 90, true))
			rankNum = 3;
		else if (QMath.isBetween(accuracy, 90, 100, false))
			rankNum = 4;
		else if (accuracy >= 100)
			rankNum = 5;

		if (accuracy <= 0)
			accuracy = 0;

		if (prevRank != rankNum)
		{
			rank.animation.frameIndex = rankNum;
			var rankEffect = rank.clone();
			rankEffect.x = rank.x;
			rankEffect.y = rank.y;
			rankEffect.updateHitbox();
			add(rankEffect);
			FlxTween.tween(rankEffect, {"scale.x": 1.5, "scale.y": 1.5, alpha: 0}, 1, {
				ease: FlxEase.cubeOut,
				onComplete: function(twn)
				{
					rankEffect.destroy();
				}
			});
		}
		prevRank = rank.animation.frameIndex;

		stats.text = 'Hits: $totalHit\nMisses: $misses\nScore: $score\nCombo: $combo / $maxCombo\nAccuracy: $accuracy%';
		stats.y = FlxG.height - (15 + stats.height);
		QMDiscordRpc.changeStatus('Playing $formattedName ($formattedDiff)', 'Misses: $misses, Acc: $accuracy%');
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (!startedSong)
			return;
		for (note in notes)
			if (note.canBeHit && !note.isSustain && controlHold[note.direction])
				hitNote(note);
	}

	private function checkForHit(note:Note)
	{
		if (note.strumTime - songPos > -Conductor.hitFrame && note.strumTime - songPos < Conductor.hitFrame)
			note.canBeHit = true;
		else
			note.canBeHit = false;

		if (!note.isSustain && note.strumTime < songPos && !note.canBeHit)
			missNote(note);
		// if (note.isSustain && (note.strumTime + note.sustainParent.sustainLength) < songPos && !note.canBeHit)
		// 	missNote(note);

		if (note.strumTime < songPos && note.canBeHit)
			note.late = true;

		var center:Float = STRUM_Y + 128 / 2;
		// if (controlHold[note.direction] && note.isSustain && note.canBeHit && !note.sustainLocked)
		// {
		// 	if (note.strumTime - songPos < 0 && note.isSustainEnd)
		// 		hitNote(note);
		// 	if ((note.strumTime + note.sustainParent.sustainLength) - songPos < 0 && !note.isSustainEnd)
		// 		hitNote(note);
		// }
		if (controlHold[note.direction] && note.isSustain && note.canBeHit)
		{
			// (40     - 0             * 3            + 128         >= 72)
			if (note.y - note.offset.y * note.scale.y + note.height >= center)
			{
				if (note.y < STRUM_Y + 64)
					note.y = STRUM_Y + 64;
				var sustainRect = new FlxRect(0, STRUM_Y + note.height / 2 - note.y, note.width * 2, note.height * 2);
				sustainRect.y /= note.scale.y;
				sustainRect.height -= sustainRect.y;
				sustainRect.height += 20;
				note.clipRect = sustainRect;
			}
			if (note.strumTime - songPos < 0)
				hitNote(note);
		}
	}

	private function endSong()
	{
		if (!autoplay){
			Scores.saveSong(songName, songDiff, {
				accuracy: accuracy,
				misses: misses,
				score: score,
				hits: totalHit,
				maxCombo: maxCombo
			});
			Scores.saveScores();
		}
		songEnded = true;
		new FlxTimer().start(1, function(tmr)
		{
			FlxG.sound.music.stop(); // makes a "crash" but the game is fine. huh. whatever, it works.
			FlxG.sound.music = null;
			FlxG.switchState(new MenuState());
		});
	}

	private function inputHandle()
	{
		if (!autoplay){
		var directions = ['left', 'down', 'up', 'right'];
		for (i in 0...4)
		{
			controlPressed[i] = Controls.justPressed(directions[i]);
			controlHold[i] = Controls.pressed(directions[i]);
			controlRelease[i] = Controls.justReleased(directions[i]);
		}

		if (controlPressed.contains(true))
		{
			onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN));
		}

		if (Controls.pressed('left'))
			strums.members[0].playAnim('pressed');
		if (Controls.pressed('down'))
			strums.members[1].playAnim('pressed');
		if (Controls.pressed('up'))
			strums.members[2].playAnim('pressed');
		if (Controls.pressed('right'))
			strums.members[3].playAnim('pressed');
		}

		if (startedSong)
			if (Controls.justPressed('pause'))
			{
				FlxG.sound.music.pause();
				if (songType == SongType.FridayNightFunkin)
					voices.pause();
				var pss = new PauseSubState(0, 0, [formattedName, formattedDiff, misses, accuracy]);
				openSubState(pss);
			}

			if (!autoplay){
		if (Controls.justReleased('left'))
			strums.members[0].playAnim('idle');
		if (Controls.justReleased('down'))
			strums.members[1].playAnim('idle');
		if (Controls.justReleased('up'))
			strums.members[2].playAnim('idle');
		if (Controls.justReleased('right'))
			strums.members[3].playAnim('idle');
	}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// var prevHealth = health;
		if (autoplay)
		{
			if (startedSong)
			{
				for (note in notes)
				{
					if (note.canBeHit)
					{
						if (note.isSustain)
						{
							if (note.canBeHit)
							{
								hitNote(note);
							}
						}
						else if (note.strumTime <= songPos || note.isSustain)
						{
							hitNote(note);
						}
					}
				}
			}
		}
		inputHandle();

		if (startedSong)
		{
			songPos = FlxG.sound.music.time;
			clampSongPos = songPos / FlxG.sound.music.length;
			if (clampSongPos >= 1)
				clampSongPos = 1;
			for (note in notes)
			{
				if (!downscroll)
					note.y = (STRUM_Y - (songPos - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)) - Preferences.visualOffset);
				else
					note.y = (STRUM_Y + (songPos - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)) + Preferences.visualOffset);
				checkForHit(note);
			};

			FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));
			// health = FlxMath.lerp(health, prevHealth, 0.5 * elapsed);

			if (Globals.debugMode)
				debugText.text = 'Steps: $steps\nBeats: $beats';
		}
		if (songEnded)
		{
			positionBar.value = 1;
		}
	}

	private inline function resyncVocals()
	{
		voices.time = FlxG.sound.music.time;
	}

	override function closeSubState()
	{
		super.closeSubState();
		subState.destroy();
		FlxG.sound.music.resume();
		if (songType == SongType.FridayNightFunkin)
		{
			voices.resume();
			resyncVocals();
		}
	}
}

class PauseSubState extends FlxSubState
{
	var songData:Array<Dynamic>;

	public function new(x:Float, y:Float, songData:Array<Dynamic>)
	{
		super();
		this.songData = songData;

		QMDiscordRpc.changeStatus('Paused ${songData[0]} (${songData[1]})', 'Misses: ${songData[2]}, Acc: ${songData[3]}%');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.justPressed('pause'))
			closeMenu();
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
			closeSong();
		}
	}

	private function closeMenu()
	{
		new FlxTimer().start(0.5, function(tmr)
		{
			close();
			QMDiscordRpc.changeStatus('Playing ${songData[0]} (${songData[1]})', 'Misses: ${songData[2]}, Acc: ${songData[3]}%');
		});
	}

	private function restartSong()
	{
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.resetState();
		});
	}

	private function closeSong()
	{
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.switchState(new SongSelectState());
		});
	}
}

class LostSubState extends FlxSubState
{
	var songData:Array<Dynamic>;

	public function new(x:Float, y:Float, songData:Array<Dynamic>) // name, diff, misses, accuracy, score, hits, combo, mcombo
	{
		super();
		this.songData = songData;

		QMDiscordRpc.changeStatus('Paused ${songData[0]} (${songData[1]})', 'Misses: ${songData[2]}, Acc: ${songData[3]}%');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER)
			restartSong();
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
			closeSong();
		}
	}

	private function restartSong()
	{
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.resetState();
		});
	}

	private function closeSong()
	{
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.switchState(new SongSelectState());
		});
	}
}
