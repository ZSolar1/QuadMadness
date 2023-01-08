package gameplay;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class NoteParticle extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic(Paths.ImagePath('gameplay/notes.png'), true, 256, 256);
		animation.frameIndex = 1;
		antialiasing = true;
		scale.set(0.5, 0.5);
		updateHitbox();
		FlxTween.tween(this, {"scale.x": 0.75, "scale.y": 0.75, "alpha": 0}, 0.35, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				kill();
			}
		});
	}
}
