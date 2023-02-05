package states.songselect;

import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import openfl.system.System;
import flixel.FlxSubState;
import QMAssets.QMAssets;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import gameplay.SongState;

class SongSelectState extends FlxState
{
	var songs:FlxText;
	var diffs:FlxText;
	var pickerSym:FlxText;
	var pickerDiffSym:FlxText;
	var songNameList:Array<String>;
	var songDiffList:Array<String>;
	var songBoxes:FlxTypedSpriteGroup<SongSelectBox>;
	var curSelected:Int = 0;
	var curDiffSelected:Int = 0;
	var selectingSong:Bool = true;

	override public function create()
	{
		super.create();

		var background = new FlxSprite(0, 0).loadGraphic('assets/images/menu/background.png');
		background.color = 0xFF333333;
		add(background);

		System.gc();
		pickerSym = new FlxText(48, 64, FlxG.width - 128, ">");
		pickerDiffSym = new FlxText(176, 64, FlxG.width - 128, ">");
		songs = new FlxText(64, 64, FlxG.width - 128);
		diffs = new FlxText(192, 64, FlxG.width - 128);
		songNameList = QMAssets.FNFreadAllCharts();
		songBoxes = new FlxTypedSpriteGroup<SongSelectBox>();
		refillDiffs();
		var i = 0;
		for (sn in songNameList)
		{
			songs.text += '$sn\n';
			songBoxes.add(new SongSelectBox(FlxG.width - 524, sn, i));
			i++;
		}
		pickerSym.antialiasing = true;
		pickerDiffSym.antialiasing = true;
		songs.antialiasing = true;
		diffs.antialiasing = true;
		add(pickerSym);
		add(pickerDiffSym);
		add(songs);
		add(diffs);
		add(songBoxes);
	}

	private function refillDiffs()
	{
		diffs.text = "";
		songDiffList = QMAssets.FNFreadAllDiffs(songNameList[curSelected]);
		for (diff in songDiffList)
		{
			diffs.text += '$diff\n';
		}
		curDiffSelected = 0;
		updatePickerPos(true);
	}

	private function updatePickerPos(diffPicker:Bool = false)
	{
		if (!diffPicker)
			pickerSym.y = 64 + (curSelected * 10);
		else
			pickerDiffSym.y = 64 + (curDiffSelected * 10);
	}

	private function changeSelection(amount:Int, diffs:Bool = false)
	{
		if (!diffs)
		{
			curSelected += amount;

			if (curSelected >= songNameList.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = songNameList.length - 1;
			updatePickerPos(false);
			refillDiffs();
		}
		else
		{
			curDiffSelected += amount;

			if (curDiffSelected >= songDiffList.length)
				curDiffSelected = 0;
			if (curDiffSelected < 0)
				curDiffSelected = songDiffList.length - 1;
			updatePickerPos(true);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var prevSongBoxY = songBoxes.y;
		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1, false);
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1, false);
		if (FlxG.keys.justPressed.S)
			changeSelection(1, true);
		else if (FlxG.keys.justPressed.W)
			changeSelection(1, true);

		if (FlxG.keys.justPressed.ENTER)
		{
			SongState.songName = songNameList[curSelected];
			SongState.songDiff = songDiffList[curDiffSelected];
			var songState:SongState = new SongState();
			FlxG.switchState(songState);
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
		songBoxes.y = FlxMath.lerp(prevSongBoxY, -(curSelected * 152 - (152 * 2)), 0.02);
	}
}

class ModifierSelectionSubState extends FlxSubState
{
	/* * Modifiers:
	 * * Neutral:
	 * Health modifier (Gain: 1.25x, Drain: 0.5x)
	 * Hit adjust (300: 0.75, 200: 0.125, 100: 0.125)
	 * Slower song (0.75x)
	 * 
	 * * Easier:
	 * No Fail
	 * 
	 * * Harder:
	 * Fading (Fade-Out, Fade-In)
	 * Instakill
	 * 
	 * * No score:
	 * Autoplay
	 */
	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
