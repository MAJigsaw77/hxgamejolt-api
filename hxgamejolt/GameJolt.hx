package hxgamejolt;

import haxe.crypto.Md5;
import haxe.Http;
import haxe.Json;
import haxe.MainLoop;
import hxgamejolt.util.OneOfTwo;

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

typedef ResponseCallbacks =
{
	/**
	 * The callback function to be executed on success.
	 */
	onSucceed:Dynamic->Void,

	/**
	 * The callback function to be executed on failure.
	 */
	onFail:String->Void
}

/**
 * @see https://gamejolt.com/game-api/doc
 */
@:nullSafety
class GameJolt
{
	@:noCompletion
	private static final API_PAGE:String = 'https://api.gamejolt.com/api/game';

	@:noCompletion
	private static final API_VERSION:String = 'v1_2';

	@:noCompletion
	private static final DATA_FORMAT:String = '?format=json';

	/**
	 * Indicates whether the ID and Private Key has been successfully set up.
	 */
	public static var initialized(get, never):Bool;

	@:noCompletion
	private static var game_id:Null<String>;

	@:noCompletion
	private static var private_key:Null<String>;

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
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function authUser(UserName:String, User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('users/auth/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns a user's data.
	 *
	 * @param UserName username of the user you'd like to fetch the data from.
	 * @param User_ID The ID of the user you'd like to fetch the data from.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function fetchUser(UserName:String, User_ID:Array<Int>, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'users/$DATA_FORMAT&game_id=$game_id';

		if (UserName != null && UserName.length > 0)
			page += '&username=$UserName';
		else if (User_ID != null && User_ID.length > 0)
			page += '&user_id=${User_ID.length > 1 ? User_ID.join(',') : Std.string(User_ID[0])}';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.
	 * You must ping the session to keep it active and you must close it when you're done with it.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function openSessions(UserName:String, User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('sessions/open/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
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
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function pingSessions(UserName:String, User_Token:String, ?Status:Null<SessionStatus>, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'sessions/ping/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token';

		if (Status != null)
			page += '&status=${Status.getName().toLowerCase()}';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Checks to see if there is an open session for the user.
	 * Can be used to see if a particular user account is active in the game.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function checkSessions(UserName:String, User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('sessions/check/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Closes the active session.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function closeSessions(UserName:String, User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('sessions/close/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
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
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function addScore(?UserName:String, ?User_Token:String, ?Guest:String, Score:String, Sort:Int, ?Extra_Data:String, ?Table_ID:Int,
			?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'scores/add/$DATA_FORMAT&game_id=$game_id';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';
		else if (Guest != null && Guest.length > 0)
			page += '&guest=$Guest';

		page += '&score=$Score&sort=$Sort';

		if (Extra_Data != null && Extra_Data.length > 0)
			page += '&extra_data=$Extra_Data';

		if (Table_ID != null)
			page += '&table_id=$Table_ID';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns the rank of a particular score on a score table.
	 *
	 * @param Sort This is a numerical sorting value that is represented by a rank on the score table.
	 * @param Table_ID The ID of the score table from which you want to get the rank.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function getScoreRank(Sort:Int, ?Table_ID:Int, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('scores/get-rank/$DATA_FORMAT&game_id=$game_id&sort=Sort&table_id=$Table_ID', false, false, Response != null ? Response.onSucceed : null,
			Response != null ? Response.onFail : null);
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
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function fetchScore(?Limit:Int = 10, ?Table_ID:Int, ?UserName:String, ?User_Token:String, ?Guest:String, ?Better_than:Int, ?Worse_than:Int,
			?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'scores/$DATA_FORMAT&game_id=$game_id';

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

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns a list of high score tables for a game.
	 *
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function scoreTables(?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('scores/tables/$DATA_FORMAT&game_id=$game_id', false, false, Response != null ? Response.onSucceed : null,
			Response != null ? Response.onFail : null);
	}

	/**
	 * Returns one or multiple trophies, depending on the parameters passed in.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Achieved Pass in true to return only the achieved trophies for a user. Pass in false to return only trophies the user hasn't achieved. Leave null to retrieve all trophies.
	 * @param Trophy_id If you would like to return just one trophy, you may pass the trophy ID with this parameter. If you do, only that trophy will be returned in the response. You may also pass multiple trophy IDs here if you want to return a subset of all the trophies. You do this as a comma-separated list in the same way you would for retrieving multiple users. Passing a `Trophy_ID` will ignore the `Achieved` parameter if it is passed.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function fetchTrophy(UserName:String, User_Token:String, ?Achieved:Null<Bool>, ?Trophy_ID:Int = 0, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'trophies/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token';

		if (Achieved != null)
			page += '&achieved=$Achieved';
		else if (Trophy_ID != null && Trophy_ID > 0)
			page += '&trophy_id=$Trophy_ID';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Sets a trophy as achieved for a particular user.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Trophy_id The ID of the trophy to add for the user.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function addTrophy(UserName:String, User_Token:String, Trophy_ID:Int, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('trophies/add-achieved/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token&trophy_id=$Trophy_ID', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Remove a previously achieved trophy for a particular user.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 * @param Trophy_id The ID of the trophy to remove from the user.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function removeTrophy(UserName:String, User_Token:String, Trophy_ID:Int, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('trophies/remove-achieved/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token&trophy_id=$Trophy_ID', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns data from the data store.
	 *
	 * @param Key The key of the data item you'd like to fetch.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function fetchDataFromDataStore(Key:String, ?UserName:String, ?User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'data-store/$DATA_FORMAT&game_id=$game_id&key=$Key';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns either all the keys in the game's global data store, or all the keys in a user's data store.
	 *
	 * @param Pattern The pattern to apply to the key names in the data store.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function getDataStoreKeys(?Pattern:String, ?UserName:String, ?User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'data-store/get-keys/$DATA_FORMAT&game_id=$game_id';

		if (Pattern != null && Pattern.length > 0)
			page += '&pattern=' + Pattern;

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=' + UserName + '&user_token=' + User_Token;

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Removes data from the data store.
	 *
	 * @param Key The key of the data item you'd like to remove.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function removeDataFromDataStore(Key:String, ?UserName:String, ?User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'data-store/remove/$DATA_FORMAT&game_id=$game_id&key=$Key';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Sets data in the data store.
	 *
	 * @param Key The key of the data item you'd like to set.
	 * @param Data The data you'd like to set.
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function setDataToDataStore(Key:String, Data:String, ?UserName:String, ?User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'data-store/set/$DATA_FORMAT&game_id=$game_id&key=$Key&data=$Data';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
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
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function updateDataFromDataStore(Key:String, Operation:String, Value:OneOfTwo<String, Int>, ?UserName:String, ?User_Token:String,
			?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'data-store/update/$DATA_FORMAT&game_id=$game_id&key=$Key&operation=$Operation&value=$Value';

		if ((UserName != null && UserName.length > 0) && (User_Token != null && User_Token.length > 0))
			page += '&username=$UserName&user_token=$User_Token';

		postData(page, false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns a list of friends of a user.
	 *
	 * @param UserName The user's username.
	 * @param User_Token The user's token.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function fetchFriends(UserName:String, User_Token:String, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('friends/$DATA_FORMAT&game_id=$game_id&username=$UserName&user_token=$User_Token', false, false,
			Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * Returns the time of the Game Jolt server.
	 *
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function fetchTime(?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		postData('time/$DATA_FORMAT&game_id=$game_id', false, false, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	/**
	 * A batch request is a collection of sub-requests that enables developers to send multiple API calls with one HTTP request.
	 *
	 * @param Parallel By default, each sub-request is processed on the servers sequentially. If this is set to true, then all sub-requests are processed at the same time, without waiting for the previous sub-request to finish before the next one is started.
	 * @param Break_On_Error If this is set to true, one sub-request failure will cause the entire batch to stop processing subsequent sub-requests and return a value of false for success.
	 * @param Requests An array of sub-request URLs. Each request will be executed and the responses of each one will be returned in the payload. You must URL-encode each sub-request.
	 *
	 * @param Response The response callbacks for success and failure cases.
	 */
	public static function batchRequest(?Parallel:Null<Bool>, ?Break_On_Error:Null<Bool>, Requests:Array<String>, ?Response:ResponseCallbacks):Void
	{
		if (!initialized)
			return;

		var page:String = 'batch/$DATA_FORMAT&game_id=$game_id';

		for (request in Requests)
			page += '&requests[]=$request';

		if (Parallel != null)
			page += '&parallel=$Parallel';
		else if (Break_On_Error != null)
			page += '&break_on_error=$Break_On_Error';

		postData(page, true, true, Response != null ? Response.onSucceed : null, Response != null ? Response.onFail : null);
	}

	@:noCompletion
	private static inline function postData(page:String, post:Bool = false, encode:Bool = false, onSucceed:Null<Dynamic->Void>, onFail:Null<String->Void>):Void
	{
		final urlPage:String = '$API_PAGE/$API_VERSION/$page';

		final urlSigniture:String = '&signature=' + Md5.encode(urlPage + private_key);

		MainLoop.addThread(makeHttpRequest.bind(urlPage + urlSigniture, post, encode, onSucceed, onFail));
	}

	@:noCompletion
	private static function makeHttpRequest(url:String, post:Bool, encode:Bool, onSucceed:Null<Dynamic->Void>, onFail:Null<String->Void>):Void
	{
		final request:Http = new Http(encode ? StringTools.urlEncode(url) : url);
		request.onStatus = function(status:Int):Void
		{
			final responseURL:Null<String> = request.responseHeaders.get('Location');

			if (responseURL != null && (status >= 300 && status < 400))
			{
				request.url = responseURL;
				request.request(post);
			}
			else if (status >= 300 && status < 400)
			{
				if (onFail != null)
					MainLoop.runInMainThread(() -> onFail('Redirect location header missing'));
			}
		}
		request.onData = function(data:String):Void
		{
			final response:Dynamic = Json.parse(data).response;

			if (response.success == 'true')
			{
				if (onSucceed != null)
					MainLoop.runInMainThread(() -> onSucceed(response));
			}
			else if (response.message != null && response.message.length > 0)
			{
				if (onFail != null)
					MainLoop.runInMainThread(() -> onFail(response.message));
			}
		}
		request.onError = function(message:String):Void
		{
			if (onFail != null)
				MainLoop.runInMainThread(() -> onFail(message));
		}
		#if js
		request.async = true;
		#end
		request.request(post);
	}

	@:noCompletion
	private static function get_initialized():Bool
	{
		return (game_id != null && game_id.length > 0) && (private_key != null && private_key.length > 0);
	}
}
