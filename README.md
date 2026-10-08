# hxgamejolt-api

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxgamejolt) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxgamejolt) ![](https://badgen.net/badge/license/MIT/green)

Haxe bindings for [GameJolt API](https://gamejolt.com/game-api).

### Installation

You can install it through `Haxelib`
```bash
haxelib install hxgamejolt-api
```
Or through `Git`, if you want the latest updates
```bash
haxelib git hxgamejolt-api https://github.com/MAJigsaw77/hxgamejolt-api.git
```

### Basic Usage Example
Samples on different engines can be found inside [examples](https://github.com/MAJigsaw77/hxgamejolt-api/samples/flixel/SetupHTML5Auto).

> [!WARNING]
> Any function that returns **GameJoltHttp** takes some time before it finishes
> e.g. `authUser()` or `openSession()`, so avoid writing any followup after it
> without it being passed onto an `onSucceed` function or a
> timer delayed function such as `haxe.Timer()` (or something similar)

```haxe
import hxgamejolt.GameJolt;

GameJolt.init('game id', 'private key');

// Basic API

GameJolt.authUser('user name', 'user token', {
	onSucceed: function():Void
	{
		// your code
	},
	onFail: function(message:String):Void
	{
		trace(message);
	}
}).requestData();

GameJolt.fetchUser('user name', [], {
	onSucceed: function():Void
	{
		// your code
	},
	onFail: function(message:String):Void
	{
		trace(message);
	}
}).requestData();

// Batch Requests

final addTrophyResponse:GameJoltEmptyCallback = {
	onSucceed: function():Void
	{
		// your code
	},
	onFail: function(message:String):Void
	{
		trace(message);
	}
};

final addTrophyRequest0:GameJoltHttp = GameJolt.addTrophy('user name', 'user token', 0, addTrophyResponse);
final addTrophyRequest1:GameJoltHttp = GameJolt.addTrophy('user name', 'user token', 0, addTrophyResponse);
final addTrophyRequest2:GameJoltHttp = GameJolt.addTrophy('user name', 'user token', 0, addTrophyResponse);

GameJolt.batchRequest([addTrophyRequest0, addTrophyRequest1, addTrophyRequest2], {
	onSucceed: function():Void
	{
		// your code
	},
	onFail: function(msg:String):Void
	{
		trace(message);
	}
});
```

### Licensing

**hxgamejolt-api** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.
