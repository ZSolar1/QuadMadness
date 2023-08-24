package;

import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
import QMAssets.QMAssets;
import sys.io.File;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import openfl.Lib;
import openfl.filters.BitmapFilter;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.BitmapFilterShader;
import openfl.filters.BitmapFilterType;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ConvolutionFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.filters.ShaderFilter;

class QHscript
{
	static var hscriptParser:Parser;
	static var hscriptInterp:Interp;
	static var theHxArray:Array<String> = [];
	static var allHx:Array<String> = [];

	public static function loadModdedHScript(theSong:String, type:String)
		{
			hscriptParser = new hscript.Parser();
			hscriptInterp = new hscript.Interp();
			switch (type.toLowerCase())
			{
			case "fnf":
				if (QMAssets.exists('mods/fnf/$theSong/hscript'))
					{
						allHx = QMAssets.readModDirectory('fnf/$theSong/hscript');
						//trace(allHx);
						for (hscripts in allHx)
						{
							if (StringTools.endsWith(hscripts, '.hx'))
								theHxArray.push('mods/fnf/$theSong/hscript/$hscripts');
						}
					}else{
						return;
					}
			case "mania":
				if (QMAssets.exists('mods/mania/$theSong/hscript'))
					{
						allHx = QMAssets.readModDirectory('mania/$theSong/hscript');
						//trace(allHx);
						for (hscripts in allHx)
						{
							if (StringTools.endsWith(hscripts, '.hx'))
								theHxArray.push('mods/mania/$theSong/hscript/$hscripts');
						}
					}else{
						return;
					}
				}

				hscriptInterp.variables.set("Math", Math); //UGHHHUUUUGH. THIS TOOK WAY TOO LONG TO SETUPP *sobbing*
				hscriptInterp.variables.set("StringTools", StringTools);
				hscriptInterp.variables.set("Array", Array);
				hscriptInterp.variables.set("Xml", Xml);
				hscriptInterp.variables.set("haxe", {
					"Json": haxe.Json,
					"Serializer": haxe.Serializer,
					"Unserializer": haxe.Unserializer
				});

				/*hscriptInterp.variables.set("flixel", {
					//"FlxColor": flixel.util.FlxColor,
					"FlxSprite": flixel.FlxSprite,
					"FlxEase": flixel.tweens.FlxEase,
					"FlxTween": flixel.tweens.FlxTween,
					"FlxText": flixel.text.FlxText,
					"FlxG": flixel.FlxG,
					"FlxBackdrop": flixel.addons.display.FlxBackdrop,
					"FlxCamera": flixel.FlxCamera
				});
				hscriptInterp.variables.set("openfl", {
					"Lib": openfl.Lib,
					"BitmapFilter": openfl.filters.BitmapFilter,
					//"BitmapFilterQuality": openfl.filters.BitmapFilterQuality,
					"BitmapFilterShader": openfl.filters.BitmapFilterShader,
					//"BitmapFilterType": openfl.filters.BitmapFilterType,
					"BlurFilter": openfl.filters.BlurFilter,
					"ColorMatrixFilter": openfl.filters.ColorMatrixFilter,
					"ConvolutionFilter": openfl.filters.ConvolutionFilter,
					"DropShadowFilter": openfl.filters.DropShadowFilter,
					"GlowFilter": openfl.filters.GlowFilter,
					"ShaderFilter": openfl.filters.ShaderFilter
				});*/

				//Flixel shit
				hscriptInterp.variables.set("FlxG", flixel.FlxG);
				hscriptInterp.variables.set("FlxSprite", flixel.FlxSprite);
				hscriptInterp.variables.set("FlxEase", flixel.tweens.FlxEase);
				hscriptInterp.variables.set("FlxTween", flixel.tweens.FlxTween);
				hscriptInterp.variables.set("FlxText", flixel.text.FlxText);
				hscriptInterp.variables.set("FlxBackdrop", flixel.addons.display.FlxBackdrop);
				hscriptInterp.variables.set("FlxCamera", flixel.FlxCamera);
				
				//OpenFL shit
				hscriptInterp.variables.set("Lib", openfl.Lib);
				hscriptInterp.variables.set("BitmapFilter", openfl.filters.BitmapFilter);
				hscriptInterp.variables.set("BitmapFilterShader", openfl.filters.BitmapFilterShader);
				hscriptInterp.variables.set("BlurFilter", openfl.filters.BlurFilter);
				hscriptInterp.variables.set("ColorMatrixFilter", openfl.filters.ColorMatrixFilter);
				hscriptInterp.variables.set("ConvolutionFilter", openfl.filters.ConvolutionFilter);
				hscriptInterp.variables.set("DropShadowFilter", openfl.filters.DropShadowFilter);
				hscriptInterp.variables.set("GlowFilter", openfl.filters.GlowFilter);
				hscriptInterp.variables.set("ShaderFilter", openfl.filters.ShaderFilter);

				if (theHxArray != [])
					{
				for (i in 0...theHxArray.length)
					{
						var scriptToParse = hscriptParser.parseString(sys.io.File.getContent(theHxArray[i]));
						trace(hscriptInterp.execute(scriptToParse));
						trace(theHxArray[i]);
					}
				}
				//callHscript("create", []);
		}

		public static function callHscript(functionName:String, args:Array<Dynamic>)
			{
				
				var method = hscriptInterp.variables.get(functionName);
				if (method == null) {return null;}

				var _ret = Reflect.callMethod(hscriptInterp, method, args); //Line 141.
				return _ret;
			}
}