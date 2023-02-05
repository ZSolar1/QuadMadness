package states.songselect;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.text.FlxText;

class SongSelectBox extends FlxText
{
	public var baseX:Int;
	public var songName:String;
	public var id:Int;

	var prevY:Float = 0;

	public function new(x:Int, songName:String, id:Int)
	{
		super(0, 0);
		baseX = x;
		this.x = baseX;
		this.songName = songName;
		this.id = id;
		loadGraphic('assets/images/menu/songbox.png');
		y += id * height;
	}

	override function draw()
	{
		super.draw();
		x = baseX + Math.abs(y / FlxG.height * 2 - 1) * 128;
	}
}
