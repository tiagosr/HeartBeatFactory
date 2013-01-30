package org.flixel
{
	public class FlxGroupX extends FlxGroup
	{
		protected var _x:int = 0, _y:int = 0;
		public function FlxGroupX(X:int, Y:int, MaxSize:uint=0)
		{
			_x = X;
			_y = Y;
			super(MaxSize);
		}
		override public function add(Object:FlxBasic):FlxBasic {
			if(Object is FlxSprite) {
				(Object as FlxSprite).x += _x;
				(Object as FlxSprite).y += _y;
			} else if (Object is FlxGroupX) {
				(Object as FlxGroupX).x += _x;
				(Object as FlxGroupX).y += _y;
			} else if (Object is FlxTilemap) {
				(Object as FlxTilemap).x += _x;
				(Object as FlxTilemap).y += _y;
			}
			return super.add(Object);
		}
		
		public function set x(nx:int):void {
			var offset:int = nx - _x;
			for each(var object:FlxBasic in members) {
				if(object is FlxSprite) {
					(object as FlxSprite).x += offset; 
				} else if (object is FlxGroupX) {
					(object as FlxGroupX).x += offset;
				} else if (object is FlxTilemap) {
					(object as FlxTilemap).x += offset;
				}
			}
			_x = nx;
		}
		public function set y(ny:int):void {
			var offset:int = ny - _y;
			for each(var object:FlxBasic in members) {
				if(object is FlxSprite) {
					(object as FlxSprite).y += offset; 
				} else if (object is FlxGroupX) {
					(object as FlxGroupX).y += offset;
				} else if (object is FlxTilemap) {
					(object as FlxTilemap).y += offset;
				}
			}
			_y = ny;
		}
		
		public function get x():int {
			return _x;
		}
		public function get y():int {
			return _y;
		}
		
	}
}