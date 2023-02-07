package gameplay;

import flixel.system.ui.FlxSoundTray;
import hscript.Interp;
import flixel.FlxCamera;
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
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import maps.Convert;
import maps.FNF.Song;
import maps.MapChart;
import openfl.events.KeyboardEvent;
import states.MenuState;

class SongState extends FlxState
{
	public static var instance:SongState;

	public static var STRUM_X = 640 - 256;
	public static var STRUM_Y = 16;
	public static var STRUM_SIZE = 16;
	public static var songName:String = '';
	public static var songDiff:String = '';

	var background:FlxSprite;

	var chart:MapChart;

	// All song types:
	// native -  - TODO
	// mania - TODO
	// quaver - TODO
	// fnf - Almost done
	var songType:String = 'fnf';

	var strums:FlxTypedGroup<StrumNote>;
	var particles:FlxTypedGroup<NoteParticle>;
	var allNotes:Array<Note>;
	var notes:FlxTypedGroup<Note>;

	var stats:FlxText;
	var positionBar:FlxBar;
	var healthBar:FlxBar;
	var healthText:FlxText;

	var downscroll:Bool;

	var songPos:Float = 0.0;
	var clampSongPos:Float = 1.0;
	var scrollSpeed:Float = 0.0;
	var paused:Bool = false;

	// FNF is a good example
	var bpm:Float = 0.0;
	var crochet:Float = 0.0;
	var stepCrochet:Float = 0.0;
	var voices:FlxSound;

	var music:openfl.media.Sound;

	var curBeat:Int;
	var curStep:Int;

	var beats:Float;
	var steps:Float;

	var startedSong:Bool = false;

	var totalNotes:Int = 0;

	var totalHit:Int = 0;
	var hitRating:Float = 0;
	var accuracy:Float = 0;
	var misses:Int = 0;
	var score:Int = 0;
	var combo:Int = 0;
	var maxCombo:Int = 0;
	var health:Float = 0.5;

	var controlPressed:Array<Bool> = [false, false, false, false];
	var controlHold:Array<Bool> = [false, false, false, false];
	var controlRelease:Array<Bool> = [false, false, false, false];

	// All of the debug stuff sits here
	var debugText:FlxText;

	override public function create()
	{
		super.create();

		instance = this;

		// FlxG.camera.pixelPerfectRender = false;
		QMDiscordRPC.changePresence('Starting $songName ($songDiff)', null);
		scrollSpeed = Preferences.scrollSpeed;

		background = new FlxSprite(0, 0).loadGraphic('assets/images/menu/background.png');
		background.color = 0xFF333333;
		add(background);

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
		updateHealthText();

		if (Globals.debugMode)
			add(debugText);
		add(stats);
		add(positionBar);
		add(healthBar);
		add(healthText);

		downscroll = Preferences.downscroll;
		if (downscroll)
			STRUM_Y = FlxG.height - 16 - 128;
		else
			STRUM_Y = 16;
		trace(Conductor.hitFrame);
		if (songType == 'fnf')
		{
			if (songDiff == 'normal' && !QMAssets.exists('mods/fnf/$songName/$songName-normal.json'))
				chart = Convert.FNF(Song.loadFromJson('$songName.json', songName));
			else
				chart = Convert.FNF(Song.loadFromJson('$songName-$songDiff.json', songName));
		}
		allNotes = new Array<Note>();
		allNotes = chart.notes;

		bpm = chart.bpm[0];
		crochet = (60 / bpm) * 1000;
		stepCrochet = crochet / 4;

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
		if (songType == 'fnf')
		{
			music = Sound.fromFile('mods/fnf/$songName/Inst.ogg');
			voices = new FlxSound().loadEmbedded(Sound.fromFile('mods/fnf/$songName/Voices.ogg'), false);
		}
		startCountdown();
	}

	// Finally added beats and steps
	private function beatHit()
	{
		if (curBeat % 4 == 0)
		{
			if (songType == 'fnf')
				resyncVocals();
			FlxG.camera.zoom += 0.02;
		}
	}

