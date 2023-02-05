package;

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

	public static function read(path:String, type:String)
	{
		#if sys
		trace('Reading a file from ${createFilePath(path, type)}');
		return sys.io.File.getContent(createFilePath(path, type));
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		#end
	}

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

	public static function exists(file):Bool
	{
		#if sys
		return sys.FileSystem.exists(file);
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	public static function FNFreadAllCharts():Array<String>
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/fnf/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	public static function readPackagedCharts():Array<String>
	{
		#if sys
		return sys.FileSystem.readDirectory('mods/charts/');
		#else
		trace('File reading cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

	public static function readChartPackage() {}

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

	public static function writeChart(name:String, diff:String, content:String)
	{
		#if sys
		sys.io.File.saveContent(createModFilePath('charts', '$name/$diff.json'), content);
		trace('Writing a file to ${createModFilePath('charts', '$name/$diff.json')}');
		#else
		trace('File writing cancelled, client is not on sys-compatible platform.');
		return null;
		#end
	}

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
