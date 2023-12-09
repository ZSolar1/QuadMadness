package states.songselect;

import flixel.addons.display.FlxBackdrop;
import states.SongState.SongType;
import skin.SkinLoader;
import maps.MapPackager;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import openfl.system.System;
import flixel.FlxSubState;
import SMAssets.SMAssets;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

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
		curSelected = FlxG.save.data.curFNFSongSelected;
		if (FlxG.sound.music == null){
			FlxG.sound.playMusic('assets/music/menu.ogg', 1, true);
			FlxG.sound.music.time = 13339;
		}
		var checker = new FlxBackdrop(SkinLoader.getSkinnedImage('menu/checker.png'), XY);
		checker.velocity.x = 20;
		add(checker);
		background = new FlxSprite(0, 0).loadGraphic(SkinLoader.getSkinnedImage('menu/background.png'));
		background.color = 0xFF333333;
		add(background);
		songNameList = SMAssets.FNFreadAllCharts();
		if (songNameList == null)
		{
			// TODO: Add notification
			Globals.LoadState(new MenuState());
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
		songDiffList = [];
		songDiffList = SMAssets.FNFreadAllDiffs(songNameList[curSelected]);
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
		FlxTween.tween(pickedBox, {x: 10, y: 40}, 1, {ease: FlxEase.cubeOut});
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
		songDiffList = SMAssets.FNFreadAllDiffs(songNameList[curSelected]);
	}

	private function changeSelection(amount:Int)
	{
		curSelected += amount;

		if (curSelected >= songBoxes.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = songBoxes.length - 1;
		FlxG.save.data.curFNFSongSelected = curSelected;
		refillDiffs();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var prevSongBoxY = songBoxes.y;
		if (selectingSong)
		{
			if (Controls.justPressed('down'))
				changeSelection(1);
			else if (Controls.justPressed('up'))
				changeSelection(-1);
			if (Controls.justPressed('confirm'))
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
					SongState.songType = SongType.FridayNightFunkin;
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
		if (FlxG.keys.justPressed.F7)
		{
			MapPackager.packageSong('fnf', songNameList[curSelected]);
		}
		if (FlxG.keys.justPressed.F8)
		{
			MapPackager.extractSong(songNameList[curSelected]);
		}
		songBoxes.y = FlxMath.lerp(prevSongBoxY, -(curSelected * 152 - (152 * 2)) + (Math.abs(FlxG.height - 720) / 2), 0.16);
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
