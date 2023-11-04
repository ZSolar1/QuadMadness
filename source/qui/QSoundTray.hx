package qui;

import openfl.text.TextFormat;
import openfl.text.TextField;
import flixel.math.FlxMath;
import openfl.Lib;
import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.system.ui.FlxSoundTray;

class QSoundTray extends FlxSoundTray
{
	var background:BitmapData;

	var volumeBar:Bitmap;
	var volumeText:TextField;

	var timer:Float = 0;

	var offsetX:Float = 10;
	var offsetY:Float = 10;

	@:keep
	public function new()
	{
		super();
		removeChildren();

		background = Assets.getBitmapData("assets/images/menu/optionbox.png");
		var tmp:Bitmap = new Bitmap(background);
		tmp.smoothing = true;
		tmp.scaleX = 0.25;
		tmp.scaleY = 0.25;
		addChild(tmp);

		volumeBar = new Bitmap(new BitmapData(4, 2, false, 0xFF000000));
		volumeBar.x = 32;
		volumeBar.y = 18;
		addChild(volumeBar);

		volumeText = new TextField();
		volumeText.selectable = false;
		volumeText.defaultTextFormat = new TextFormat(Fonts.NotoSans.Regular, 12, 0xFF000000);
		volumeText.y = volumeBar.y - 10;
		volumeText.width = tmp.width;
		volumeText.height = tmp.height;
		addChild(volumeText);

		visible = false;
		alpha = 0;
	}

	override function update(MS:Float)
	{
		if (timer > 0)
		{
			if (timer <= 100)
			{
				alpha = timer / 100;
			}
			timer -= 0.5 * MS;
		}
		else
		{
			visible = false;
			active = false;
		}

		// 50 from left, 50 from right, 161 width of max volume
		volumeBar.width = FlxMath.lerp(volumeBar.width, FlxG.sound.muted ? 0 : FlxG.sound.volume * 50, 0.1);
		volumeText.x = volumeBar.x + volumeBar.width + 5;
		var percentage = Math.ceil(volumeBar.width * 2);
		volumeText.text = '${percentage == 1 ? 0 : percentage}%';
	}

	override function show(up:Bool = false)
	{
		if (!silent)
		{
			var sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		visible = true;
		active = true;

		timer = 1000;
		alpha = 1;
	}

	override function screenCenter()
	{
		x = Lib.current.stage.stageWidth - (width) - offsetX;
		y = offsetY;
	}
}