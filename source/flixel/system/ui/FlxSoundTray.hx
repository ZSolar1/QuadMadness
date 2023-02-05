package flixel.system.ui;

import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 1.5;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = "flixel/sounds/beep";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'flixel/sounds/beep';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

	var targetY:Float = 0.0;

	var bar:Bitmap;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 40, false, 0xFFFFFF));
		screenCenter();
		var outline:Bitmap = new Bitmap(new BitmapData(_width + 4, 40 + 4, false, 0x000000));
		outline.x -= 4;
		addChild(outline);
		addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(Fonts.NotoSans.Light, 10, 0x000000);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "Volume";
		text.y = 20;

		var bx:Int = 10;
		var by:Int = 14;

		bar = new Bitmap(new BitmapData(4, 4, false, FlxColor.BLACK));
		bar.x = bx;
		bar.y = by;
		addChild(bar);
		bx += 6;
		by--;

		y = -height;
		visible = false;
		alpha = 0;
	}

	/**
	 * This function just updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		if (_timer > 0)
		{
			_timer -= MS / 1000;
			if (_timer < 1)
			{
				alpha = _timer;
				if (alpha == 0)
				{
					visible = false;
					active = false;
				}
			}
		}
		bar.width = FlxMath.lerp(bar.width, FlxG.sound.muted ? 0 : FlxG.sound.volume * 60, 0.02);
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	public function show(up:Bool = false):Void
	{
		if (!silent)
		{
			var sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 2;
		FlxTween.tween(this, {alpha: 1}, 0.25);
		y = 0;
		visible = true;
		active = true;
	}

	public function screenCenter():Void // Calling it screenCenter because FlxGame requires that
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x;
	}
}
#end
