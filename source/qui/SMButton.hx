package qui;

import flixel.group.FlxSpriteGroup;

class SMButton extends FlxSpriteGroup
{
	var text:String;

	public function new(x:Float, y:Float, text:String)
	{
		super(x, y);
		this.text = text;
	}
}
