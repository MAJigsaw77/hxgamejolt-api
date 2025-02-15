package hxgamejolt.util;

import haxe.io.Path;
import haxe.crypto.Md5;
import haxe.Http;
import haxe.Json;
import haxe.MainLoop;

/**
 * A generic HTTP handler for interacting with the GameJolt API.
 */
class GameJoltHttp
{
	/** The base URL for the GameJolt API. */
	@:noCompletion
	private static final API_PAGE:String = 'https://api.gamejolt.com/api/game';

	/** The API version to be used for requests. */
	@:noCompletion
	private static final API_VERSION:String = 'v1_2';

	/** The data format to be appended to API requests. */
	@:noCompletion
	private static final DATA_FORMAT:String = '?format=json';

	/** The constructed API page URL. */
	@:noCompletion
	private final urlPage:String;

	/** The constructed API request URL. */
	@:noCompletion
	private final urlRequest:String;

	/** The API request URL with an added security signature. */
	@:noCompletion
	private final urlSigniture:String;

	/** The HTTP instance for requesting data from the API */
	@:noCompletion
	private final urlRequestHttp:Http;

	/**
	 * Callback function to be executed on a successful request.
	 * 
	 * @param data The parsed JSON response from the API.
	 */
	public var onSucceed:Null<(data:Dynamic) -> Void>;

	/**
	 * Callback function to be executed on a failed request.
	 * 
	 * @param message The error message describing the failure.
	 */
	public var onFail:Null<(message:String) -> Void>;

	/**
	 * Constructs a new GameJoltHttp request object.
	 *
	 * @param path The specific path of the GameJolt API.
	 * @param parameters An array of query parameters to be appended to the request.
	 * @param privateKey The private key used for API authentication.
	 */
	@:allow(hxgamejolt.GameJolt)
	private function new(path:String, parameters:Array<String>, privateKey:String):Void
	{
		urlPage = Path.join([API_PAGE, API_VERSION]);
		urlRequest = Path.join([path, [DATA_FORMAT].concat(parameters).join('&')]);
		urlSigniture = '&signature=' + Md5.encode(Path.join([urlPage, urlRequest]) + privateKey);

		urlRequestHttp = new Http(Path.join([urlPage, urlRequest]) + urlSigniture);
		#if (js && !HXGAMEJOLT_NO_THREADING)
		urlRequestHttp.async = true;
		#end
		urlRequestHttp.onStatus = function(status:Int):Void
		{
			final responseURL:Null<String> = urlRequestHttp.responseHeaders.get('Location');

			if (responseURL != null && (status >= 300 && status < 400))
			{
				urlRequestHttp.url = responseURL;
				urlRequestHttp.request();
			}
			else if (status >= 300 && status < 400)
			{
				if (onFail != null)
					MainLoop.runInMainThread(onFail.bind('Redirect location header missing'));
			}
		}
		urlRequestHttp.onData = function(data:String):Void
		{
			final response:Dynamic = Json.parse(data).response;

			if (response.success == 'true')
			{
				Reflect.deleteField(response, 'success');

				if (onSucceed != null)
					MainLoop.runInMainThread(onSucceed.bind(response));
			}
			else if (response.message != null && response.message.length > 0)
			{
				if (onFail != null)
					MainLoop.runInMainThread(onFail.bind(response.message));
			}
		}
		urlRequestHttp.onError = function(message:String):Void
		{
			if (onFail != null)
				MainLoop.runInMainThread(onFail.bind(message));
		}
	}

	/**
	 * Initiates an HTTP request to the GameJolt API asynchronously.
	 */
	public function requestData():Void
	{
		#if !HXGAMEJOLT_NO_THREADING
		MainLoop.addThread(urlRequestHttp.request.bind());
		#else
		urlRequestHttp.request();
		#end
	}
}
