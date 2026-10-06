package hxgamejolt.util;

/**
 * @see https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/typeLimit/OneOfTwo.hx
 */
#if flixel
typedef OneOfTwo<T1, T2> = flixel.util.typeLimit.OneOfTwo<T1, T2>;
#else
abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}
#end