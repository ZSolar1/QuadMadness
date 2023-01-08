package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class ParallaxSprite extends FlxSprite
{
	var parallaxLimit:Float;
	var baseX:Float;
	var baseY:Float;

	public var parallaxed:Bool = true;

	public function new(x:Float, y:Float, parallaxLimit:Float)
	{
		baseX = x;
		baseY = y;
		super(x, y);
		this.parallaxLimit = parallaxLimit;
	}

	public function centerPos()
	{
		baseX -= width / 2;
		baseY -= height / 2;
	}

	override function draw()
	{
		super.draw();
		if (parallaxed)
		{
			x = baseX + FlxMath.remapToRange(FlxG.mouse.x, 0, FlxG.width, -parallaxLimit, parallaxLimit);
			y = baseY + FlxMath.remapToRange(FlxG.mouse.y, 0, FlxG.height, -parallaxLimit, parallaxLimit);
		}
	}
}
