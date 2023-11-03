package;

import haxe.Exception;
import states.CrashHandlerState;
#if cpp
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

class QMDiscordRpc
{
	#if cpp
	public static var isInitialized:Bool = false;

	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1052553282377224212",
			onReady: onReady,
			onError: function(_code:Int, _message:String)
			{
				new Exception('QMDiscordRPC: $_code : $_message');
			},
			onDisconnected: null
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "Launched the game",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Quad Madness"
		});
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new QMDiscordRpc();
		});
		trace("QMDiscordRpc initialized");
		isInitialized = true;
	}

	public static function changeStatus(details:String, state:Null<String>, ?smallImageKey:String)
	{
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			smallImageKey: smallImageKey,
		});

	}
	#else
	public function new()
		trace("Can't start Discord Client, user is on a non-cpp platform.");

	public static function shutdown()
		trace("Can't shutdown Discord Client, user is on a non-cpp platform.");

	static function onReady()
		trace("Can't call onReady in Discord Client, user is on a non-cpp platform.");

	public static function initialize()
		trace("Can't initialize Discord Client, user is on a non-cpp platform.");

	public static function changeStatus(details:String, state:Null<String>, ?smallImageKey:String)
		trace("Can't change presence on Discord Client, user is on a non-cpp platform.");
	#end

}
