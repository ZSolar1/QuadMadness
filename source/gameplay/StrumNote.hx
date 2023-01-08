package gameplay;

import skin.SkinLoader;
import flixel.FlxSprite;

class StrumNote extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic(SkinLoader.getSkinnedImage('gameplay/notes.png'), true, 256, 256);
		animation.frameIndex = 0;
		antialiasing = true;
		scale.set(0.5, 0.5);
		updateHitbox();
	}

	public function playAnim(name:String, force:Bool = false)
	{
		switch (name)
		{
			case 'idle':
				animation.frameIndex = 0;
			case 'pressed':
				animation.frameIndex = 1;
		}
	}
}
