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
	private static final DATA_FORMAT:String = 'format=json';

	/** The constructed API page URL. */
	@:noCompletion
	private final urlPage:String;

	/** The constructed API request URL. */
	@:noCompletion
	private final urlRequest:String;

	/** The private key required for the URL signature. */
	@:noCompletion
	private final urlPrivateKey:String;

	/** The HTTP instance for requesting data from the API */
	@:noCompletion
	private var urlRequestHttp:Null<Http>;

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
		urlRequest = Path.join(['/', path, '?' + [DATA_FORMAT].concat(parameters).join('&')]);
		urlPrivateKey = privateKey;
	}

	/**
	 * Initiates an HTTP request to the GameJolt API asynchronously.
	 */
	public function requestData():Void
	{
		urlRequestHttp = new Http(createRequest(Path.join([urlPage, urlRequest])));

		#if (js && !HXGAMEJOLT_NO_THREADING)
		urlRequestHttp.async = true;
		#end

		urlRequestHttp.onStatus = function(status:Int):Void
		{
			if (urlRequestHttp != null)
			{
				if (status >= 300 && status < 400)
				{
					final responseURL:Null<String> = urlRequestHttp.responseHeaders.get('Location');

					if (responseURL != null && responseURL.length > 0)
					{
						urlRequestHttp.url = responseURL;

						#if !HXGAMEJOLT_NO_THREADING
						MainLoop.addThread(function():Void
						{
							if (urlRequestHttp != null)
								urlRequestHttp.request();
						});
						#else
						urlRequestHttp.request();
						#end
					}
					else
						dispatchFail('Redirect location header missing');
				}
			}
		}

		urlRequestHttp.onData = (data:String) -> dispatchData(Json.parse(data).response);

		urlRequestHttp.onError = (message:String) -> dispatchFail(message);

		#if !HXGAMEJOLT_NO_THREADING
		MainLoop.addThread(function():Void
		{
			if (urlRequestHttp != null)
				urlRequestHttp.request();
		});
		#else
		urlRequestHttp.request();
		#end
	}

	@:noCompletion
	private function dispatchData(response:Dynamic):Void
	{
		if (response.success == 'true')
		{
			Reflect.deleteField(response, 'success');

			if (onSucceed != null)
				onSucceed(response);
		}
		else if (response.message != null && response.message.length > 0)
		{
			if (onFail != null)
				onFail(response.message);
		}
	}

	@:noCompletion
	private function dispatchFail(message:String):Void
	{
		if (onFail != null)
			onFail(message);
	}

	@:noCompletion
	private inline function createRequest(url:String):String
	{
		return url + createSigniture(url);
	}

	@:noCompletion
	private inline function createBatchRequest(url:String):String
	{
		return StringTools.urlEncode(createRequest(StringTools.replace(url, '${GameJoltHttp.DATA_FORMAT}&', '')));
	}

	@:noCompletion
	private inline function createSigniture(url:String):String
	{
		return '&signature=' + Md5.encode(url + urlPrivateKey);
	}
}
