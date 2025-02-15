package hxgamejolt.data;

/**
 * A score object from the GameJolt API.
 */
class Score
{
	/** The score. */
	public final score:String;

	/** The score's numerical sort value. */
	public final sort:Int;

	/** Any extra data associated with the score. */
	public final extraData:String;

	/** If this is a user score, this is the display name for the user. */
	public final user:String;

	/** If this is a user score, this is the user's ID. */
	public final userId:Int;

	/** If this is a guest score, this is the guest's submitted name. */
	public final guest:String;

	/** When the score was logged by the user. */
	public final stored:String;

	/** The timestamp (in seconds) of when the score was logged by the user. */
	public final storedTimestamp:Int;

	/**
	 * Initialize a score instance with data from a HTTP request.
	 * 
	 * @param data The object containing data.
	 */
	@:allow(hxgamejolt.GameJolt)
	@:nullSafety(Off)
	private function new(data:Dynamic):Void
	{
		score = data.score;
		sort = Std.parseInt(data.sort);
		extraData = data.extra_data;
		user = data.user;
		userId = Std.parseInt(data.user_id);
		guest = data.guest;
		stored = data.stored;
		storedTimestamp = data.stored_timestamp;
	}

	/**
	 * Returns a string representation of the Score object.
	 *
	 * @return A string containing all the properties of the Score object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('Score: $score');
		parts.push('Sort: $sort');
		parts.push('Extra Data: $extraData');
		parts.push('User: $user');
		parts.push('User ID: $userId');
		parts.push('Guest: $guest');
		parts.push('Stored: $stored');
		parts.push('Stored Timestamp: $storedTimestamp');
		return parts.join('\n');
	}
}
