package hxgamejolt;

import hxgamejolt.data.Friend;
import hxgamejolt.data.Score;
import hxgamejolt.data.Table;
import hxgamejolt.data.Time;
import hxgamejolt.data.Trophy;
import hxgamejolt.data.User;
import hxgamejolt.util.GameJoltHttp;
import hxgamejolt.util.OneOfTwo;

/**
 * Callbacks for handling responses without a return value.
 */
typedef EmptyResponseCallbacks =
{
	/** Called when the request succeeds. */
	var onSucceed:Void->Void;

	/** Called when the request fails, providing an error message. */
	var onFail:String->Void;
}

/**
 * Callbacks for handling responses with a return value.
 *
 * @param T The expected type of the successful response data.
 */
typedef TypeResponseCallbacks<T> =
{
	/** Called when the request succeeds, passing the response data of type `T`. */
	var onSucceed:T->Void;

	/** Called when the request fails, providing an error message. */
	var onFail:String->Void;
}

/**
 * The status of the session.
 */
enum Status
{
	/**
	 * Sets the session to the `active` state.
	 */
	Active;

	/**
	 * Sets the session to the `idle` state.
	 */
	Idle;
}

/**
 * @see https://gamejolt.com/game-api/doc
 */
class GameJolt
{
	@:noCompletion
	private static var game_id:Null<String>;

	@:noCompletion
	private static var private_key:Null<String>;

	/**
	 * Initializes the Game ID and private key for API usage.
	 * 
	 * @param GameID The Game ID to authenticate the game on GameJolt's platform.
	 * @param PrivateKey The private key for authentication with GameJolt.
	 */
	public static function init(GameID:String, PrivateKey:String):Void
	{
		if (GameID == null || GameID.length == 0)
			return;
		else if (PrivateKey == null || PrivateKey.length == 0)
			return;

		game_id = GameID;
		private_key = PrivateKey;
	}

