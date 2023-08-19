package;

import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxG;
import gameplay.SongState;
import flixel.tweens.FlxTween;
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

class QLua
{
	public static var lua:State = null;
	public var scriptName:String = '';

	public function new(script:String)
	{
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		try
		{
			var result:Dynamic = LuaL.dofile(lua, script);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0)
			{
				trace('Lua script encountered an error! ' + resultStr);
				lua = null;
				return;
			}
		}
		catch (e:Dynamic)
		{
			trace(e);
			return;
		}
		scriptName = script;

		set('scrollSpeed', Preferences.scrollSpeed);
		set('downscroll', Preferences.downscroll);
		set('curBeat', SongState.curBeat);
		set('curStep', SongState.curStep);

		Lua_helper.add_callback(lua, "strumTween", function(id:Int, variable:String, value:Dynamic, duration:Float, ease:String)
		{
			SongState.instance.strumTween(id, variable, value, duration, ease);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(color:String, duration:Float)
		{
			switch (color.toLowerCase())
			{
				case "red":
					FlxG.camera.flash(FlxColor.RED, duration);
				case "orange":
					FlxG.camera.flash(FlxColor.ORANGE, duration);
				case "yellow":
					FlxG.camera.flash(FlxColor.YELLOW, duration);
				case "green":
					FlxG.camera.flash(FlxColor.GREEN, duration);
				case "lime":
					FlxG.camera.flash(FlxColor.LIME, duration);
				case "cyan":
					FlxG.camera.flash(FlxColor.CYAN, duration);
				case "blue":
					FlxG.camera.flash(FlxColor.BLUE, duration);
				case "purple":
					FlxG.camera.flash(FlxColor.PURPLE, duration);
				case "magenta":
					FlxG.camera.flash(FlxColor.MAGENTA, duration);
				case "pink":
					FlxG.camera.flash(FlxColor.PINK, duration);
				case "white":
					FlxG.camera.flash(FlxColor.WHITE, duration);
				case "gray":
					FlxG.camera.flash(FlxColor.GRAY, duration);
				case "brown":
					FlxG.camera.flash(FlxColor.BROWN, duration);
				case "black":
					FlxG.camera.flash(FlxColor.BLACK, duration);
			}
		});
		call('create', []);
	}

	/*public static function beatHit() fix one day.
		{
			call('beatHit', []);
		}*/

	static public function call(theFunction:String, theArguments:Array<Dynamic>):Dynamic { 
		Lua.getglobal(lua, theFunction);
		Lua.call(lua, theArguments.length, 1);
		return 0;
	}

	static function typeToString(type:Int):String {
		#if cpp
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		#end
		return "unknown";
	}

	public function set(variable:String, data:Dynamic)
	{
		if (lua == null)
		{
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}
}