	// I thought it would be harder
	private function stepHit()
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	private function updateHealthText()
	{
		healthText.y = FlxG.height - Math.round(health * 512) - (healthText.height / 2);
		healthText.text = Std.string(Math.round(health * 100)) + '%';
	}

	private function generateNotes()
	{
		notes = new FlxTypedGroup<Note>();
		for (note in allNotes)
		{
			var sustainLength = note.sustainLength / stepCrochet;
			note.x = STRUM_X + (note.direction * note.width);
			if (note.sustainLength > 0)
			{
				for (sustainId in 0...Math.floor(sustainLength + 1))
				{
					var sustainNote:Note = new Note(note.strumTime + (stepCrochet * sustainId) + (stepCrochet / scrollSpeed), note.direction, 0, true);
					sustainNote.x = STRUM_X + (sustainNote.direction * sustainNote.width);
					if (sustainId == Math.floor(sustainLength)) // Last sustain note
					{
						sustainNote.animation.frameIndex = 4;
						sustainNote.isSustainEnd = true;
						sustainNote.flipY = downscroll;
					}
					else
					{
						sustainNote.scale.y *= stepCrochet / 100 * 1.075;
						sustainNote.scale.y *= scrollSpeed;
						sustainNote.scale.y /= 3;
					}

					// For debug purposes
					// sustainNote.alpha = 0.5;

					sustainNote.updateHitbox();
					notes.add(sustainNote);
				}
			}
			notes.add(note);
			// trace('Note: ' + note.x);
		}
		trace("Active notes: " + notes.length);
		add(notes);
	}

	private function startCountdown()
	{
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
		// startSong();
	}

