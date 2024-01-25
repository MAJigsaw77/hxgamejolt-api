package hxgamejolt;

import haxe.crypto.Md5;
import haxe.Http;
import haxe.Json;
#if (target.threaded)
import sys.thread.Thread;
#end

enum SessionStatus
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
	private static final API_PAGE:String = 'https://api.gamejolt.com/api/game';

	@:noCompletion
	private static final API_VERSION:String = 'v1_2';

	@:noCompletion
	private static final DATA_FORMAT:String = '?format=json';

	@:noCompletion
	private static var game_id:String;

	@:noCompletion
	private static var private_key:String;

	/**
	 * @param GameID The ID of your game.
	 * @param PrivateKey The private key of your game.
	 */
	public static function init(GameID:String, PrivateKey:String):Void
	{
		if (GameID == null || (GameID != null && GameID.length <= 0))
			return;
		else if (PrivateKey == null || (PrivateKey != null && PrivateKey.length <= 0))
			return;

		game_id = GameID;
		private_key = PrivateKey;
	}

	/**
	 * Authenticates the user's information.
	 * This should be done before you make any calls for the user, to make sure the user's credentials (username and token) are valid.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function authUser(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/users/auth/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false, onSucceed, onFail);
	}

	/**
	 * Returns a user's data.
	 *
	 * @param UserName username of the user you'd like to fetch the data from.
	 * @param User_ID The ID of the user you'd like to fetch the data from.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function fetchUser(UserName:String, User_ID:Array<Int>, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/users/$DATA_FORMAT&game_id=$game_id';

		if (UserName != null && UserName.length > 0)
			page += '&username=$UserName';
		else if (User_ID != null && User_ID.length > 0)
			page += '&user_id=${User_ID.length > 1 ? User_ID.join(',') : Std.string(User_ID[0])}';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.
	 * You must ping the session to keep it active and you must close it when you're done with it.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function openSessions(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/sessions/open/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false, onSucceed,
			onFail);
	}

	/**
	 * Pings an open session to tell the system that it's still active.
	 * If the session hasn't been pinged within 120 seconds, the system will close the session and you will have to open another one.
	 * It's recommended that you ping about every 30 seconds or so to keep the system from clearing out your session.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Status Sets the status of the session.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function pingSessions(UserName:String, User_Token:String, ?Status:Null<SessionStatus>, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/sessions/ping/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token';

		if (Status != null)
			page += '&status=${Status.getName().toLowerCase()}';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Checks to see if there is an open session for the user.
	 * Can be used to see if a particular user account is active in the game.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function checkSessions(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/sessions/check/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false, onSucceed,
			onFail);
	}

	/**
	 * Closes the active session.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function closeSessions(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/sessions/close/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false, onSucceed,
			onFail);
	}

	/**
	 * Adds a score for a user or guest.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Guest The guest's name.
	 * @param Score This is a string value associated with the score. Example: 500 Points
	 * @param Sort This is a numerical sorting value associated with the score. All sorting will be based on this number. Example: 500
	 * @param Extra_Data If there's any extra data you would like to store as a string, you can use this variable.
	 * @param Table_ID The ID of the score table to submit to.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function addScore(?UserName:String, ?User_Token:String, ?Guest:String, Score:String, Sort:Int, ?Extra_Data:String, ?Table_ID:Int,
			?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/scores/add/$DATA_FORMAT&game_id=$game_id';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';
		else if (Guest != null && Guest.length > 0)
			page += '&guest=$Guest';

		page += '&score=$Score&sort=$Sort';

		if (Extra_Data != null && Extra_Data.length > 0)
			page += '&extra_data=$Extra_Data';

		if (Table_ID != null)
			page += '&table_id=$Table_ID';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Returns the rank of a particular score on a score table.
	 *
	 * @param Sort This is a numerical sorting value that is represented by a rank on the score table.
	 * @param Table_ID The ID of the score table from which you want to get the rank.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function getScoreRank(Sort:Int, ?Table_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/scores/get-rank/$DATA_FORMAT&game_id=$game_id&sort=Sort&table_id=$Table_ID', false, false, onSucceed, onFail);
	}

	/**
	 * Returns a list of scores either for a user or globally for a game.
	 *
	 * @param Limit The number of scores you'd like to return.
	 * @param Table_ID The ID of the score table.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Guest The guest's name.
	 * @param Better_than Fetch only scores better than this score sort value.
	 * @param Worse_than Fetch only scores worse than this score sort value.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function fetchScore(?Limit:Int = 10, ?Table_ID:Int, ?UserName:String, ?User_Token:String, ?Guest:String, ?Better_than:Int, ?Worse_than:Int,
			?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/scores/$DATA_FORMAT&game_id=$game_id';

		if (Limit != null)
		{
			if (Limit >= 100)
				Limit = 100;

			page += '&limit=$Limit';
		}

		if (Table_ID != null)
			page += '&table_id=$Table_ID';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';
		else if (Guest != null && Guest.length > 0)
			page += '&guest=$Guest';

		if (Better_than != null)
			page += '&better_than=$Better_than';
		if (Worse_than != null)
			page += '&worse_than=$Worse_than';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Returns a list of high score tables for a game.
	 *
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function scoreTables(?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/scores/tables/$DATA_FORMAT&game_id=$game_id', false, false, onSucceed, onFail);
	}

	/**
	 * Returns one or multiple trophies, depending on the parameters passed in.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Achieved Pass in true to return only the achieved trophies for a user. Pass in false to return only trophies the user hasn't achieved. Leave null to retrieve all trophies.
	 * @param Trophy_id If you would like to return just one trophy, you may pass the trophy ID with this parameter. If you do, only that trophy will be returned in the response. You may also pass multiple trophy IDs here if you want to return a subset of all the trophies. You do this as a comma-separated list in the same way you would for retrieving multiple users. Passing a `Trophy_ID` will ignore the `Achieved` parameter if it is passed.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function fetchTrophy(UserName:String, User_Token:String, ?Achieved:Null<Bool>, ?Trophy_ID:Int = 0, ?onSucceed:Dynamic->Void,
			?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/trophies/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token';

		if (Achieved != null)
			page += '&achieved=$Achieved';
		else if (Trophy_ID > 0)
			page += '&trophy_id=$Trophy_ID';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Sets a trophy as achieved for a particular user.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Trophy_id The ID of the trophy to add for the user.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function addTrophy(UserName:String, User_Token:String, Trophy_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/trophies/add-achieved/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token&trophy_id=$Trophy_ID',
			false, false, onSucceed, onFail);
	}

	/**
	 * Remove a previously achieved trophy for a particular user.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Trophy_id The ID of the trophy to remove from the user.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function removeTrophy(UserName:String, User_Token:String, Trophy_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/trophies/remove-achieved/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token&trophy_id=$Trophy_ID',
			false, false, onSucceed, onFail);
	}

	/**
	 * Returns data from the data store.
	 *
	 * @param Key The key of the data item you'd like to fetch.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function fetchDataFromDataStore(Key:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/data-store/$DATA_FORMAT&game_id=$game_id&key=$Key';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Returns either all the keys in the game's global data store, or all the keys in a user's data store.
	 *
	 * @param Pattern The pattern to apply to the key names in the data store.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function getDataStoreKeys(?Pattern:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/data-store/get-keys/$DATA_FORMAT&game_id=$game_id';

		if (Pattern != null && Pattern.length > 0)
			page += '&pattern=' + Pattern;

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Removes data from the data store.
	 *
	 * @param Key The key of the data item you'd like to remove.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function removeDataFromDataStore(Key:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/data-store/remove/$DATA_FORMAT&game_id=$game_id&key=$Key';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Sets data in the data store.
	 *
	 * @param Key The key of the data item you'd like to set.
	 * @param Data The data you'd like to set.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function setDataToDataStore(Key:String, Data:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void,
			?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/data-store/set/$DATA_FORMAT&game_id=$game_id&key=$Key&data=$Data';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Updates data in the data store.
	 *
	 * @param Key The key of the data item you'd like to update.
	 * @param Operation The operation you'd like to perform.
	 * @param Value The value you'd like to apply to the data store item.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function updateDataFromDataStore(Key:String, Operation:String, Value:OneOfTwo<String, Int>, ?UserName:String, ?User_Token:String,
			?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/data-store/update/$DATA_FORMAT&game_id=$game_id&key=$Key&operation=$Operation&value=$Value';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, onSucceed, onFail);
	}

	/**
	 * Returns a list of friends of a user.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function fetchFriends(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/friends/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false, onSucceed, onFail);
	}

	/**
	 * Returns the time of the Game Jolt server.
	 *
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function fetchTime(?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		postData('$API_PAGE/$API_VERSION/time/$DATA_FORMAT&game_id=$game_id', false, false, onSucceed, onFail);
	}

	/**
	 * A batch request is a collection of sub-requests that enables developers to send multiple API calls with one HTTP request.
	 *
	 * @param Parallel By default, each sub-request is processed on the servers sequentially. If this is set to true, then all sub-requests are processed at the same time, without waiting for the previous sub-request to finish before the next one is started.
	 * @param Break_On_Error If this is set to true, one sub-request failure will cause the entire batch to stop processing subsequent sub-requests and return a value of false for success.
	 * @param Requests An array of sub-request URLs. Each request will be executed and the responses of each one will be returned in the payload. You must URL-encode each sub-request.
	 *
	 * @param onSucceed A callback returned when the request succeed.
	 * @param onFail A callback returned when the request failed.
	 */
	public static function batchRequest(?Parallel:Null<Bool>, ?Break_On_Error:Null<Bool>, Requests:Array<String>, ?onSucceed:Dynamic->Void,
			?onFail:String->Void):Void
	{
		if (game_id == null && private_key == null)
			return;

		var page:String = '$API_PAGE/$API_VERSION/batch/$DATA_FORMAT&game_id=$game_id';

		for (request in Requests)
			page += '&requests[]=$request';

		if (Parallel != null)
			page += '&parallel=$Parallel';
		else if (Break_On_Error != null)
			page += '&break_on_error=$Break_On_Error';

		postData(page, true, true, onSucceed, onFail);
	}

	@:noCompletion
	private static function postData(url:String, post:Bool = false, encode:Bool = false, onSucceed:Dynamic->Void, onFail:String->Void):Void
	{
		url += '&signature=${Md5.encode(url + private_key)}';

		#if (target.threaded)
		Thread.create(function()
		{
			var http:Http = new Http(encode ? StringTools.urlEncode(url) : url);
			http.onData = function(data:String)
			{
				final response:Dynamic = Json.parse(data).response;

				if (response.success == 'true')
				{
					if (onSucceed != null)
						onSucceed(response);
				}
				else if (response.message != null && response.message.length > 0)
				{
					if (onFail != null)
						onFail(response.message);
				}
			}
			http.onError = function(message:String)
			{
				if (onFail != null)
					onFail(message);
			}
			http.request(post);
		});
		#else
		var http:Http = new Http(encode ? StringTools.urlEncode(url) : url);
		http.onData = function(data:String)
		{
			final response:Dynamic = Json.parse(data).response;

			if (response.success == 'true')
			{
				if (onSucceed != null)
					onSucceed(response);
			}
			else if (response.message != null && response.message.length > 0)
			{
				if (onFail != null)
					onFail(response.message);
			}
		}
		http.onError = function(message:String)
		{
			if (onFail != null)
				onFail(message);
		}
		http.request(post);
		#end
	}
}

@:noCompletion
private abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}
