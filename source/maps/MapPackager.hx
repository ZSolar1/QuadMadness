package maps;

import haxe.io.Bytes;
import cpp.Int32;
import openfl.utils.ByteArray;

class MapPackager
{
	public static function packageSong(game:String, song:String)
	{
		var files:Array<String>;
		var songPackage:ByteArray = new ByteArray();

		if (game == 'fnf')
			files = QMAssets.readModDirectory('fnf/$song');
		else
			files = [];
		trace(files.toString());
		songPackage.writeBytes([0x00, 0x51, 0x4D, 0x50, 0x43, 0x00]); // '.QMPC.' header
		for (filename in files)
		{
			var data = QMAssets.readModChart(game, '$song/$filename');
			songPackage.writeBytes([0x01, 0x50, 0x45, 0x4E, 0x00]); // File entry mark '.PEN.'
			songPackage.writeUTFBytes(filename);
			// songPackage.writeBytes([0x02, 0x50, 0x4C, 0x4E, 0x00]); // File data mark '.PLN.'
			// songPackage.writeInt(data.length);
			songPackage.writeBytes([0x02, 0x50, 0x44, 0x54, 0x00]); // File data mark '.PDT.'
			songPackage.writeUTFBytes(data);
			songPackage.writeBytes([0x03, 0x50, 0x46, 0x4E, 0x00]); // File end mark '.PFN.'
		}
		QMAssets.writeChartPackage(song, songPackage);
	}

	public static function extractSong(song:String)
	{
		var data = QMAssets.readModChart('charts', '$song.qmp');
		var dataBytes = new ByteArray();
		dataBytes.writeUTFBytes(data);
		var files:Map<String, String> = new Map<String, String>();
		var curPos = 6;

		var curMode:Int = -1;

		var latestName:String = "";
		var latestData:String = "";
		var latestLength:Int = 0;

		// Checks header
		if (dataBytes[0] == 0x00 && dataBytes[1] == 0x51 && dataBytes[2] == 0x4D && dataBytes[3] == 0x50 && dataBytes[4] == 0x43 && dataBytes[5] == 0x00)
		{
			trace(".qmp header valid! Extracting song...");
			QMAssets.makeDirectory('mods/charts/$song');
			function checkForMarker()
			{
				if (dataBytes[curPos] == 0x01 && dataBytes[curPos + 1] == 0x50 && dataBytes[curPos + 2] == 0x45 && dataBytes[curPos + 3] == 0x4E
					&& dataBytes[curPos + 4] == 0x00)
				{
					trace('Found a file entry!');
					curPos += 5;
					curMode = 1;
				}
					// else if (dataBytes[curPos] == 0x02 && dataBytes[curPos + 1] == 0x50 && dataBytes[curPos + 2] == 0x4C && dataBytes[curPos + 3] == 0x4E
					// 	&& dataBytes[curPos + 4] == 0x00)
					// {
					// 	trace('Found file length!');
					// 	curPos += 5;
					// 	curMode = 0;
					// 	latestLength = dataBytes[curPos] ^ dataBytes[curPos + 1] ^ dataBytes[curPos + 2] ^ dataBytes[curPos + 3] ^ dataBytes[curPos + 4];
					// 	curPos += 4;
					// 	trace(latestLength);
				// }
				else if (dataBytes[curPos] == 0x02 && dataBytes[curPos + 1] == 0x50 && dataBytes[curPos + 2] == 0x44 && dataBytes[curPos + 3] == 0x54
					&& dataBytes[curPos + 4] == 0x00)
				{
					trace('Found file data!');
					curPos += 5;
					curMode = 2;
				}
				else if (dataBytes[curPos] == 0x03 && dataBytes[curPos + 1] == 0x50 && dataBytes[curPos + 2] == 0x46 && dataBytes[curPos + 3] == 0x4E
					&& dataBytes[curPos + 4] == 0x00)
				{
					trace('Found file ending!');
					curPos += 4;
					curMode = 3;
				}
			}
			while (curPos < dataBytes.length)
			{
				checkForMarker();
				switch (curMode)
				{
					case 1:
						latestName += String.fromCharCode(dataBytes[curPos]);
						checkForMarker();
					case 2:
						latestData += String.fromCharCode(dataBytes[curPos]);
						curPos++;
						trace('\r Reading byte [${latestData.length}] of file "$latestName"');
						checkForMarker();
					case 3:
						files.set(latestName, latestData);
						QMAssets.writeRaw('mods/charts/$song/$latestName', latestData);
						latestName = "";
						latestData = "";
						checkForMarker();
				}
				curPos++;
			}
		}
		else
			trace(".qmp header invalid, file is either not a packaged chart, or a corrupted file");
		return;
	}
}
