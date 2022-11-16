### Haxe-GameJolt-Integration

A full integration of GameJolt to Haxe using Flash.

### Features
* Latest API version.
* JSON Data Format.
* MD5 URL Encoding.
* And many more!

### Installation

1. Do this command `haxelib git gamejolt-integration https://github.com/MAJigsaw77/Haxe-GameJolt-Integration` on Command prompt/PowerShell.

2. Add it to `Project.xml` like this.

```xml
<haxelib name="gamejolt-integration" />
```

### Basic Functons

```haxe
import api.GameJoltClient; // be sure you import this.

GameJoltClient.init('game id', 'private key');
GameJoltClient.authUser('user name', 'user token', function(json:Dynamic)
{
	// your code
});
GameJoltClient.fetchUser('user name', null, function(json:Dynamic)
{
	// your code
});

// there are more function then those, check the source if you want!
```

### Credits
* [M.A. Jigsaw](https://github.com/MAJigsaw77) - Creator of this library.
* The Contributors!
