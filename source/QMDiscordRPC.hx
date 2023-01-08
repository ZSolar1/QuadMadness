package;

#if cpp
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

class QMDiscordRPC
{
	// Copied from Psych Engine
	// https://github.com/ShadowMario/FNF-PsychEngine
	public static var isInitialized:Bool = false;

	public function new()
	{
		#if cpp
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1052553282377224212",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#else
		trace("Can't start Discord Client, user is on a non-cpp platform.");
		#end
	}

	public static function shutdown()
	{
		#if cpp
		DiscordRpc.shutdown();
		#else
		trace("Can't shutdown Discord Client, user is on a non-cpp platform.");
		#end
	}

	static function onReady()
	{
		#if cpp
		DiscordRpc.presence({
			details: "Launched the game",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Quad Madness"
		});
		#else
		trace("Can't call onReady in Discord Client, user is on a non-cpp platform.");
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		#if cpp
		trace('Error! $_code : $_message');
		#else
		trace("Can't call onError in Discord Client, user is on a non-cpp platform.");
		#end
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		#if cpp
		trace('Disconnected! $_code : $_message');
		#else
		trace("Can't call onDisconnected in Discord Client, user is on a non-cpp platform.");
		#end
	}

	public static function initialize()
	{
		#if cpp
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new QMDiscordRPC();
		});
		trace("QMDiscordRPC initialized");
		isInitialized = true;
		#else
		trace("Can't initialize Discord Client, user is on a non-cpp platform.");
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		#if cpp
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			// largeImageText: "Engine Version: " + ,
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		#else
		trace("Can't change presence on Discord Client, user is on a non-cpp platform.");
		#end
	}
}
