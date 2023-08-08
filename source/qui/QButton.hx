package qui;

import flixel.group.FlxSpriteGroup;

class QButton extends FlxSpriteGroup
{
	var text:String;

	public function new(x:Float, y:Float, text:String)
	{
		super(x, y);
		this.text = text;
	}
}
