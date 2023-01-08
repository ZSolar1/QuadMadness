Compiler_OS=$(OS)

windows:
	@lime test windows
	
macos:
	@lime build macos

linux:
	@lime build linux

android:
	@lime build android

html5:
	@lime build html5