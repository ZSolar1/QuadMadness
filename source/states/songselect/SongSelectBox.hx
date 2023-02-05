package states.songselect;

import flixel.FlxG;
import flixel.text.FlxText;

class SongSelectBox extends FlxText
{
	public var baseX:Int;
	public var songName:String;

	public function new(x:Int, songName:String)
	{
		super(0, 0);
		baseX = x;
		this.x = baseX;
		this.songName = songName;
		loadGraphic('assets/images/menu/songbox.png');
	}

	override function draw()
	{
		super.draw();
		x = baseX + (y / FlxG.height) * 128;
	}
}
