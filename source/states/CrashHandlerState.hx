package states;

import openfl.system.System;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
import haxe.CallStack;

class CrashHandlerState extends FlxState
{
	var messageText:String;
	var callStack:CallStack;

	var background:FlxSprite;
	var error:FlxText;
	var errorMessage:FlxText;
	var callStackMessage:FlxText;
	var buttonMsg:FlxText;

	public function new(message:String, stack:CallStack)
	{
		super();
		messageText = message;
		callStack = stack;
	}

	function constructCallStack():String
	{
		var callStackText:String = "";
		if (callStack != null)
			{
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					callStackText += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
			Sys.println(stackItem);
		}
		return callStackText;
	}else{
		return "";
	}
	}

	override function create()
	{
		super.create();
		background = new FlxSprite(0, 0).loadGraphic('assets/images/menu/background.png');
		background.alpha = 0;
		background.color = 0xFF333333;
		add(background);

		error = new FlxText(0, 10, FlxG.width, 'Damn!');
		error.setFormat(Fonts.NotoSans.Regular, 48, 0xFF4444, CENTER);
		add(error);
		error.alpha = 0;
		error.y = -error.height;

		errorMessage = new FlxText(FlxG.width / 2, FlxG.height / 2, FlxG.width / 2, 'Here\'s the error:\n$messageText');
		errorMessage.setFormat(Fonts.NotoSans.Light, 24, 0xFFFFFF, CENTER);
		add(errorMessage);
		errorMessage.alpha = 0;
		errorMessage.y = FlxG.height / 2 - 30;

		callStackMessage = new FlxText(0, FlxG.height / 2, FlxG.width / 2, 'Call Stack:\n${constructCallStack()}');
		callStackMessage.setFormat(Fonts.NotoSans.Light, 24, 0xFFFFFF, CENTER);
		add(callStackMessage);
		callStackMessage.alpha = 0;
		callStackMessage.y = -20;

		buttonMsg = new FlxText(0, FlxG.height - 50, FlxG.width, 'Press R to reset | Press Esc to exit');
		buttonMsg.setFormat(Fonts.NotoSans.Light, 24, 0xFFFFFF, CENTER);
		add(buttonMsg);
		buttonMsg.alpha = 0;

		if (callStackMessage.text == 'Call Stack:\n')
		{
			remove(callStackMessage);
			errorMessage.fieldWidth = 1000;
			errorMessage.screenCenter(X);
		}

		new FlxTimer().start(1, function(tmr)
		{
			switch (tmr.loopsLeft)
			{
				case 3:
					FlxTween.tween(background, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
				case 2:
					FlxTween.tween(error, {y: 10, alpha: 1}, 1, {ease: FlxEase.cubeOut});
				case 1:
					if (errorMessage.fieldWidth != 1000)
						{
					FlxTween.tween(errorMessage, {y: FlxG.height / 2, alpha: 1}, 1, {ease: FlxEase.cubeOut});
						}else{
							FlxTween.tween(errorMessage, {y: (FlxG.height - errorMessage.height) / 2, alpha: 1}, 1, {ease: FlxEase.cubeOut});
						}
					FlxTween.tween(callStackMessage, {y: FlxG.height / 2 - callStackMessage.height / 2, alpha: 1}, 1, {ease: FlxEase.cubeOut});
					FlxTween.tween(buttonMsg, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
			}
		}, 4);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxTween.tween(background, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(error, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(errorMessage, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(callStackMessage, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(buttonMsg, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			new FlxTimer().start(0.5, function(tmr)
			{
				System.exit(1);
			});
		}
		if (FlxG.keys.justPressed.R)
		{
			FlxTween.tween(background, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(error, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(errorMessage, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(callStackMessage, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			FlxTween.tween(buttonMsg, {alpha: 0}, 0.25, {ease: FlxEase.cubeOut});
			new FlxTimer().start(0.5, function(tmr)
			{
				FlxG.resetGame();
			});
		}
	}
}
