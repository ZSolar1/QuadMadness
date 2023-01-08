package;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class QButton extends QBase
{
	public var icon:FlxSprite;

	public function new(x:Float, y:Float, width:Int, icon:String)
	{
		super(x, y);
		this.icon = new FlxSprite(this.x + 64, this.y + 64).loadGraphic(Paths.ImagePath('menu/buttons/' + icon + '.png'));
		loadGraphic(Paths.ImagePath('menu/qbutton.png'));
		this.icon.scale.x = 0.75;
		this.icon.scale.y = 0.75;
		this.icon.antialiasing = true;
		antialiasing = true;
	}

	public function dissapear()
	{
		FlxTween.tween(icon, {"scale.x": 1, "scale.y": 1, alpha: 0}, 0.35, {ease: FlxEase.quadOut});
		FlxTween.tween(this, {"scale.x": 0.75, "scale.y": 0.75, alpha: 0}, 0.45, {ease: FlxEase.quadOut});
	}

	public function fade()
	{
		FlxTween.tween(icon, {alpha: 0}, 0.3, {ease: FlxEase.quadOut});
		FlxTween.tween(this, {alpha: 0}, 0.3, {ease: FlxEase.quadOut});
	}

	public function click()
	{
		dissapear();
		new FlxTimer().start(0.5, function(tmr)
		{
			appear();
		});
	}

	public function appear()
	{
		icon.alpha = 0;
		icon.scale.x = 0;
		icon.scale.y = 0;

		alpha = 0;
		scale.x = 0;
		scale.y = 0;
		FlxTween.tween(this, {"scale.x": 1, "scale.y": 1, alpha: 1}, 0.45, {ease: FlxEase.quadOut});
		FlxTween.tween(icon, {"scale.x": 0.75, "scale.y": 0.75, alpha: 1}, 0.35, {ease: FlxEase.quadOut});
	}
}
