package states;

import states.debug.DebugStrumsState;
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

class IntroState extends BPMState
{
	var quads:Array<FlxSprite> = [];
	var positions:Array<Array<Float>> = [[0.0, 128.0], [128.0, 0.0], [256.0, 128.0], [128.0, 256.0]];
	var skipText:FlxText;
	public static var cameFromIntro:Bool = true;

	override function onResize(Width:Int, Height:Int)
	{
		super.onResize(Width, Height);
		resizeSprites();
	}

	function resizeSprites()
	{

	}

	function init(){
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
		if (FlxG.save.data.curFNFSongSelected == null)
			FlxG.save.data.curFNFSongSelected = 0;
		FlxG.scaleMode = new flixel.system.scaleModes.StageSizeScaleMode();
		bpm = 180;
		updateCrochet();
		FlxG.sound.playMusic('assets/music/menu.ogg', 1, true);
	}

	override public function create()
	{
		super.create();
		init();
		skipText = new FlxText(0, 650, FlxG.width, 'Press ENTER To Skip', 30);
		skipText.alignment = CENTER;
		skipText.screenCenter(X);
		skipText.font = Fonts.NotoSans.Light;
		add(skipText);
		var quad = new FlxSprite(FlxG.width / 2 - 256, FlxG.height / 2 - 256);
		quad.loadGraphic(SkinLoader.getSkinnedImage('gameplay/notes.png'), true, 256, 256);
		quad.animation.frameIndex = 0;
		quad.x += positions[0][0];
		quad.y += positions[0][1];
		quad.scale.set(0.75, 0.75);
		quad.alpha = 0;
		FlxTween.tween(quad, {alpha: 1}, (crochet/1000) * 8);
		quads.push(quad);
		add(quad);
		resizeSprites();
	}

	override public function beatHit(){
		if (curBeat < 32 && curBeat % 8 == 0){
			trace(curBeat);
				var quad = new FlxSprite(FlxG.width / 2 - 256, FlxG.height / 2 - 256);
				quad.loadGraphic(SkinLoader.getSkinnedImage('gameplay/notes.png'), true, 256, 256);
				quad.animation.frameIndex = 0;
				quad.x += positions[(Std.int(curBeat/8))][0];
				quad.y += positions[(Std.int(curBeat/8))][1];
				quad.scale.set(0.75, 0.75);
				quad.alpha = 0;
				FlxTween.tween(quad, {alpha: 1}, (crochet/1000) * 8);
				quads.push(quad);
				add(quad);
		}
		if (curBeat == 32){
			FlxG.camera.fade(0xFFFFFFFF, (crochet/1000) * 8);
			new FlxTimer().start((crochet/1000) * 8, function(tmr)
			{
				FlxG.switchState(new MenuState());
			});
		}
		if (curBeat == 8){
			FlxTween.tween(skipText, {alpha: 0}, (crochet/1000)*8);
		}
		resizeSprites();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.F7)
			FlxG.switchState(new DebugStrumsState());
		if (FlxG.keys.justPressed.ENTER) //Skip the entro if it's too long
		 	FlxG.switchState(new MenuState());
	}
}
