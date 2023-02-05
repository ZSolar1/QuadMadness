package states;

import flixel.util.FlxTimer;
import Fonts.NotoSans;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class IntroState extends FlxState
{
	var title:FlxText;
	var subtitle:FlxText;
	var pressanykey:FlxText;

	override public function create()
	{
		super.create();

		FlxSprite.defaultAntialiasing = true;

		#if desktop
		FlxG.mouse.load(new FlxSprite().loadGraphic('assets/images/cursor.png').pixels);
		#end
		// FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode(true);

		title = new FlxText(0, FlxG.height / 2 - 40, FlxG.width, "This is Quad Madness", 28);
		subtitle = new FlxText(0, FlxG.height / 2 + 10, FlxG.width, "A free 4k VSRG game, in development", 20);
		pressanykey = new FlxText(0, FlxG.height - 96, FlxG.width, "Press ENTER / Click to continue", 20);

		title.antialiasing = true;
		subtitle.antialiasing = true;
		pressanykey.antialiasing = true;

		title.alpha = 0;
		subtitle.alpha = 0;
		pressanykey.alpha = 0;

		title.alignment = CENTER;
		subtitle.alignment = CENTER;
		pressanykey.alignment = CENTER;

		title.setFormat(NotoSans.Medium, 28);
		subtitle.setFormat(NotoSans.Light, 20);
		pressanykey.setFormat(NotoSans.Light, 24);

		add(title);
		add(subtitle);
		add(pressanykey);

		FlxTween.tween(title, {alpha: 1}, 1.5);

		new FlxTimer().start(0.5, function(tmr)
		{
			FlxTween.tween(subtitle, {alpha: 1}, 1.5);
		});

		new FlxTimer().start(5, function(tmr)
		{
			FlxTween.tween(pressanykey, {alpha: 1}, 1.5);
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		// if (FlxG.keys.justPressed.F7)
		// 	FlxG.switchState(new DebugStrumsState());

		if (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed)
		{
			FlxTween.cancelTweensOf(title);
			FlxTween.cancelTweensOf(subtitle);
			FlxTween.cancelTweensOf(pressanykey);
			FlxTween.tween(title, {alpha: 0}, 1.5);
			FlxTween.tween(subtitle, {alpha: 0}, 1.5);
			FlxTween.tween(pressanykey, {alpha: 0}, 1.5);

			new FlxTimer().start(2, function(tmr)
			{
				FlxG.switchState(new MenuState());
			});
		}
	}
}
