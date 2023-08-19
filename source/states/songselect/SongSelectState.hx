package states.songselect;

import skin.SkinLoader;
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

class SongSelectState extends FlxState
{
	var background:FlxSprite;
	var selectedSong:String;
	var selectedDiff:String;

	var songNameList:Array<String>;
	var songDiffList:Array<String>;
	var songBoxes:FlxTypedSpriteGroup<SongSelectBox>;
	var curSelected:Int = 0;

	var selectingSong:Bool = true;
	var selectingDiff:Bool = false;

	var pickedBox:SongSelectBox;

	override function onResize(Width:Int, Height:Int)
	{
		super.onResize(Width, Height);
		resizeSprites();
	}

	function resizeSprites()
	{
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.updateHitbox();
	}

	override public function create()
	{
		super.create();

		background = new FlxSprite(0, 0).loadGraphic(SkinLoader.getSkinnedImage('menu/background.png'));
		background.color = 0xFF333333;
		add(background);
		songNameList = QMAssets.FNFreadAllCharts();
		if (songNameList == null)
		{
			FlxG.switchState(new states.CrashHandlerState("You don't have any songs added. To add a new song or multiple songs, In the games main folder, add a folder called mods. Then make a folder named the type of mod you want to add. For a starter pack, go to (link here) For more info on how to install mods, read this (article?? idfk) here: (link here)", null));
			trace("No songs!");
			var noSongs = new SongSelectBox(0, "No songs!", 0);
			add(noSongs);
		}
		else
		{
			songBoxes = new FlxTypedSpriteGroup<SongSelectBox>();
			refillDiffs();
			fillSongs();
			add(songBoxes);
		}
		resizeSprites();
	}

	private function fillSongs()
	{
		var i = 0;
		for (sn in songNameList)
		{
			songBoxes.add(new SongSelectBox(FlxG.width - 600, sn, i));
			i++;
		}
	}

	private function fillDiffs()
	{
		songDiffList = QMAssets.FNFreadAllDiffs(songNameList[curSelected]);
		var i = 0;
		for (sd in songDiffList)
		{
			songBoxes.add(new SongSelectBox(FlxG.width - 600, sd, i));
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
		FlxTween.tween(pickedBox, {x: 50, y: 40}, 1, {ease: FlxEase.cubeOut});
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
		songDiffList = QMAssets.FNFreadAllDiffs(songNameList[curSelected]);
	}

	private function changeSelection(amount:Int)
	{
		curSelected += amount;

		if (curSelected >= songBoxes.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = songBoxes.length - 1;
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
					SongState.songType = 'fnf';
					var songState:SongState = new SongState();
					FlxG.switchState(songState);
				}
			}
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (pickedBox != null)
			{
				FlxTween.tween(pickedBox, {x: -620, y: 40}, 1.5, {ease: FlxEase.cubeOut});
				pickedBox.listed = false;
			}
			for (box in songBoxes)
			{
				box.listed = false;
			}
			FlxG.camera.fade(0xFFFFFFFF, 0.5, false, function()
			{
				FlxG.switchState(new MenuState());
			});
		}
		songBoxes.y = FlxMath.lerp(prevSongBoxY, -(curSelected * 152 - (152 * 2)) + (Math.abs(FlxG.height - 720) / 2), 0.02);
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
