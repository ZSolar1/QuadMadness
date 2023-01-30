package states;

import gameplay.Note;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import gameplay.StrumNote;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;
import flash.media.Sound;

using StringTools;

class ChartEditorState extends FlxState
{
	public static var STRUM_X = 640 - 256;
	public static var STRUM_Y = 16;
	public static var STRUM_SIZE = 16;

	var strums:FlxTypedGroup<StrumNote>;

	var songName:String = "final-boss-chan";
	var songDiff:String = "hard";
	var songLength:Float = 0;
	var songPos:Float = 0;

	var bpm:Float = 322;
	var crochet:Float = 0.0;
	var stepCrochet:Float = 0.0;
	var curBeat:Int;
	var curStep:Int;
	var beats:Float;
	var steps:Float;

	var songNameText:FlxText;
	var songDiffText:FlxText;
	var songPosText:FlxText;

	var beatBars:FlxTypedGroup<BeatBar>;
	var notes:FlxTypedGroup<Note>;

	override public function create()
	{
		super.create();
		var background = new FlxSprite(0, 0).loadGraphic('assets/images/menu/background.png');
		background.color = 0xFF333333;
		add(background);

		songNameText = new FlxText(15, FlxG.height - 70, STRUM_X - 30, FlxStringUtil.toTitleCase(songName.replace('-', ' ')));
		songDiffText = new FlxText(15, FlxG.height - 40, STRUM_X - 30, songDiff.toUpperCase());
		songPosText = new FlxText(STRUM_X + 512 + 15, FlxG.height - 40, 512, "0 / 0");

		songNameText.setFormat(Fonts.NotoSans.Medium, 24);
		songDiffText.setFormat(Fonts.NotoSans.LightItalic, 20);
		songPosText.setFormat(Fonts.NotoSans.Light, 20);

		add(songNameText);
		add(songDiffText);
		add(songPosText);

		strums = new FlxTypedGroup<StrumNote>();
		beatBars = new FlxTypedGroup<BeatBar>();
		notes = new FlxTypedGroup<Note>();
		for (i in 0...4)
		{
			var strum:StrumNote = new StrumNote(STRUM_X, 0);
			strum.x += i * 128;
			strum.y += STRUM_Y;
			strums.add(strum);
		}
		add(strums);
		add(beatBars);
		loadSong();
	}

	function loadSong()
	{
		FlxG.sound.music = new FlxSound().loadEmbedded(Sound.fromFile('mods/charts/$songName/music.ogg'), false);
		songPos = 0;
		songLength = FlxG.sound.music.length;
		FlxG.sound.music.play();
		FlxG.sound.music.pause();
		crochet = (60 / bpm) * 1000;
		stepCrochet = crochet / 4;
		for (i in 0...5)
		{
			beatBars.add(new BeatBar(crochet * i));
		}
	}

	function resumePause()
	{
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.pause();
		}
		else
		{
			FlxG.sound.music.resume();
		}
	}

	private function beatHit()
	{
		beatBars.add(new BeatBar(songPos + crochet * 4));
		trace('beat hit');
	}

	private function stepHit()
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var prevStep = curStep;
		if (FlxG.sound.music.playing)
		{
			songPos = FlxG.sound.music.time;
			songPosText.text = '${songPos / 1000} / ${songLength / 1000}';
		}
		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MenuState());
		if (FlxG.keys.justPressed.SPACE)
			resumePause();

		steps = songPos / stepCrochet;
		beats = songPos / crochet;

		curStep = Math.floor(steps);
		curBeat = Math.floor(beats);

		if (prevStep != curStep)
			if (curStep > 0)
				stepHit();

		beatBars.forEachAlive(function(bar)
		{
			// bar.y = (STRUM_Y - (songPos - (crochet * 4)) * (0.45 * FlxMath.roundDecimal(Preferences.scrollSpeed, 2)) - Preferences.visualOffset);
			var calc = (STRUM_Y - (songPos - bar.time) * (0.45 * FlxMath.roundDecimal(Preferences.scrollSpeed, 2)) - Preferences.visualOffset);
			bar.y = (calc);
			if (bar.time - songPos < -1500)
			{
				beatBars.remove(bar, true);
				bar.destroy();
			}
		});
	}
}

class BeatBar extends FlxSprite
{
	public var time:Float = 0.0;

	public function new(time:Float)
	{
		super(ChartEditorState.STRUM_X, -2000);
		makeGraphic(512, 8, 0xFFFFFFFF);
		alpha = 0.25;
		this.time = time;
	}
}
