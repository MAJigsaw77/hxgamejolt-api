# hxgamejolt-api

A full integration of [GameJolt API](https://gamejolt.com/game-api) to Haxe.

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxgamejolt) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxgamejolt) ![](https://badgen.net/badge/license/MIT/green)

### Features
* Latest API version.
* JSON Data format.
* MD5/Sha1 URL encoding.
* And many more!

### Installation

You can install it through `Haxelib`
```bash
haxelib install hxgamejolt
```
Or through `Git`, if you want the latest updates
```bash
haxelib git hxgamejolt https://github.com/MAJigsaw77/hxgamejolt.git
```

### Basic Usage Example

```haxe
import gamejolt.Client as GJClient; // be sure you import this.

GJClient.init('game id', 'private key');

GJClient.authUser('user name', 'user token', function(json:Dynamic) // on Succeed
{
	// your code
}, function(message:String) // on Failure
{
	// your code
});

GJClient.fetchUser('user name', 0, function(json:Dynamic) // on Succeed
{
	// your code
}, function(message:String) // on Failure
{
	// your code
});
```
