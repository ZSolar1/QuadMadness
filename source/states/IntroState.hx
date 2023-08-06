package states;

import skin.SkinLoader;
#if MULTIPLAYER_TEST
import openfl.net.Socket;
import openfl.events.ServerSocketConnectEvent;
#end
import flixel.util.FlxTimer;
import Fonts.NotoSans;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
#if mobile
import flixel.input.touch.FlxTouch;
import flixel.input.touch.FlxTouchManager;
#end

class IntroState extends FlxState
{
	var quads:Array<FlxSprite> = [];

	override function onResize(Width:Int, Height:Int)
	{
		super.onResize(Width, Height);
		resizeSprites();
	}

	function resizeSprites()
	{

	}

	override public function create()
	{
		super.create();
		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true;

		#if desktop
		FlxG.mouse.load(new FlxSprite().loadGraphic('assets/images/cursor.png').pixels);
		#end
		#if MULTIPLAYER_TEST
		var socket = new Socket();
		socket.addEventListener(ServerSocketConnectEvent.CONNECT, function(listener)
		{
			trace("Connected to game server successfully");
			trace(socket.bytesAvailable);

			socket.writeUTFBytes("QMClient");
			socket.flush();
		});
		socket.connect("127.0.0.1", 25564);
		#end

		FlxG.scaleMode = new flixel.system.scaleModes.StageSizeScaleMode();

		var positions:Array<Array<Float>> = [[0.0, 128.0], [128.0, 0.0], [256.0, 128.0], [128.0, 256.0]];

		new FlxTimer().start(0.5, function(tmr)
		{
			for (i in 0...4)
			{
				new FlxTimer().start(1 + i / 2, function(tmr)
				{
					var quad = new FlxSprite(FlxG.width / 2 - 256, FlxG.height / 2 - 256);
					quad.loadGraphic(SkinLoader.getSkinnedImage('gameplay/notes.png'), true, 256, 256);
					quad.animation.frameIndex = 0;
					quad.x += positions[i][0];
					quad.y += positions[i][1];
					quad.scale.set(0.75, 0.75);
					quad.alpha = 0;
					FlxTween.tween(quad, {alpha: 1,}, 1);
					quads.push(quad);
					add(quad);
				});
			}
		});

		new FlxTimer().start(4.5, function(tmr)
		{
			FlxG.camera.fade(0xFFFFFFFF, 0.25);
			new FlxTimer().start(0.75, function(tmr)
			{
				FlxG.switchState(new MenuState());
			});
		});

		resizeSprites();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		// if (FlxG.keys.justPressed.F7)
		// 	FlxG.switchState(new DebugStrumsState());
	}
}
