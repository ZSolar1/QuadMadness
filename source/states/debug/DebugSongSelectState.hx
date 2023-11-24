package states.debug;

import maps.MapPackager;
#if desktop
import sys.io.File;
#end
import SMAssets.SMAssets;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import maps.FunkinParser;
import flixel.ui.FlxButton;

class DebugSongSelectState extends FlxState
{
	var songs:FlxText;
	var diffs:FlxText;
	var pickerSym:FlxText;
	var pickerDiffSym:FlxText;
	var songNameList:Array<String>;
	var songDiffList:Array<String>;
	var curSelected:Int = 0;
	var curDiffSelected:Int = 0;
	var selectingSong:Bool = true;

	override public function create()
	{
		super.create();
		pickerSym = new FlxText(48, 64, FlxG.width - 128, ">");
		pickerDiffSym = new FlxText(176, 64, FlxG.width - 128, ">");
		songs = new FlxText(64, 64, FlxG.width - 128);
		diffs = new FlxText(192, 64, FlxG.width - 128);
		songNameList = SMAssets.FNFreadAllCharts();
		refillDiffs();
		for (sn in songNameList)
		{
			songs.text += '$sn\n';
		}
		add(pickerSym);
		add(pickerDiffSym);
		add(songs);
		add(diffs);
	}

	private function refillDiffs()
	{
		diffs.text = "";
		songDiffList = SMAssets.FNFreadAllDiffs(songNameList[curSelected]);
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
			Globals.LoadState(songState);
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
		if (FlxG.keys.justPressed.F7)
		{
			MapPackager.packageSong('fnf', songNameList[curSelected]);
		}
	}
}
