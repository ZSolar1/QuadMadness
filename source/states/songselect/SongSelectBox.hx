package states.songselect;

import flixel.text.FlxText;

class SongSelectBox extends FlxText
{
	public var songName:String;

	public function new(songName:String)
	{
		super(0, 0);
		this.songName = songName;
	}
}
