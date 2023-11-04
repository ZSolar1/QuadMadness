package;

import qui.QSoundTray;
import flixel.FlxState;
import SongSaveData.Scores;
import states.CrashHandlerState;
import openfl.events.Event;
import haxe.CallStack;
import lime.system.System;
import flixel.util.FlxTimer;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import openfl.events.UncaughtErrorEvent;
import flixel.FlxG;
import openfl.Lib;
import lime.app.Application;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.IntroState;

using StringTools;

class QMGame extends FlxGame
{
	var message:String;
	var stack:CallStack;
	public function new(gameWidth = 0, gameHeight = 0, ?initialState:Class<FlxState>, updateFramerate = 60, drawFramerate = 60, skipSplash = false,
			startFullscreen = false)
	{
		super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);

		_customSoundTray = QSoundTray;
	}
	
	override function create(_:Event)
	{
		message = "";
		stack = null;
		try
		{
			super.create(_);
			FlxG.fixedTimestep = false;
		}
		catch (e)
		{
			new FlxTimer().start(1.0, crashHandler, 1);
			message = e.message;
			stack = e.stack;
		}
	}

	override function draw()
	{
		try
		{
			super.draw();
		}
		catch (e)
		{
			new FlxTimer().start(1.0, crashHandler, 1);
			message = e.message;
			stack = e.stack;
		}
	}

	override function update()
	{
		try
		{
			super.update();
		}
		catch (e)
		{
			
			new FlxTimer().start(1.0, crashHandler, 1);
			message = e.message;
			stack = e.stack;
			trace('got a crash: ${e.message}');
			
		}
	}
	function crashHandler(timer:FlxTimer):Void
	{
		FlxG.switchState(new CrashHandlerState(message, stack));
	}
}

class Main extends Sprite
{
	public function new()
	{
		super();
		// Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		var game = {
			width: 0,
			height: 0,
			initialState: IntroState,
			updateFramerate: 144,
			drawFramerate: 144,
			skipSplash: true
		};

		Preferences.loadPrefs();
		Scores.loadSavedScores();
		Globals.version = Lib.application.meta.get('version');

		#if desktop
		if (!QMDiscordRpc.isInitialized)
		{
			QMDiscordRpc.initialize();
			Application.current.window.onClose.add(function()
			{
				QMDiscordRpc.shutdown();
			});
		}
		#end
		addChild(new QMGame(game.width, game.height, game.initialState, game.updateFramerate, game.drawFramerate, game.skipSplash));
		addChild(new FpsMem(2, 2, 0xFFFFFF));
		FlxG.maxElapsed = Math.POSITIVE_INFINITY;
	};

	function onCrash(e:UncaughtErrorEvent)
	{
		// QMDiscordRpc.shutdown();
		var curDate = Date.now().toString();
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		curDate = curDate.replace(" ", "_").replace(":", "'");

		#if sys
		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');
		#end

		var errMsg:String = "Uncaught Error:\n";
		errMsg += "Call Stack that lead to this event:\n";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += '\n${e.error}\n';

		// Crash message itself
		Lib.application.window.alert(errMsg, "Uncaught Error!");
		#if sys
		File.saveContent('./crash/QM_$curDate.txt', errMsg);
		#end
		System.exit(1);
	}
}
