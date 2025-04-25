package hxgamejolt.data;

/**
 * The type of the user.
 */
enum abstract UserType(String) from String to String
{
	var User = 'User';
	var Developer = 'Developer';
	var Moderator = 'Moderator';
	var Administrator = 'Administrator';
}

/**
 * The status of the user.
 */
enum abstract UserStatus(String) from String to String
{
	var Active = 'Active';
	var Banned = 'Banned';
}

/**
 * A user object from the GameJolt API.
 */
class User
{
	/** The ID of the user. */
	public final id:Int;

	/** The type of user. */
	public final type:UserType;

	/** The user's username. */
	public final userName:String;

	/** The URL of the user's avatar. */
	public final avatarUrl:String;

	/** How long ago the user signed up. */
	public final signedUp:String;

	/** The timestamp (in seconds) of when the user signed up. */
	public final signedUpTimestamp:Int;

	/** How long ago the user was last logged in. */
	public final lastLoggedIn:String;

	/** The timestamp (in seconds) of when the user was last logged in. */
	public final lastLoggedInTimestamp:Int;

	/** The status of the user. */
	public final status:UserStatus;

	/** The user's display name. */
	public final developerName:String;

	/** The user's website (or empty string if not specified). */
	public final developerWebsite:String;

	/** The user's profile markdown description. */
	public final developerDescription:String;

	/**
	 * Initialize a user instance with data from a HTTP request.
	 * 
	 * @param data The object containing data.
	 */
	@:allow(hxgamejolt.GameJolt)
	@:nullSafety(Off)
	private function new(data:Dynamic):Void
	{
		id = data.id;
		type = data.type;
		userName = data.username;
		avatarUrl = data.avatar_url;
		signedUp = data.signed_up;
		signedUpTimestamp = data.signed_up_timestamp;
		lastLoggedIn = data.last_logged_in;
		lastLoggedInTimestamp = data.last_logged_in_timestamp;
		status = data.status;
		developerName = data.developer_name;
		developerWebsite = data.developer_website;
		developerDescription = data.developer_description;
	}

	/**
	 * Returns a string representation of the User object.
	 *
	 * @return A string containing all the properties of the User object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('ID: $id');
		parts.push('Type: $type');
		parts.push('Username: $userName');
		parts.push('Avatar URL: $avatarUrl');
		parts.push('Signed Up: $signedUp');
		parts.push('Signed Up Timestamp: $signedUpTimestamp');
		parts.push('Last Logged In: $lastLoggedIn');
		parts.push('Last Logged In Timestamp: $lastLoggedInTimestamp');
		parts.push('Status: $status');
		parts.push('Developer Name: $developerName');
		parts.push('Developer Website: $developerWebsite');
		parts.push('Developer Description: $developerDescription');
		return parts.join('\n');
	}
}
