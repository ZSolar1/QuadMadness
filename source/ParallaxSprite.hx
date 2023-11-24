package;

import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class ParallaxSprite extends FlxSprite
{
	var parallaxLimit:Float;
	var baseX:Float;
	var baseY:Float;

	public var parallaxAxes:FlxAxes = XY;
	public var parallaxed:Bool = true;

	public function new(x:Float, y:Float, parallaxLimit:Float, ?parallaxAxes:FlxAxes = XY)
	{
		baseX = x;
		baseY = y;
		super(x, y);
		this.parallaxLimit = parallaxLimit;
		this.parallaxAxes = parallaxAxes;
	}

	public function centerPos()
	{
		baseX -= width / 2;
		baseY -= height / 2;
	}

	public function getLimit():Float
	{
		return parallaxLimit;
	}

	public function rebase(x:Float, y:Float)
	{
		baseX = x;
		baseY = y;
	}

	override function draw()
	{
		super.draw();
		#if desktop
		if (parallaxed)
		{
			if (parallaxAxes.x)
				x = baseX + FlxMath.remapToRange(FlxG.mouse.x, 0, FlxG.width, -parallaxLimit, parallaxLimit);
			if (parallaxAxes.y)
				y = baseY + FlxMath.remapToRange(FlxG.mouse.y, 0, FlxG.height, -parallaxLimit, parallaxLimit);
		}
		#end
	}
}
