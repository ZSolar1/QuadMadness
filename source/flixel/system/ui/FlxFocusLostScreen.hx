package flixel.system.ui;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFormatAlign;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flash.display.Sprite;
import flixel.FlxG;
import flixel.system.FlxAssets;

class FlxFocusLostScreen extends Sprite
{
	var _width = 80;
	var _height = 40;
	var _defaultScale = 1.5;

	@:keep
	public function new()
	{
		super();
		draw();

		var logo:Sprite = new Sprite();
		FlxAssets.drawLogo(logo.graphics);
		logo.scaleX = logo.scaleY = 0.2;
		logo.x = logo.y = 5;
		logo.alpha = 0.35;
		addChild(logo);

		var tmp:Bitmap = new Bitmap(new BitmapData(_width, _height, false, 0xFFFFFF));
		var outline:Bitmap = new Bitmap(new BitmapData(_width + 8, _height + 8, false, 0x000000));
		outline.x -= 4;
		outline.y -= 4;
		addChild(outline);
		addChild(tmp);

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		x = (0.5 * (Lib.current.width - _width * _defaultScale) - FlxG.game.x);
		y = (0.5 * (Lib.current.height - _height * _defaultScale) - FlxG.game.y);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		var dtf:TextFormat = new TextFormat(Fonts.NotoSans.Light, 14, 0x000000);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "Pause";
		text.y = 8;
	}

	/**
	 * Redraws the big arrow on the focus lost screen.
	 */
	public function draw():Void {}
}
