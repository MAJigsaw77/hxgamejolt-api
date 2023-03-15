package hxgamejolt;

import haxe.Http;
import haxe.Json;
import haxe.crypto.Md5;
import haxe.crypto.Sha1;

abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}

enum Encoding
{
	MD5;
	SHA1;
}

/**
 * @see https://gamejolt.com/game-api/doc
 * 
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class GameJolt
{
	//////////////////////////////////////////////////////

	public static var encoding:Encoding = MD5;
	public static var initialized(get, never):Bool;

	private static final API_PAGE:String = 'https://api.gamejolt.com/api/game';
	private static final API_VERSION:String = 'v1_2';
	private static final DATA_FORMAT:String = '?format=json';

	private static var game_id:String;
	private static var private_key:String;

	//////////////////////////////////////////////////////

	/**
	 * @param Game_id The ID of your game.
	 * @param Private_key The private key of your game.
	 */
	public static function init(Game_id:String, Private_key:String):Void
	{
		game_id = Game_id;
		private_key = Private_key;
	}

	/**
	 * Authenticates the user's information.
	 * This should be done before you make any calls for the user, to make sure the user's credentials (username and token) are valid.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function authUser(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/users/auth/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token, false, onSucceed, onFail);
	}

	/**
	 * Returns a user's data.
	 * 
	 * @param UserName username of the user you'd like to fetch the data from.
	 * @param User_ID The ID of the user you'd like to fetch the data from.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function fetchUser(UserName:String, User_ID:Array<Int>, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/users/' + DATA_FORMAT + '&game_id=' + game_id;

		if (UserName != null)
			page += '&username=' + UserName;
		else if (User_ID != null)
			page += '&user_id=' + User_ID.length > 1 ? User_ID.join(',') : User_ID[0];

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.
	 * You must ping the session to keep it active and you must close it when you're done with it.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function openSessions(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/sessions/open/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token, false, onSucceed, onFail);
	}

	/**
	 * Pings an open session to tell the system that it's still active.
	 * If the session hasn't been pinged within 120 seconds, the system will close the session and you will have to open another one.
	 * It's recommended that you ping about every 30 seconds or so to keep the system from clearing out your session.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Status Sets the status of the session.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function pingSessions(UserName:String, User_Token:String, ?Status:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/sessions/ping/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token;

		if (Status == 'active' || Status == 'idle')
			page += '&status=' + Status;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Checks to see if there is an open session for the user.
	 * Can be used to see if a particular user account is active in the game.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function checkSessions(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/sessions/check/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token, false, onSucceed, onFail);
	}

	/**
	 * Closes the active session.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function closeSessions(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/sessions/close/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token, false, onSucceed, onFail);
	}

	/**
	 * Adds a score for a user or guest.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Guest The guest's name.
	 * @param Score This is a string value associated with the score. Example: 500 Points
	 * @param Sort This is a numerical sorting value associated with the score. All sorting will be based on this number. Example: 500
	 * @param Extra_data If there's any extra data you would like to store as a string, you can use this variable.
	 * @param Table_ID The ID of the score table to submit to.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function addScore(?UserName:String, ?User_Token:String, ?Guest:String, Score:String, Sort:Int, ?Extra_data:String, ?Table_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/scores/add/' + DATA_FORMAT + '&game_id=' + game_id;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;
		else if (Guest != null)
			page += '&guest=' + Guest;

		page += '&score=' + Score + '&sort=' + Sort;

		if (Extra_data != null)
			page += '&extra_data=' + Extra_data;
		if (Table_ID != null)
			page += '&table_id=' + Table_ID;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Returns the rank of a particular score on a score table.
	 * 
	 * @param Sort This is a numerical sorting value that is represented by a rank on the score table.
	 * @param Table_ID The ID of the score table from which you want to get the rank.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function getScoreRank(Sort:Int, ?Table_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/scores/get-rank/' + DATA_FORMAT + '&game_id=' + game_id + '&sort=' + Sort + '&table_id=' + Table_ID, false, onSucceed, onFail);
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
	 * @param CallBack A callback with the returned json data.
	 */
	public static function fetchScore(?Limit:Int, ?Table_ID:Int, ?UserName:String, ?User_Token:String, ?Guest:String, ?Better_than:Int, ?Worse_than:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/scores/' + DATA_FORMAT + '&game_id=' + game_id;

		if (Limit != null)
			page += '&limit=' + Limit;
		if (Table_ID != null)
			page += '&table_id=' + Table_ID;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;
		else if (Guest != null)
			page += '&guest=' + Guest;

		if (Better_than != null)
			page += '&better_than=' + Better_than;
		if (Worse_than != null)
			page += '&worse_than=' + Worse_than;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Returns a list of high score tables for a game.
	 * 
	 * @param CallBack A callback with the returned json data.
	 */
	public static function scoreTables(?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/scores/tables/' + DATA_FORMAT + '&game_id=' + game_id, false, onSucceed, onFail);
	}

	/**
	 * Returns one or multiple trophies, depending on the parameters passed in.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Achieved Pass in true to return only the achieved trophies for a user. Pass in false to return only trophies the user hasn't achieved. Leave null to retrieve all trophies.
	 * @param Trophy_id If you would like to return just one trophy, you may pass the trophy ID with this parameter. If you do, only that trophy will be returned in the response. You may also pass multiple trophy IDs here if you want to return a subset of all the trophies. You do this as a comma-separated list in the same way you would for retrieving multiple users. Passing a `Trophy_ID` will ignore the `Achieved` parameter if it is passed.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function fetchTrophy(UserName:String, User_Token:String, ?Achieved:Null<Bool>, ?Trophy_ID:Int = 0, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/trophies/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token;

		if (Achieved != null)
			page += '&achieved=' + Achieved;
		else if (Trophy_ID > 0)
			page += '&trophy_id=' + Trophy_ID;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Sets a trophy as achieved for a particular user.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Trophy_id The ID of the trophy to add for the user.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function addTrophy(UserName:String, User_Token:String, Trophy_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/trophies/add-achieved/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token + '&trophy_id=' + Trophy_ID, false, onSucceed, onFail);
	}

	/**
	 * Remove a previously achieved trophy for a particular user.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Trophy_id The ID of the trophy to remove from the user.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function removeTrophy(UserName:String, User_Token:String, Trophy_ID:Int, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/trophies/remove-achieved/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token + '&trophy_id=' + Trophy_ID, false, onSucceed, onFail);
	}

	/**
	 * Returns data from the data store.
	 * 
	 * @param Key The key of the data item you'd like to fetch.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function fetchDataFromDataStore(Key:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/data-store/' + DATA_FORMAT + '&game_id=' + game_id + '&key=' + Key;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Returns either all the keys in the game's global data store, or all the keys in a user's data store.
	 * 
	 * @param Pattern The pattern to apply to the key names in the data store.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function getDataStoreKeys(?Pattern:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/data-store/get-keys/' + DATA_FORMAT + '&game_id=' + game_id;

		if (Pattern != null)
			page += '&pattern=' + Pattern;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Removes data from the data store.
	 * 
	 * @param Key The key of the data item you'd like to remove.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function removeDataFromDataStore(Key:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/data-store/remove/' + DATA_FORMAT + '&game_id=' + game_id + '&key=' + Key;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Sets data in the data store.
	 * 
	 * @param Key The key of the data item you'd like to set.
	 * @param Data The data you'd like to set.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function setDataToDataStore(Key:String, Data:String, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/data-store/set/' + DATA_FORMAT + '&game_id=' + game_id + '&key=' + Key + '&data=' + Data;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Updates data in the data store.
	 * 
	 * @param Key The key of the data item you'd like to update.
	 * @param Operation The operation you'd like to perform.
	 * @param Value The value you'd like to apply to the data store item.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function updateDataFromDataStore(Key:String, Operation:String, Value:OneOfTwo<String, Int>, ?UserName:String, ?User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/data-store/update/' + DATA_FORMAT + '&game_id=' + game_id + '&key=' + Key + '&operation=' + Operation + '&value=' + Value;

		if (UserName != null && User_Token != null)
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, onSucceed, onFail);
	}

	/**
	 * Returns a list of friends of a user.
	 * 
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function fetchFriends(UserName:String, User_Token:String, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/friends/' + DATA_FORMAT + '&game_id=' + game_id + '&username=' + UserName + '&user_token=' + User_Token, false, onSucceed, onFail);
	}

	/**
	 * Returns the time of the Game Jolt server.
	 * 
	 * @param CallBack A callback with the returned json data.
	 */
	public static function fetchTime(?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		postData(API_PAGE + '/' + API_VERSION + '/friends/' + DATA_FORMAT + '&game_id=' + game_id, false, onSucceed, onFail);
	}

	/**
	 * A batch request is a collection of sub-requests that enables developers to send multiple API calls with one HTTP request.
	 * 
	 * @param Parallel By default, each sub-request is processed on the servers sequentially. If this is set to true, then all sub-requests are processed at the same time, without waiting for the previous sub-request to finish before the next one is started.
	 * @param Break_On_Error If this is set to true, one sub-request failure will cause the entire batch to stop processing subsequent sub-requests and return a value of false for success.
	 * @param Requests An array of sub-request URLs. Each request will be executed and the responses of each one will be returned in the payload. You must URL-encode each sub-request.
	 * @param CallBack A callback with the returned json data.
	 */
	public static function batchRequest(?Parallel:Null<Bool>, ?Break_On_Error:Null<Bool>, Requests:Array<String>, ?onSucceed:Dynamic->Void, ?onFail:String->Void):Void
	{
		if (!initialized)
			return;

		var page:String = API_PAGE + '/' + API_VERSION + '/batch/' + DATA_FORMAT + '&game_id=' + game_id;

		for (request in Requests)
			page += '&requests[]=' + request;

		if (Parallel != null)
			page += '&parallel=' + Parallel;
		else if (Break_On_Error != null)
			page += '&break_on_error=' + Break_On_Error;

		postData(page, true, onSucceed, onFail);
	}

	//////////////////////////////////////////////////////

	private static function postData(URL:String, EncodeURL:Bool = false, onSucceed:Dynamic->Void, onFail:String->Void):Void
	{
		switch (encoding)
		{
			case MD5:
				URL += '&signature=' + Md5.encode(URL + private_key);
			case SHA1:
				URL += '&signature=' + Sha1.encode(URL + private_key);
		}

		if (EncodeURL)
			URL = StringTools.urlEncode(URL);

		var http:Http = new Http(URL);
		http.onData = function(data:String)
		{
			var response:Dynamic = Json.parse(data).response;

			if (response.success == 'true')
			{
				if (onSucceed != null)
					onSucceed(response);
			}
			else if (response.message != null)
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
		http.request(true);
	}

	//////////////////////////////////////////////////////

	static function get_initialized():Bool
	{
		if ((game_id != null && game_id != '') && (private_key != null && private_key != ''))
			return true;

		return false;
	}

	//////////////////////////////////////////////////////
}
