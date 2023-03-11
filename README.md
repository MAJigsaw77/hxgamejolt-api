### hxgamejolt

A full integration of GameJolt API to Haxe.

### Features
* Latest API version.
* JSON Data format.
* MD5/Sha1 URL encoding.
* And many more!

### Installation

Do this command `haxelib git gamejolt-integration https://github.com/MAJigsaw77/hxgamejolt.git` on Command prompt/PowerShell.

### Basic Functons

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
}, function(message:String) // onFail
{
	// your code
});

// there are more function then those, check the source if you want.
```

### Credits
* [M.A. Jigsaw](https://github.com/MAJigsaw77) - Creator of this library.
* The Contributors!