	private function startSong():Void
	{
		generateNotes();
		if (songType == 'fnf')
		{
			FlxG.sound.playMusic(music, 1, false);
			FlxG.sound.list.add(voices);
			voices.play(true, 0.0);
			FlxG.sound.music.onComplete = endSong;
			// voices.play(true);
		}
		startedSong = true;
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
			// trace(diff);
			if (QMath.isBetween(diff, Conductor.hitFrame * 0.75, Conductor.hitFrame, true))
			{
				score = 100;
				rating = 0.5;
			}
			else if (QMath.isBetween(diff, Conductor.hitFrame * 0.45, Conductor.hitFrame * 0.75, false))
			{
				score = 200;
				rating = 0.75;
			}
			else if (QMath.isBetween(diff, 0, Conductor.hitFrame * 0.45, true))
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
			// score = 350;
			// rating = 1;
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
		healthBar.percent = 0;
		FlxG.sound.music.pause();
		voices.pause();
		startedSong = false;
		FlxTween.tween(healthBar, {angle: 5, y: 2000}, 2, {ease: FlxEase.quadIn});
		FlxTween.tween(positionBar, {angle: -5, y: 1000}, 4, {ease: FlxEase.quadIn});
		// FlxTween.tween(stats, {angle: 10, y: 1750}, 3, {ease: FlxEase.quadIn});
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
			openSubState(new LostSubState(0, 0, [songName, songDiff, misses, accuracy, score, totalHit, combo, maxCombo]));
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
			// Sound.loadFromFile('assets/sounds/hitsound.ogg')
			new FlxSound().loadEmbedded(Sound.fromFile('assets/sounds/hitsound.ogg'), false).play(true);
		}
		hitRating += judge[1];
		changeHealth(0.0125);
		// trace(hitRating);
		totalNotes += 1;
		if (combo > maxCombo)
			maxCombo = combo;
		updateScore();
	}

	private function missNote(note:Note)
	{
		totalNotes += 1;
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

	private function sortHitNotes(a:Note, b:Note)
	{
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function updateScore()
	{
		accuracy = hitRating != 0 || totalNotes != 0 ? FlxMath.roundDecimal((hitRating / totalNotes) * 100, 2) : 0;

		stats.text = 'Hits: $totalHit\nMisses: $misses\nScore: $score\nCombo: $combo / $maxCombo\nAccuracy: $accuracy%';
		stats.y = FlxG.height - (15 + stats.height);
		QMDiscordRPC.changePresence('Playing $songName ($songDiff)', 'Misses: $misses, Acc: $accuracy%');
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

		if (note.strumTime < songPos && !note.canBeHit)
			missNote(note);

		if (note.strumTime < songPos && note.canBeHit)
			note.late = true;

		var center:Float = STRUM_Y * 2 + note.height / 2;
		if (controlHold[note.direction] && note.isSustain && note.canBeHit)
		{
			if (note.y - note.offset.y * note.scale.y + note.height >= center)
			{
				var sustainRect = new FlxRect(0, STRUM_Y + note.height / 2 - note.y, note.width * 2, note.height * 2);
				sustainRect.y /= note.scale.y;
				sustainRect.height -= sustainRect.y;
				sustainRect.height += 20;

				note.clipRect = sustainRect;
			}
			else
			{
				hitNote(note);
			}
		}
	}

	private function endSong()
	{
		positionBar.parentVariable = '';
		positionBar.percent = 1;
		new FlxTimer().start(1, function(tmr)
		{
			FlxG.switchState(new MenuState());
		});
	}

	private function inputHandle()
	{
		controlPressed[0] = Controls.justPressed('left');
		controlPressed[1] = Controls.justPressed('down');
		controlPressed[2] = Controls.justPressed('up');
		controlPressed[3] = Controls.justPressed('right');

		controlHold[0] = Controls.pressed('left');
		controlHold[1] = Controls.pressed('down');
		controlHold[2] = Controls.pressed('up');
		controlHold[3] = Controls.pressed('right');

		controlRelease[0] = Controls.justReleased('left');
		controlRelease[1] = Controls.justReleased('down');
		controlRelease[2] = Controls.justReleased('up');
		controlRelease[3] = Controls.justReleased('right');

		if (controlPressed.contains(true))
		{
			for (keyPress in controlPressed)
			{
				onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN));
			}
		}

		if (Controls.pressed('left'))
			strums.members[0].playAnim('pressed');
		if (Controls.pressed('down'))
			strums.members[1].playAnim('pressed');
		if (Controls.pressed('up'))
			strums.members[2].playAnim('pressed');
		if (Controls.pressed('right'))
			strums.members[3].playAnim('pressed');

		if (startedSong)
			if (Controls.justPressed('pause'))
			{
				FlxG.sound.music.pause();
				voices.pause();
				var pss = new PauseSubState(0, 0, [songName, songDiff, misses, accuracy]);
				openSubState(pss);
			}

		if (Controls.justReleased('left'))
			strums.members[0].playAnim('idle');
		if (Controls.justReleased('down'))
			strums.members[1].playAnim('idle');
		if (Controls.justReleased('up'))
			strums.members[2].playAnim('idle');
		if (Controls.justReleased('right'))
			strums.members[3].playAnim('idle');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var prevHealth = health;
		var prevStep = curStep;
		inputHandle();

		if (startedSong)
		{
			songPos = FlxG.sound.music.time;
			clampSongPos = songPos / FlxG.sound.music.length;
			if (clampSongPos >= 1)
				clampSongPos = 1;
			notes.forEachAlive(function(note:Note)
			{
				checkForHit(note);
				if (!downscroll)
					note.y = (STRUM_Y - (songPos - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)) - Preferences.visualOffset);
				else
					note.y = (STRUM_Y + (songPos - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)) + Preferences.visualOffset);
				// if (note.y < STRUM_Y)
				// 	note.kill();
			});

			steps = songPos / stepCrochet;
			beats = songPos / crochet;

			curStep = Math.floor(steps);
			curBeat = Math.floor(beats);

			FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125), 0, 1));
			health = FlxMath.lerp(health, prevHealth, 0.5 * elapsed);

			// So simple, yet so effective
			if (prevStep != curStep)
				if (curStep > 0)
					stepHit();

			if (Globals.debugMode)
				debugText.text = 'Steps: $steps\nBeats: $beats';
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
		if (songType == 'fnf')
		{
			voices.resume();
			resyncVocals();
		}
	}

	// Lua stuff
	public function strumTween(id:Int, variable:String, value:Dynamic, duration:Float, ease:String):Void
	{
		FlxTween.tween(strums.members[id + 1], {variable: value}, duration, {ease: QMath.easeFromString(ease)});
	}
}

