package hxgamejolt.data;

/**
 * A friend object from the GameJolt API.
 */
class Friend
{
	/** The friend's user ID. */
	public final friendId:Int;

	/**
	 * Initialize a friend instance with data from a HTTP request.
	 * 
	 * @param data The object containing data.
	 */
	@:allow(hxgamejolt.GameJolt)
	@:nullSafety(Off)
	private function new(data:Dynamic):Void
	{
		friendId = Std.parseInt(data.friend_id);
	}

	/**
	 * Returns a string representation of the Friend object.
	 *
	 * @return A string containing all the properties of the Friend object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('Friend ID: $friendId');
		return parts.join('\n');
	}
}
