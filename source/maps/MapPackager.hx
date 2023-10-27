package maps;

import haxe.io.Bytes;
import qmp.QMPackage;

class MapPackager
{
	private static function Encode(data:String):String
	{
		return "";
	}

	private static function Decode(data:String):String
	{
		return "";
	}

	public static function packageSong(game:String, song:String)
	{
		var files:Array<String>;
		var songPackage:QMPackage = {
			Info: {
				Version: VERSION_FIRST,
				Type: TYPE_SONG
			},
			Entries: []
		};
		if (game == 'fnf')
			files = QMAssets.readModDirectory('fnf/$song');
		else
			files = [];
		songPackage.Info.Version = QMPackageVersion.VERSION_FIRST;
		songPackage.Info.Type = QMPackageType.TYPE_SONG;

		for (filename in files)
		{
			var file = QMAssets.readBinaryModChart(game, '$song/$filename');
			var entry:QMPackageEntry = {
				Name: "",
				Data: "",
			};
			entry.Name = filename;
			entry.Data = file.toHex();
			songPackage.Entries.push(entry);
		}

		QMAssets.writeChartPackage(song, songPackage);
	}

	private static function castJsonToPackage(data:String):QMPackage
		return cast haxe.Json.parse(data);

	public static function extractSong(song:String)
	{
		var data = QMAssets.readModChart('charts', '$song.qmp');
		var songPackage:QMPackage = castJsonToPackage(data);

		QMAssets.makeDirectory('mods/charts/$song');
		for (file in songPackage.Entries)
		{
			QMAssets.writeHexChart(song, file.Name, file.Data);
		}
	}
}
