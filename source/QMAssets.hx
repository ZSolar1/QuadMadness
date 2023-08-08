package;

import haxe.io.Bytes;
import qmp.QMPackage;
import openfl.utils.ByteArray;

using StringTools;

class QMAssets
{
	private static function createFilePath(path:String, type:String):String
	{
		return 'assets/' + type + '/' + path;
	}

	private static function createModFilePath(game:String, song:String):String
	{
		return 'mods/' + game + '/' + song;
	}

	/**
		Read a file from 'assets/'
	**/
	public static function read(path:String, type:String)
	{
		#if sys
		trace('Reading a file from ${createFilePath(path, type)}');
		return sys.io.File.getContent(createFilePath(path, type));
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		#end
	}

	/**
		Retrieve filenames relative to 'mods/'
	**/
	public static function readModDirectory(path:String)
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/$path');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		#end
	}

	/**
		Retrieve all filenames inside an fnf song folder
	**/
	public static function FNFreadAllDiffs(song:String):Array<String>
	{
		#if sys
		var files = sys.FileSystem.readDirectory('mods/fnf/$song/');
		var chartfiles:Array<String> = new Array<String>();
		for (file in files)
		{
			if (file.endsWith('.json') && file.startsWith('$song'))
			{
				if (file.replace('$song', '').replace('.json', '') != '')
				{
					chartfiles.push(file.replace('$song-', '').replace('.json', ''));
				}
				else
				{
					chartfiles.push('normal');
				}
			}
		}
		return chartfiles;
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Does file exist (relative to exe?)
	**/
	public static function exists(file):Bool
	{
		#if sys
		return sys.FileSystem.exists(file);
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Retrieve all folder names inside fnf songs folder
	**/
	public static function FNFreadAllCharts():Array<String>
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/fnf/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Retrieve all folder names inside osu!mania songs folder
	**/
	public static function OsuReadAllCharts():Array<String>
	{
		#if sys
		trace(sys.FileSystem.readDirectory('mods/mania/'));
		return sys.FileSystem.readDirectory('mods/mania/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Retrieve all filenames inside an fnf song folder
	**/
	public static function OsuReadAllDiffs(song:String):Array<String>
	{
		#if sys
		trace(sys.FileSystem.readDirectory('mods/mania/$song/'));
		return sys.FileSystem.readDirectory('mods/mania/$song/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Retrieve all filenames of '*.qmp' (QM Package) inside 'mods/charts/'
	**/
	public static function readPackagedCharts():Array<String>
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/charts/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Retrieve all filenames inside 'mods/charts/'
	**/
	public static function readNativeCharts():Array<String>
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/charts/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Read packaged chart into a MapChart
	**/
	public static function readChartPackage() {}

	/**
		Write packaged chart into a file
	**/
	public static function writeChartPackage(name:String, data:QMPackage)
	{
		#if sys
		sys.io.File.saveContent('mods/charts/$name.qmp', haxe.Json.stringify(data));
		trace('Writing a packaged chart to \'mods/charts/$name.qmp\'');
		#else
		trace('File writing cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Read a chart from 'mods' folder
	**/
	public static function readModChart(game:String, song:String)
	{
		#if sys
		trace('Reading a file from ${createModFilePath(game, song)}');
		return sys.io.File.getContent(createModFilePath(game, song));
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Write a file to 'assets/'
	**/
	public static function write(path:String, type:String, content:String)
	{
		#if sys
		sys.io.File.saveContent(createFilePath(path, type), content);
		trace('Writing a file to ${createFilePath(path, type)}');
		#else
		trace('File writing cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Write a file to 'mods/charts/'
	**/
	public static function writeChart(name:String, diff:String, content:String)
	{
		#if sys
		sys.io.File.saveBytes(createModFilePath('charts', '$name/$diff'), Bytes.ofString(content));
		trace('Writing a file to ${createModFilePath('charts', '$name/$diff')}');
		#else
		trace('File writing cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Create directory
	**/
	public static function makeDirectory(path:String)
	{
		#if sys
		sys.FileSystem.createDirectory(path);
		trace('Creating a directory "$path"');
		#else
		trace('File writing cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Write to a path (relative to exe?)
	**/
	public static function writeRaw(path:String, content:String)
	{
		#if sys
		sys.io.File.saveContent(path, content);
		trace('Writing a file to ${path}');
		#else
		trace('File writing cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	/**
		Retrieve all filenames inside 'mods/skins/'
	**/
	public static function readAllSkins():Array<String>
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/skins/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}
}
