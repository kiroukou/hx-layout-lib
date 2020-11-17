package ee.ui.comp;

import haxe.Json;

@:enum 
abstract TextureMode(String) {
	var Repeat = 'repeat';
	var None = '';
	var Scale = 'scale';	
}
@:enum 
abstract TextAlign(String) {
	var Left = 'left';
	var Center = 'center';
	var Right = 'right';	
}

typedef Decoration = {
	?texture:String,
	?backgroundTexture:String,
	?backgroundTextureMode:TextureMode,
	?backgroundColor:ee.ui.Color,

	?outlineColor:ee.ui.Color,
	?outlineThickness:Int,
	
	?color:ee.ui.Color,
	?textColor:ee.ui.Color,
	?fontSize:Int,
	?fontName:String,
	?textAlign:TextAlign,
}

typedef Style = {
	> Decoration,
	?component:String,
	?textureMode:TextureMode,
	?states: {
		?hover:Style,
		?click:Style,
	}
}
