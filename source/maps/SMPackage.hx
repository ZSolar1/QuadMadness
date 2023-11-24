package maps;

enum SMPackageVersion
{
	VERSION_FIRST;
}

enum SMPackageType
{
	TYPE_SONG;
}

typedef SMPackageInfo =
{
	var Version:SMPackageVersion;
	var Type:SMPackageType;
}

typedef SMPackageEntry =
{
	var Name:String;
	var Data:String;
}

typedef SMPackage =
{
	var Info:SMPackageInfo;
	var Entries:Array<SMPackageEntry>;
}