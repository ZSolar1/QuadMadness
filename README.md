# QuadMadness

## What is this?

QuadMadness is a rhythm game made in HaxeFlixel

## Why is this?

After getting inspired by FNF and it's engine, I decided to try making a rhythm game of my own. The visual art-style is heavily inspired by [osu!lazer](https://lazer.ppy.sh/), and tries to aim at it's fluidity and cleanliness. This game is supposed to be highly-moddable with compatibility with different games.

## Currently available features
- Autoplaying songs (Won't save score)
- Playing FNF songs
- Playing osu!mania songs (unfinished, due to no mp3 support on desktop)
- Chart Editor (WIP)
- Discord RPC
- Song Saving (useless, for now)
- Support for native packaging format

## Planned features

- Scripting to allow for modcharting
- Full osu!mania support
- Fully working options menu
- Project DIVA charts? (unsure)
- Android version?

## Features that will NOT be added

- More/less keys than 4 (the game is oriented around the number 4)

## Playing

I don't know why you would like to play the game in it's unfinished state. But if you would like to, head over to the [Building](#building) part.

## Building

First of all you need [Haxe](https://haxe.org/), I use 4.2.5, newer ones might work.  
The dependencies that you have to install using haxelib are:

- [HaxeFlixel](https://haxeflixel.com/) (`flixel`) (QuadMadness targets the latest version of HaxeFlixel)
- HaxeFlixel Addons (`flixel-addons`)
- Discord RPC (`discord_rpc`, `https://github.com/Aidan63/linc_discord-rpc`)

Afterwards, you type `lime test windows`.
It should compile in 10-40 minutes, depending on your PC
