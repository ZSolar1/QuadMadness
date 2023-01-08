package gameplay;

import skin.SkinLoader;
import flixel.FlxSprite;

class Note extends FlxSprite
{
	public var strumTime:Float;
	public var direction:Int;
	public var sustainLength:Float;
	public var isSustain:Bool;
	public var isSustainEnd:Bool = false;
	public var late:Bool = false;
	public var canBeHit:Bool = false;

	public function new(strumTime:Float, direction:Int, sustainLength:Float, isSustain:Bool = false)
	{
		super();
		this.strumTime = strumTime;
		this.direction = direction;
		this.sustainLength = sustainLength;
		this.isSustain = isSustain;

		y -= 2000;

		loadGraphic(SkinLoader.getSkinnedImage('gameplay/notes.png'), true, 256, 256);
		if (!isSustain)
			animation.frameIndex = 2;
		else
			animation.frameIndex = 3;
		antialiasing = true;
		scale.set(0.5, 0.5);
		updateHitbox();
	}
}
