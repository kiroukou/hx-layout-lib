package ee.ui.comp;

import haxe.Json;

typedef Style = {
	?backgroundTexture:String,
	?backgroundColor:ee.ui.Color,
	?outlineColor:ee.ui.Color,
	?outlineThickness:Int,
	?textColor:ee.ui.Color
}

class StyleParser
{
	public static function parse(styleContent:String):Null<Style>
	{
		if( StringTools.trim(styleContent).length == 0 ) return null;
		var raw:haxe.DynamicAccess<Dynamic> = Json.parse(styleContent);

		var style:Style = {
			textColor: ee.ui.Color.fromString(raw.get('textColor')),
			outlineColor: ee.ui.Color.fromString(raw.get('outlineColor')),
			backgroundColor : ee.ui.Color.fromString(raw.get('backgroundColor')),
			backgroundTexture:  raw.get('backgroundTexture'),
			outlineThickness: raw.get('outlineThickness')
		}
		//TODO make something safe ?
		return style;
	}
}