	/**
	 * Fetches user information.
	 * 
	 * @see https://gamejolt.com/game-api/doc/users/fetch
	 * @param UserName The username of the user whose data you'd like to fetch.
	 * @param UserID The ID of the user whose data you'd like to fetch.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function fetchUser(UserName:String, UserID:Array<Int>, ?Response:TypeResponseCallbacks<Array<User>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id'];

		if (UserName != null && UserName.length > 0)
			gjParams.push('username=$UserName');
		else if (UserID != null && UserID.length > 0)
			gjParams.push('user_id=' + UserID.join(','));

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('users', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
				{
					if (data.users != null)
					{
						switch (Type.typeof(data.users))
						{
							case TClass(Array):
								if (Response.onSucceed != null)
									Response.onSucceed([for (data in (data.users : Array<Dynamic>)) new User(data)]);
							default:
								if (Response.onSucceed != null)
									Response.onSucceed([]);
						}
					}
					else
					{
						if (Response.onSucceed != null)
							Response.onSucceed([]);
					}
				}
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Authenticates the user's information.
	 * 
	 * This should be done before you make any calls for the user, to make sure the user's credentials (username and token) are valid.
	 * 
	 * @see https://gamejolt.com/game-api/doc/users/auth
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function authUser(UserName:String, UserToken:String, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('users/auth', ['game_id=$game_id', 'username=$UserName', 'user_token=$UserToken'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.
	 * 
	 * You must ping the session to keep it active and you must close it when you're done with it.
	 * 
	 * @see https://gamejolt.com/game-api/doc/sessions/open
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function openSessions(UserName:String, UserToken:String, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('sessions/open', ['game_id=$game_id', 'username=$UserName', 'user_token=$UserToken'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Pings an open session to tell the system that it's still active.
	 * 
	 * If the session hasn't been pinged within 120 seconds, the system will close the session and you will have to open another one.
	 * It's recommended that you ping about every 30 seconds or so to keep the system from clearing out your session.
	 * You can also let the system know whether the player is in an active or idle state within your game.
	 * 
	 * @see https://gamejolt.com/game-api/doc/sessions/ping
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Status Sets the status of the session.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function pingSessions(UserName:String, UserToken:String, ?Status:Null<Status>, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id'];

		if (Status != null)
			gjParams.push('status=${Status.getName().toLowerCase()}');

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('sessions/ping', gjParams.concat(['username=$UserName', 'user_token=$UserToken']), private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Checks to see if there is an open session for the user.
	 * 
	 * Can be used to see if a particular user account is active in the game.
	 * 
	 * @see https://gamejolt.com/game-api/doc/sessions/check
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function checkSessions(UserName:String, UserToken:String, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('sessions/check', ['game_id=$game_id', 'username=$UserName', 'user_token=$UserToken'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Closes the active session.
	 * 
	 * @see https://gamejolt.com/game-api/doc/sessions/close
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function closeSessions(UserName:String, UserToken:String, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('sessions/close', ['game_id=$game_id', 'username=$UserName', 'user_token=$UserToken'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Adds a score.
	 * 
	 * @see https://gamejolt.com/game-api/doc/scores/add
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Guest The guest's name.
	 * @param Score This is a string value associated with the score. Example: 500 Points
	 * @param Sort This is a numerical sorting value associated with the score. All sorting will be based on this number. Example: 500
	 * @param ExtraData If there's any extra data you would like to store as a string, you can use this variable.
	 * @param TableID The ID of the score table to submit to.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function addScore(?UserName:String, ?UserToken:String, ?Guest:String, Score:String, Sort:Int, ?ExtraData:String, ?TableID:Int,
			?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'score=$Score', 'sort=$Sort'];

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}
		else if (Guest != null && Guest.length > 0)
			gjParams.push('guest=$Guest');

		if (ExtraData != null && ExtraData.length > 0)
			gjParams.push('extra_data=$ExtraData');

		if (TableID != null)
			gjParams.push('table_id=$TableID');

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('scores/add', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Fetches the rank of a particular score on a score table.
	 * 
	 * @see https://gamejolt.com/game-api/doc/scores/get-rank
	 * @param Sort This is a numerical sorting value that is represented by a rank on the score table.
	 * @param TableID The ID of the score table from which you want to get the rank.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function getScoreRank(Sort:Int, ?TableID:Int, ?Response:TypeResponseCallbacks<Int>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'sort=$Sort'];

		if (TableID != null)
			gjParams.push('table_id=$TableID');

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('scores/get-rank', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed(data.rank);
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Fetches a list of scores either for a user or globally for a game.
	 * 
	 * @see https://gamejolt.com/game-api/doc/scores/fetch
	 * @param Limit The number of scores you'd like to return.
	 * @param TableID The ID of the score table.
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Guest The guest's name.
	 * @param BetterThan Fetch only scores better than this score sort value.
	 * @param WorseThan Fetch only scores worse than this score sort value.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function fetchScore(?Limit:Int = 10, ?TableID:Int, ?UserName:String, ?UserToken:String, ?Guest:String, ?BetterThan:Int, ?WorseThan:Int,
			?Response:TypeResponseCallbacks<Array<Score>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id'];

		if (Limit != null)
			gjParams.push('limit=${Limit < 100 ? Limit : 100}');

		if (TableID != null)
			gjParams.push('table_id=$TableID');

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}
		else if (Guest != null && Guest.length > 0)
			gjParams.push('guest=$Guest');

		if (BetterThan != null)
			gjParams.push('better_than=$BetterThan');
		if (WorseThan != null)
			gjParams.push('worse_than=$WorseThan');

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('scores', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
				{
					if (data.scores != null)
					{
						switch (Type.typeof(data.scores))
						{
							case TClass(Array):
								if (Response.onSucceed != null)
									Response.onSucceed([for (data in (data.scores : Array<Dynamic>)) new Score(data)]);
							default:
								if (Response.onSucceed != null)
									Response.onSucceed([]);
						}
					}
					else
					{
						if (Response.onSucceed != null)
							Response.onSucceed([]);
					}
				}
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Fetches a list of high score tables for a game.
	 * 
	 * @see https://gamejolt.com/game-api/doc/scores/tables
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function scoreTables(?Response:TypeResponseCallbacks<Array<Table>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('scores/tables', ['game_id=$game_id'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
				{
					if (data.tables != null)
					{
						switch (Type.typeof(data.tables))
						{
							case TClass(Array):
								if (Response.onSucceed != null)
									Response.onSucceed([for (data in (data.tables : Array<Dynamic>)) new Table(data)]);
							default:
								if (Response.onSucceed != null)
									Response.onSucceed([]);
						}
					}
					else
					{
						if (Response.onSucceed != null)
							Response.onSucceed([]);
					}
				}
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Fetches one or multiple trophies based on the provided parameters.
	 * 
	 * @see https://gamejolt.com/game-api/doc/trophies/fetch
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Achieved If true, fetches only achieved trophies. If false, fetches only unachieved trophies. If null, fetches all trophies. Ignored if `TrophyID` is provided.
	 * @param TrophyID A list of trophy IDs to fetch. If provided, only these trophies are returned, and `Achieved` is ignored.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function fetchTrophy(UserName:String, UserToken:String, ?Achieved:Null<Bool>, ?TrophyID:Array<Int>,
			?Response:TypeResponseCallbacks<Array<Trophy>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'username=$UserName', 'user_token=$UserToken'];

		if (TrophyID != null && TrophyID.length > 0)
			gjParams.push('trophy_id=' + TrophyID.join(','));
		else if (Achieved != null)
			gjParams.push('achieved=$Achieved');

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('trophies', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
				{
					if (data.trophies != null)
					{
						switch (Type.typeof(data.trophies))
						{
							case TClass(Array):
								if (Response.onSucceed != null)
									Response.onSucceed([for (data in (data.trophies : Array<Dynamic>)) new Trophy(data)]);
							default:
								if (Response.onSucceed != null)
									Response.onSucceed([]);
						}
					}
					else
					{
						if (Response.onSucceed != null)
							Response.onSucceed([]);
					}
				}
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Sets a trophy as achieved for a particular user.
	 * 
	 * @see https://gamejolt.com/game-api/doc/trophies/add-achieved
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param TrophyID The ID of the trophy to add for the user.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function addTrophy(UserName:String, UserToken:String, TrophyID:Int, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('trophies/add-achieved', [
			'game_id=$game_id',
			'username=$UserName',
			'user_token=$UserToken',
			'trophy_id=$TrophyID'
		], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Remove a previously achieved trophy for a particular user.
	 * 
	 * @see https://gamejolt.com/game-api/doc/trophies/remove-achieved
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param TrophyID The ID of the trophy to remove from the user.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function removeTrophy(UserName:String, UserToken:String, TrophyID:Int, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('trophies/remove-achieved', [
			'game_id=$game_id',
			'username=$UserName',
			'user_token=$UserToken',
			'trophy_id=$TrophyID'
		], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Returns data from the data store.
	 * 
	 * @see https://gamejolt.com/game-api/doc/data-store/fetch
	 * @param Key The key of the data item you'd like to fetch.
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function fetchDataFromDataStore(Key:String, ?UserName:String, ?UserToken:String, ?Response:TypeResponseCallbacks<String>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'key=$Key'];

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('data-store', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed(data.data);
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Returns either all the keys in the game's global data store, or all the keys in a user's data store.
	 * 
	 * @see https://gamejolt.com/game-api/doc/data-store/get-keys
	 * @param Pattern The pattern to apply to the key names in the data store.
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function getDataStoreKeys(?Pattern:String, ?UserName:String, ?UserToken:String, ?Response:TypeResponseCallbacks<Array<String>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id'];

		if (Pattern != null && Pattern.length > 0)
			gjParams.push('pattern=' + Pattern);

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('data-store/get-keys', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
				{
					if (data.keys != null)
					{
						switch (Type.typeof(data.keys))
						{
							case TClass(Array):
								if (Response.onSucceed != null)
									Response.onSucceed([for (data in (data.keys : Array<Dynamic>)) data.key]);
							default:
								if (Response.onSucceed != null)
									Response.onSucceed([]);
						}
					}
					else
					{
						if (Response.onSucceed != null)
							Response.onSucceed([]);
					}
				}
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Removes data from the data store.
	 * 
	 * @see https://gamejolt.com/game-api/doc/data-store/remove
	 * @param Key The key of the data item you'd like to remove.
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function removeDataFromDataStore(Key:String, ?UserName:String, ?UserToken:String, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'key=$Key'];

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('data-store/remove', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Sets data in the data store.
	 * 
	 * @see https://gamejolt.com/game-api/doc/data-store/set
	 * @param Key The key of the data item you'd like to set.
	 * @param Data The data you'd like to set.
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function setDataToDataStore(Key:String, Data:String, ?UserName:String, ?UserToken:String, ?Response:EmptyResponseCallbacks):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'key=$Key', 'data=$Data'];

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('data-store/set', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed();
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Updates data in the data store.
	 * 
	 * @see https://gamejolt.com/game-api/doc/data-store/update
	 * @param Key The key of the data item you'd like to update.
	 * @param Operation The operation you'd like to perform.
	 * @param Value The value you'd like to apply to the data store item.
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function updateDataFromDataStore(Key:String, Operation:String, Value:OneOfTwo<String, Int>, ?UserName:String, ?UserToken:String,
			?Response:TypeResponseCallbacks<OneOfTwo<String, Int>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id', 'key=$Key', 'operation=$Operation', 'value=$Value'];

		if ((UserName != null && UserName.length > 0) && (UserToken != null && UserToken.length > 0))
		{
			gjParams.push('username=$UserName');
			gjParams.push('user_token=$UserToken');
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('data-store/update', gjParams, private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed(data.data);
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Fetches the list of a user's friends.
	 * 
	 * @see https://gamejolt.com/game-api/doc/friends/fetch
	 * @param UserName The user's username.
	 * @param UserToken The user's token.
	 * @param Response The callback object containing callbacks.
	 * @return The configured HTTP request.
	 */
	public static function fetchFriends(UserName:String, UserToken:String, ?Response:TypeResponseCallbacks<Array<Friend>>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('friends', ['game_id=$game_id', 'username=$UserName', 'user_token=$UserToken'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
				{
					if (data.friends != null)
					{
						switch (Type.typeof(data.friends))
						{
							case TClass(Array):
								if (Response.onSucceed != null)
									Response.onSucceed([for (data in (data.friends : Array<Dynamic>)) new Friend(data)]);
							default:
								if (Response.onSucceed != null)
									Response.onSucceed([]);
						}
					}
					else
					{
						if (Response.onSucceed != null)
							Response.onSucceed([]);
					}
				}
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * Fetches the time of the Game Jolt server.
	 * 
	 * @see https://gamejolt.com/game-api/doc/time/fetch
	 * @param Response The response callbacks for success and failure cases.
	 * @return The configured HTTP request.
	 */
	public static function fetchTime(?Response:TypeResponseCallbacks<Time>):GameJoltHttp
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('time', ['game_id=$game_id'], private_key);

		if (Response != null)
		{
			gjHttp.onSucceed = function(data:Dynamic):Void
			{
				if (Response.onSucceed != null)
					Response.onSucceed(new Time(data));
			};

			gjHttp.onFail = function(message:String):Void
			{
				if (Response.onFail != null)
					Response.onFail(message);
			};
		}

		return gjHttp;
	}

	/**
	 * A batch request is a collection of sub-requests that enables developers to send multiple API calls with one HTTP request.
	 * 
	 * @see https://gamejolt.com/game-api/doc/batch
	 * @param Parallel By default, each sub-request is processed on the servers sequentially. If this is set to true, then all sub-requests are processed at the same time, without waiting for the previous sub-request to finish before the next one is started.
	 * @param BreakOnError If this is set to true, one sub-request failure will cause the entire batch to stop processing subsequent sub-requests and return a value of false for success.
	 * @param Requests An array of sub-request. Each request will be executed and the responses of each one will be returned in the payload.
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function batchRequest(?Parallel:Bool, ?BreakOnError:Bool, Requests:Array<GameJoltHttp>, ?Response:EmptyResponseCallbacks):Void
	{
		if ((game_id == null || game_id.length == 0) || (private_key == null || private_key.length == 0))
		{
			#if HXGAMEJOLT_LOGGING
			trace('Missing Game ID or Private Key.');
			#end
		}

		final gjParams:Array<String> = ['game_id=$game_id'];

		if (Parallel != null)
			gjParams.push('parallel=' + Parallel);

		if (BreakOnError != null)
			gjParams.push('break_on_error=' + BreakOnError);

		if (Requests != null && Requests.length > 0)
		{
			@:privateAccess
			for (Request in Requests)
				gjParams.push('requests[]=' + Request.createBatchRequest(Request.urlRequest));
		}

		@:nullSafety(Off)
		final gjHttp:GameJoltHttp = new GameJoltHttp('batch', gjParams, private_key);

		gjHttp.onSucceed = function(data:Dynamic):Void
		{
			final responses:Array<Dynamic> = data.responses;

			for (i in 0...responses.length)
			{
				@:privateAccess
				if (Requests[i] != null && responses[i] != null)
					Requests[i].dispatchData(responses[i]);
			}

			if (Response != null && Response.onSucceed != null)
				Response.onSucceed();
		};

		gjHttp.onFail = function(message:String):Void
		{
			if (Response != null && Response.onFail != null)
				Response.onFail(message);
		};

		gjHttp.requestData();
	}
}
