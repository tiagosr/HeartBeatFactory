package
{
	public class Stage
	{
		public static const TILES_WIDE:int = 20, TILES_HIGH:int = 16;
		public static const 
			GROUND_:int = 0,
			BELT_RL:int = 1,
			BELT_LR:int = 2,
			BELT_DU:int = 3,
			BELT_UD:int = 4,
			BELT_UL:int = 5,
			BELT_LU:int = 6,
			BELT_UR:int = 7,
			BELT_RU:int = 8,
			BELT_DL:int = 9,
			BELT_LD:int = 10,
			BELT_DR:int = 11,
			BELT_RD:int = 12,
			PLACE__:int = 13;
			
		public static var TILES_MAP:Array = [
			/* GROUND_ */ {tile:0, ch:'.', anim:[0]},
			/* BELT_RL */ {tile:20, ch:'<', anim:[0, 1, 2, 3, 4, 5, 6, 7]},
			/* BELT_LR */ {tile:20, ch:'>', anim:[7, 6, 5, 4, 3, 2, 1, 0]},
			/* BELT_DU */ {tile:40, ch:'A', anim:[0, 1, 2, 3, 4, 5, 6, 7]},
			/* BELT_UD */ {tile:40, ch:'V', anim:[7, 6, 5, 4, 3, 2, 1, 0]},
			/* BELT_UL */ {tile:60, ch:'d', anim:[7, 6, 5, 4, 3, 2, 1, 0]},
			/* BELT_LU */ {tile:60, ch:'J', anim:[0, 1, 2, 3, 4, 5, 6, 7]},
			/* BELT_UR */ {tile:80, ch:'b', anim:[0, 1, 2, 3, 4, 5, 6, 7]},
			/* BELT_RU */ {tile:80, ch:'L', anim:[7, 6, 5, 4, 3, 2, 1, 0]},
			/* BELT_DL */ {tile:100, ch:'q', anim:[7, 6, 5, 4, 3, 2, 1, 0]},
			/* BELT_LD */ {tile:100, ch:'j', anim:[0, 1, 2, 3, 4, 5, 6, 7]},
			/* BELT_DR */ {tile:120, ch:'p', anim:[0, 1, 2, 3, 4, 5, 6, 7]},
			/* BELT_RD */ {tile:120, ch:'r', anim:[7, 6, 5, 4, 3, 2, 1, 0]},
			/* PLACE__ */ {tile:2, ch:'+', anim:[0]},
			
		];
		
		public static var TILE_NUMS:Array = [
			GROUND_,
			BELT_RL, BELT_LR, BELT_DU, BELT_UD,
			BELT_UL, BELT_LU, BELT_UR, BELT_RU,
			BELT_DL, BELT_LD, BELT_DR, BELT_RD,
			PLACE__
		];
		
		public static var EDIT_TILES:Array = [
			GROUND_,
			BELT_RL, BELT_LR, BELT_DU, BELT_UD,
			BELT_UL, BELT_LU, BELT_UR, BELT_RU,
			BELT_DL, BELT_LD, BELT_DR, BELT_RD,
			PLACE__, GROUND_, 			
		];
		public static var ANIM_OFFSETS:Object = null;
		public static var TILES:Object = {};
		public static var TILE_CHARS:Array = [];
		public static var TILE_C:Array = [];
			
		public var tiles:Array;
		public var name:String;
		public var doors:Array;
		public var pistons:Array;
		public var sequence:Array;
		public var lastframe:int;
		public var anim_tiles:Array;
		
		public function Stage(tiles:Array,
							  name:String,
							  sequence:Array,
							  doors:Array,
							  pistons:Array)
		{
			this.tiles = tiles;
			this.name = name;
			this.sequence = sequence;
			this.doors = doors;
			this.pistons = pistons;
			this.lastframe = -1;
			this.anim_tiles = [];
			makeAnimTiles(0);
		}
		
		static public function fromString(string:String,
										  name:String,
										  sequence:Array,
										  doors:Array,
										  pistons:Array):Stage {
			return new Stage(,name,sequence,doors,pistons);
		}
		
		static public function fillTileStructs():void {
			if (ANIM_OFFSETS == null) {
				/* setup dos mapas */
				ANIM_OFFSETS = {};
				for (var i:int = 0; i < TILES_MAP.length; i++) {
					var t:Object = TILES_MAP[i];
					
					ANIM_OFFSETS[t.ch] = t.anim;
					//trace("ch: "+t.ch+" anim: "+t.anim);
					TILES[t.ch] = i;
					TILE_CHARS[i] = t.tile;
					TILE_C[i] = t.ch;
				}
			}
		}
		
		public function getTile(x:int, y:int):int {
			return tiles[Math.min(TILES_HIGH,Math.max(0,y))][Math.min(TILES_WIDE,Math.max(0,y))];
		}
		
		
		public function makeAnimTiles(frame:int):Array {
			var tile:int, curtile:Number;
			if(lastframe != frame) {
				for(var y:int = 0; y < TILES_HIGH; y++) {
					anim_tiles[y]=[];
					tile = tiles[y][x];
					curtile = TILE_CHARS[tile];
					for(var x:int = 0; x < TILES_WIDE; x++) {
						if(TILE_C[tile] in ANIM_OFFSETS) { 
							var anim:Array = ANIM_OFFSETS[TILE_C[tile]];
							var animfr:Number = (frame) % (anim.length);
							anim_tiles[y][x] = curtile + animfr;
						} else {
							anim_tiles[y][x] = curtile;
						}
					}
				}
				lastframe = frame;
			}
			return anim_tiles;
		}
		
		public function getAnimTiles(frame:int):Array {
			var tile:int, curtile:Number;
			if(lastframe != frame) {
				for(var y:int = 0; y < TILES_HIGH; y++) {
					anim_tiles[y]=[];
					tile = tiles[y][x];
					curtile = TILE_CHARS[tile];
					for(var x:int = 0; x < TILES_WIDE; x++) {
						if(TILE_C[tile] in ANIM_OFFSETS) { 
							var anim:Array = ANIM_OFFSETS[TILE_C[tile]];
							var animfr:Number = (frame) % (anim.length);
							anim_tiles[y][x] = curtile + animfr;
						}
					}
				}
				
				lastframe = frame;
			}
			return anim_tiles;
		}
		
	}
}