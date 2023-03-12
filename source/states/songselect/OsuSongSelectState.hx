package states.songselect;

import maps.MapPackager;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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

class OsuSongSelectState extends FlxState
{
	var selectedSong:String;
	var selectedDiff:String;

	var songNameList:Array<String>;
	var songDiffList:Array<String>;
	var songBoxes:FlxTypedSpriteGroup<SongSelectBox>;
	var curSelected:Int = 0;

	var selectingSong:Bool = true;
	var selectingDiff:Bool = false;

	var pickedBox:SongSelectBox;

	override public function create()
	{
		super.create();

		var background = new FlxSprite(0, 0).loadGraphic('assets/images/menu/background.png');
		background.color = 0xFF333333;
		add(background);
		songNameList = QMAssets.OsuReadAllCharts();
		songBoxes = new FlxTypedSpriteGroup<SongSelectBox>();
		refillDiffs();
		fillSongs();
		add(songBoxes);
		System.gc();
	}

	private function fillSongs()
	{
		var i = 0;
		for (sn in songNameList)
		{
			songBoxes.add(new SongSelectBox(FlxG.width - 524, sn, i));
			i++;
		}
	}

	private function fillDiffs()
	{
		songDiffList = QMAssets.OsuReadAllDiffs(songNameList[curSelected]);
		var i = 0;
		for (sd in songDiffList)
		{
			songBoxes.add(new SongSelectBox(FlxG.width - 524, sd, i));
			i++;
		}
	}

	private function selectSong()
	{
		var boxesX = songBoxes.x;
		selectingSong = false;
		selectedSong = songNameList[curSelected];
		pickedBox = new SongSelectBox(-524, songNameList[curSelected], 0);
		pickedBox.y = 40;
		pickedBox.mirrorBox();
		pickedBox.listed = false;
		for (box in songBoxes)
		{
			box.listed = false;
		}
		FlxTween.tween(pickedBox, {x: 0, y: 40}, 1, {ease: FlxEase.cubeOut});
		FlxTween.tween(songBoxes, {x: FlxG.width + 524}, 1, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn)
			{
				songBoxes.visible = false;
				songBoxes.clear();
				fillDiffs();
				for (box in songBoxes)
				{
					box.listed = false;
				}
				songBoxes.visible = true;
				curSelected = 0;
				FlxTween.tween(songBoxes, {x: boxesX}, 1, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn)
					{
						for (box in songBoxes)
						{
							box.listed = true;
						}
						selectingSong = true;
						selectingDiff = true;
					}
				});
			}
		});
		add(pickedBox);
	}

	private function refillDiffs()
	{
		songDiffList = QMAssets.OsuReadAllDiffs(songNameList[curSelected]);
	}

	private function changeSelection(amount:Int)
	{
		curSelected += amount;

		if (curSelected >= songBoxes.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = songBoxes.length - 1;
		if (!selectingDiff)
			refillDiffs();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var prevSongBoxY = songBoxes.y;
		if (selectingSong)
		{
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);
			else if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.ENTER)
			{
				if (!selectingDiff)
				{
					selectSong();
				}
				else
				{
					trace(songDiffList[curSelected]);
					selectedDiff = songDiffList[curSelected];
					trace('SelectedN: $curSelected, Diff: $selectedDiff');
					SongState.songName = selectedSong;
					SongState.songDiff = selectedDiff;
					SongState.songType = 'mania';
					var songState:SongState = new SongState();
					FlxG.switchState(songState);
				}
			}
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
		if (FlxG.keys.justPressed.F1)
		{
			MapPackager.packageSong('fnf', songNameList[curSelected]);
		}
		if (FlxG.keys.justPressed.F2)
		{
			MapPackager.extractSong(songNameList[curSelected]);
		}
		songBoxes.y = FlxMath.lerp(prevSongBoxY, -(curSelected * 152 - (152 * 2)), 0.02);
	}
}
