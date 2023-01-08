package;

import gameplay.SongState;
import flixel.tweens.FlxTween;
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

class QLua
{
	public var lua:State = null;
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

		Lua_helper.add_callback(lua, "strumTween", function(id:Int, variable:String, value:Dynamic, duration:Float, ease:String)
		{
			SongState.instance.strumTween(id, variable, value, duration, ease);
		});
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
