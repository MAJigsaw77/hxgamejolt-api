package hxgamejolt.data;

import hxgamejolt.util.OneOfTwo;

/**
 * The difficulty level of the trophy.
 */
enum abstract TrophyDifficulty(String) from String to String
{
	var Bronze = 'Bronze';
	var Silver = 'Silver';
	var Gold = 'Gold';
	var Platinum = 'Platinum';
}

/**
 * A trophy object from the GameJolt API.
 */
class Trophy
{
	/** The ID of the trophy. */
	public final id:Int;

	/** The title of the trophy. */
	public final title:String;

	/** The description of the trophy. */
	public final description:String;

	/** The difficulty level of the trophy. */
	public final difficulty:TrophyDifficulty;

	/** The URL of the trophy's thumbnail image. */
	public final imageUrl:String;

	/** Date/time when the trophy was achieved by the user, or false if not achieved. */
	public final achieved:OneOfTwo<Bool, String>;

	/**
	 * Initialize a trophy instance with data from a HTTP request.
	 * 
	 * @param data The object containing data.
	 */
	@:allow(hxgamejolt.GameJolt)
	@:nullSafety(Off)
	private function new(data:Dynamic):Void
	{
		id = Std.parseInt(data.id);
		title = data.title;
		description = data.description;
		difficulty = data.difficulty;
		imageUrl = data.image_url;
		achieved = data.achieved == 'false' ? false : data.achieved;
	}

	/**
	 * Returns a string representation of the Trophy object.
	 *
	 * @return A string containing all the properties of the Trophy object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('ID: $id');
		parts.push('Title: $title');
		parts.push('Description: $description');
		parts.push('Difficulty: $difficulty');
		parts.push('Image URL: $imageUrl');
		parts.push('Achieved: $achieved');
		return parts.join('\n');
	}
}