class PauseSubState extends FlxSubState
{
	var resumeButton:QButton;
	var restartButton:QButton;
	var exitButton:QButton;
	var songData:Array<Dynamic>;

	public function new(x:Float, y:Float, songData:Array<Dynamic>)
	{
		super();
		this.songData = songData;

		QMDiscordRPC.changePresence('Paused ${songData[0]} (${songData[1]})', 'Misses: ${songData[2]}, Acc: ${songData[3]}%');

		resumeButton = new QButton(FlxG.width - FlxG.width / 4, 0, 1, 'play');
		add(resumeButton);
		add(resumeButton.icon);
		resumeButton.appear();

		restartButton = new QButton(FlxG.width - FlxG.width / 4, FlxG.height / 2 - 128, 1, 'back');
		add(restartButton);
		add(restartButton.icon);
		restartButton.appear();

		exitButton = new QButton(FlxG.width - FlxG.width / 4, FlxG.height - 256, 1, 'exit');
		add(exitButton);
		add(exitButton.icon);
		exitButton.appear();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Interactions.Clicked(resumeButton) || Controls.justPressed('pause'))
		{
			closeMenu();
		}
		if (Interactions.Clicked(restartButton))
		{
			restartSong();
		}
		if (Interactions.Clicked(exitButton))
		{
			closeSong();
		}
	}

	private function closeMenu()
	{
		FlxTween.cancelTweensOf(resumeButton);
		FlxTween.cancelTweensOf(restartButton);
		FlxTween.cancelTweensOf(exitButton);

		resumeButton.dissapear();
		restartButton.fade();
		exitButton.fade();
		new FlxTimer().start(0.5, function(tmr)
		{
			close();
			QMDiscordRPC.changePresence('Playing ${songData[0]} (${songData[1]})', 'Misses: ${songData[2]}, Acc: ${songData[3]}%');
		});
	}

	private function restartSong()
	{
		FlxTween.cancelTweensOf(resumeButton);
		FlxTween.cancelTweensOf(restartButton);
		FlxTween.cancelTweensOf(exitButton);

		restartButton.dissapear();
		resumeButton.fade();
		exitButton.fade();
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.resetState();
		});
	}

	private function closeSong()
	{
		FlxTween.cancelTweensOf(resumeButton);
		FlxTween.cancelTweensOf(restartButton);
		FlxTween.cancelTweensOf(exitButton);

		exitButton.dissapear();
		restartButton.fade();
		resumeButton.fade();
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.switchState(new MenuState());
		});
	}
}

class LostSubState extends FlxSubState
{
	var restartButton:QButton;
	var exitButton:QButton;
	var songData:Array<Dynamic>;

	public function new(x:Float, y:Float, songData:Array<Dynamic>) // name, diff, misses, accuracy, score, hits, combo, mcombo
	{
		super();
		this.songData = songData;

		QMDiscordRPC.changePresence('Paused ${songData[0]} (${songData[1]})', 'Misses: ${songData[2]}, Acc: ${songData[3]}%');

		restartButton = new QButton(FlxG.width - FlxG.width / 4, FlxG.height / 2 - 128, 1, 'back');
		add(restartButton);
		add(restartButton.icon);
		restartButton.appear();

		exitButton = new QButton(FlxG.width - FlxG.width / 4, FlxG.height - 256, 1, 'exit');
		add(exitButton);
		add(exitButton.icon);
		exitButton.appear();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Interactions.Clicked(restartButton))
		{
			restartSong();
		}
		if (Interactions.Clicked(exitButton))
		{
			closeSong();
		}
	}

	private function restartSong()
	{
		FlxTween.cancelTweensOf(restartButton);
		FlxTween.cancelTweensOf(exitButton);

		restartButton.dissapear();
		exitButton.fade();
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.resetState();
		});
	}

	private function closeSong()
	{
		FlxTween.cancelTweensOf(restartButton);
		FlxTween.cancelTweensOf(exitButton);

		exitButton.dissapear();
		restartButton.fade();
		new FlxTimer().start(0.5, function(tmr)
		{
			FlxG.switchState(new MenuState());
		});
	}
}
