package hxgamejolt.data;

/**
 * A time object from the GameJolt API.
 */
class Time
{
	/** The UNIX time stamp (in seconds) representing the server's time. */
	public final timestamp:Int;

	/** The timezone of the server. */
	public final timezone:String;

	/** The current date. */
	public final date:Date;

	/**
	 * Initialize a time instance with data from a HTTP request.
	 * 
	 * @param data The object containing data.
	 */
	@:allow(hxgamejolt.GameJolt)
	@:nullSafety(Off)
	private function new(data:Dynamic):Void
	{
		timestamp = data.timestamp;
		timezone = data.timezone;
		date = new Date(Std.parseInt(data.year), Std.parseInt(data.month), Std.parseInt(data.day), Std.parseInt(data.hour), Std.parseInt(data.minute),
			Std.parseInt(data.second));
	}

	/**
	 * Returns a string representation of the Time object.
	 *
	 * @return A string containing all the properties of the Time object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('Timestamp: $timestamp');
		parts.push('Timezone: $timezone');
		parts.push('Date: $date');
		return parts.join('\n');
	}
}
