package states.songselect;

import skin.SkinLoader;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;

using StringTools;

class SongSelectBox extends FlxSpriteGroup
{
	public var baseX:Int;
	public var songName:String;
	public var id:Int;

	var _height = 0.0;

	var prevY:Float = 0;
	var text:FlxText;
	var box:FlxSprite;

	public var listed:Bool = true;

	public function new(x:Int, songName:String, id:Int)
	{
		super(0, 0);
		text = new FlxText(0, 0);
		box = new FlxSprite(0, 0);
		baseX = x;
		this.x = baseX;
		this.songName = songName;
		this.id = id;
		text.setFormat(Fonts.NotoSans.Light, 40, 0x000000);
		text.text = FlxStringUtil.toTitleCase(songName.replace('-', ' '));
		box.loadGraphic(SkinLoader.getSkinnedImage('menu/optionbox.png'));
		_height = box.height;
		y += id * _height;
		add(box);
		add(text);
	}

	public function mirrorBox()
	{
		box.flipX = !box.flipX;
	}

	override function draw()
	{
		super.draw();
		if (listed)
			x = FlxMath.lerp(x, baseX + Math.abs(y / FlxG.height * 2 - 1) * 128, 0.02);
		text.x = x + 60;
		text.y = y + 45;
	}
}
