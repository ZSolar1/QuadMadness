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

class QLua extends FlxState
{
	public static var lua:State = null;
	public var scriptName:String = '';

	public function new(script:String, isMania:Bool)
	{
		super();
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

		if (!isMania)
			{
		set('scrollSpeed', Preferences.scrollSpeed);
		set('downscroll', Preferences.downscroll);
		set('curBeat', SongState.curBeat);
		set('curStep', SongState.curStep);

		Lua_helper.add_callback(lua, "strumTween", function(id:Int, variable:String, value:Dynamic, duration:Float, ease:String)
		{
			SongState.instance.strumTween(id, variable, value, duration, ease);
		});

		Lua_helper.add_callback(lua, "cameraFlash", function(color:String, duritation:Float){ //bruhh istg there is a better way to do this
			if (color == "red" || color == "Red" || color == "RED")
				FlxG.camera.flash(FlxColor.RED, duritation);

			if (color == "orange" || color == "Orange" || color == "ORANGE")
				FlxG.camera.flash(FlxColor.ORANGE, duritation);

			if (color == "yellow" || color == "Yellow" || color == "YELLOW")
				FlxG.camera.flash(FlxColor.YELLOW, duritation);

			if (color == "green" || color == "Green" || color == "GREEN")
				FlxG.camera.flash(FlxColor.GREEN, duritation);

			if (color == "lime" || color == "Lime" || color == "LIME")
				FlxG.camera.flash(FlxColor.LIME, duritation);

			if (color == "cyan" || color == "Cyan" || color == "CYAN")
				FlxG.camera.flash(FlxColor.CYAN, duritation);

			if (color == "blue" || color == "Blue" || color == "BLUE")
				FlxG.camera.flash(FlxColor.BLUE, duritation);

			if (color == "purple" || color == "Purple" || color == "PURPLE")
				FlxG.camera.flash(FlxColor.PURPLE, duritation);

			if (color == "magenta" || color == "Magenta" || color == "MAGENTA")
				FlxG.camera.flash(FlxColor.MAGENTA, duritation);

			if (color == "pink" || color == "Pink" || color == "PINK")
				FlxG.camera.flash(FlxColor.PINK, duritation);

			if (color == "white" || color == "White" || color == "WHITE")
				FlxG.camera.flash(FlxColor.WHITE, duritation);

			if (color == "gray" || color == "Gray" || color == "GRAY")
				FlxG.camera.flash(FlxColor.GRAY, duritation);

			if (color == "brown" || color == "Brown" || color == "BROWN")
				FlxG.camera.flash(FlxColor.BROWN, duritation);

			if (color == "black" || color == "Black" || color == "BLACK")
				FlxG.camera.flash(FlxColor.BLACK, duritation);
		});
		call('create', []);
		}else{
			trace("Mania charts don't have lua support yet!!");
		}
	}

	/*public static function beatHit() I'll fix this one day.
		{
			call('beatHit', []);
		}*/

	public function call(theFunction:String, theArguments:Array<Dynamic>):Dynamic { 
		Lua.getglobal(lua, theFunction);
		Lua.call(lua, theArguments.length, 1);
		return 0;
	}

<<<<<<< Updated upstream
	static function typeToString(type:Int):String {
		#if LUA_ALLOWED
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

=======
>>>>>>> Stashed changes
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
