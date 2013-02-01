package
{
	
	import caurina.transitions.Tweener;
	
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroupX;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSave;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxTilemap;
	
	import stateMachine.StateMachine;
	
	public class GameState extends FlxState
	{
		[Embed(source="tilesheet.png")] public static const tilesheet:Class;
		private var scene:FlxTilemap = null;
		private var bg:FlxTilemap = null;
		private var stagexml:XML = null;
		private var stages:Array = new Array();
		private var stage_props:Array = new Array();
		private var current_stage_num:int = -1; // pra fazer o setup do primeiro stage.
		private var current_stage:String = null;
		public var current_stage_tiles:Array = null;
		private var current_stage_tile_speeds:Array = null;
		private var current_stage_current_frames:Array = null;
		
		private var current_crates:Array = [];
		private var current_pistons:Array = [];
		private var current_doors:Array = [];

		private var game_save:FlxSave;
		private var save_btn:FlxButton;
		
		private var pump:Heart;
		
		//private var piston:Pistao;
		
		private var editing:Boolean = false;
		private var editCursor:FlxSprite;
		
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
		public static var ANIM_OFFSETS:Object = {};
		public static var TILES:Object = {};
		public static var TILE_CHARS:Array = [];
		public static var TILE_C:Array = [];
		
		public var sm:StateMachine;
		
		public static function makeStageArrayFromString(str:String):Array {
			var stagearr:Array = new Array();
			var stagerowarr:Array = new Array();
			
			for (var i:int = 0; i<str.length; i++) {
				var t:String = str.charAt(i);
				if (t == '\n') {
					stagearr[stagearr.length] = stagerowarr;
					stagerowarr = new Array();
				} else if (t in TILES) {
					stagerowarr.push(TILES[t]);
				}
			}
			return stagearr;
		}
		public static function makeStageStringFromArray(stagearr:Array):String {
			return stagearr.map(function(arr:*, ind:int, array:Array):String {
				return (arr as Array).map(function(num:*, ind:int, array:Array):String {
					return TILE_C[num as uint];
				}).join('');
			}).join("\n");
		}
		
		public static function makeStageFromArray(stagearr:Array):String {
			var resultstr:String = stagearr.map(function(arr:*, ind:int, array:Array):String {
				var xarr:Array = (arr as Array).map(function(item:*, ind:int, array:Array):int {
					return TILE_CHARS[item as int];
				});
				return FlxTilemap.arrayToCSV(xarr,xarr.length);
			}).join('\n');
			return resultstr;
		}
		
		public static var animspeed:Number = 0.25;
		public var title_card:FlxTilemap;
		public var title_screen:FlxGroupX;
		
		private var crate_spawn_list:Array = [];
		
		override public function create():void {
			/* setup dos mapas */
			for (var i:int = 0; i < TILES_MAP.length; i++) {
				var t:Object = TILES_MAP[i];
				
				ANIM_OFFSETS[t.ch] = t.anim;
				//trace("ch: "+t.ch+" anim: "+t.anim);
				TILES[t.ch] = i;
				TILE_CHARS[i] = t.tile;
				TILE_C[i] = t.ch;
			}
			
			sm = new StateMachine();
			sm.addState("titlescreen", {
				enter:function():void {
					Tweener.addTween(title_screen, {x:0.0, time:1.0});
				}
			});
			
			sm.addState("ingame", {
				enter:function():void {
					Tweener.addTween(title_screen, {x: -320.0, time:1.0});
				},				
				parent: "titlescreen"
			});
			
			FlxG.mouse.show();
			game_save = new FlxSave();
			game_save.bind("BeltStages");
			delete(game_save.data["stages"]);
			bg = new FlxTilemap();
			scene = new FlxTilemap();
			title_card = new FlxTilemap();
			var bgmap:Array = [];
			for (var j:int = 0; j<16; j++) {
				bgmap[j] = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
			}
			
			bg.loadMap(bgmap.map(function(i,a,b):String {
				return FlxTilemap.arrayToCSV(i as Array,(i as Array).length);
			}).join("\n"), tilesheet,16, 16);
			
			setupStage(0);
			var title_card_map:Array = [
				[89,90,91,92,93,94],
				[109,110,111,112,113,114],
				[129,130,131,132,133,134]
			];
			title_card.loadMap(title_card_map.map(function(i,a,b):String {
				return FlxTilemap.arrayToCSV(i as Array,(i as Array).length);
			}).join("\n"), tilesheet,16, 16);
			
			add(bg);
			add(scene);
			
			
			editCursor = new FlxSprite(0,0);
			editCursor.loadGraphic(tilesheet,true,false,16,16);
			for each(var anim:* in TILES_MAP) {
				editCursor.addAnimation(anim.ch,anim.anim.map(function(frame:*, ind:int, arr:Array):int{
					return anim.tile+(frame as int);
				}), 20, true);
			}
			add(editCursor);
			editCursor.visible = false;
			
			/*
			var firstcrate:Crate = new Crate(32,32,current_stage_tiles);
			current_crates.push(firstcrate);
			add(firstcrate);
			*/
			pump = new Heart(160,128,this);
			add(pump);
			
			/*
			var piston:Pistao = new Pistao(192, 192, Pistao.DIR_LEFT);
			add(piston);
			current_pistons.push(piston);
			var piston2:Pistao = new Pistao(160, 192, Pistao.DIR_UP, false);
			add(piston2);
			current_pistons.push(piston2);*/
			
			/*var door:Porta = new Porta(80, 0);
			add(door);
			current_doors.push(door);*/
			
			title_screen = new FlxGroupX(0,0);
			
			title_card.x = 8;
			title_card.y = 176;
			var text0:FlxText = new FlxText(6, 160, 200, "Click to begin play");
			text0.shadow = 0xff000000;
			title_screen.add(text0);
			title_screen.add(title_card);
			var text1:FlxText =new FlxText(6, 226, 200, "a game for the 2013 Global Game Jam\nby Tiago Rezende & Bruno Ferraz"); 
			text1.shadow = 0xff000000;
			title_screen.add(text1);
			var text2:FlxText = new FlxText(96, 2, 260, "<- bring crates to this moving door,\nbut avoid letting them fall off of the tracks");
			text2.shadow = 0xff000000;
			title_screen.add(text2);
			var text3:FlxText = new FlxText(176, 66, 260, "<- drag these pistons to\nthe other marked places\nto displace the crates");
			text3.shadow = 0xff000000;
			title_screen.add(text3);
			add(title_screen);
			sm.initialState = 'titlescreen';
		}
		
		public var frame_sync:Number = 0;
		
		private function loadStage(stagenum:int):String {
			if ("stages" in game_save.data) {
				stages = game_save.data["stages"];
				if(current_stage_num >= 0) {
					stages[current_stage_num] = makeStageStringFromArray(current_stage_tiles);
					game_save.data["stages"];
				}
			} else {

				stages[0] = 
					"....................\n"+
					"....r<<<<<q.........\n"+
					"....V.....A.........\n"+
					"....V...VpJ.rq......\n"+
					"....b>>jVA+.VA......\n"+
					".......VVL<<dA......\n"+
					".......Vd.A..A......\n"+
					".......V..A..A......\n"+
					".......V<<.>>A......\n"+
					".......V..V..A......\n"+
					".......V..V.pA......\n"+
					".......V..V.AA+.....\n"+
					".......V..b>JA......\n"+
					".......b>>>>>J......\n"+
					"........+++++.......\n"+
					"....................\n"+
					"....................";
				stage_props[0] = {
					name: "Stage 1 / Presentation",
					crate_sequence: [
						[1, Heart.DIR_UP],
						[1, Heart.DIR_RIGHT],
						[1, Heart.DIR_DOWN],
						[1, Heart.DIR_LEFT]
					],
					doors: [
						[5,0, Door.DIR_UP]
					],
					pistons: [
						[17, 3, Piston.DIR_LEFT],
					],
					requirements: 4
				};
				stages[1] = 
					"....................\n"+
					"....r<<<<<q.........\n"+
					"....V.....A.........\n"+
					"....V...VpJ.rq......\n"+
					"....b>>jVA+.VA......\n"+
					".......VVL<<dA......\n"+
					".......Vd.A..A......\n"+
					".......V..A..A......\n"+
					".......V<<.>>A......\n"+
					".......V..V..A......\n"+
					".......V..V.pA......\n"+
					".......V..V.AA+.....\n"+
					".......V..b>JA......\n"+
					".......b>>>>>J......\n"+
					"........+++++.......\n"+
					"....................\n"+
					"....................";
				stage_props[1] = {
					name: "Stage 2 / Presentation",
					crate_sequence: [
						[1, Heart.DIR_UP],
						[1, Heart.DIR_RIGHT]
					],
					doors: [
						[5,0, Door.DIR_UP]
					],
					pistons: [
					],
					requirements: 1
				};
				game_save.data["stages"] = stages;
				
			}
import org.flixel.FlxPoint;
			
			current_stage_current_frames = new Array();
			current_stage_tile_speeds = new Array();
			for(var y:uint = 0; y < 16; y++) {
				current_stage_current_frames[y] = new Array();
				current_stage_tile_speeds[y] = new Array();
				for(var x:uint = 0; x < 20; x++) {
					current_stage_current_frames[y][x] = 0.0;
					current_stage_tile_speeds[y][x] = 1.0;
				}
			}
			current_stage_tiles = makeStageArrayFromString(stages[stagenum]);
			
			return current_stage = stages[stagenum] as String;
		}
		
		public function setupStage(stagenum:int):void {
			for each(var piston:Piston in current_pistons) {
				remove(piston);
			}
			for each(var door:Door in current_doors) {
				remove(door);
			}
			for each(var crate:Crate in current_crates) {
				remove(crate);
			}			
			scene.loadMap(makeStageFromArray(makeStageArrayFromString(loadStage(stagenum))),tilesheet,16,16);
			for each (var seq:Array in stage_props[stagenum].create_sequence) {
					
			}
			for each (var doordata:Array in stage_props[stagenum].doors) {
				addDoor(new Door(16*doordata[0],16*doordata[1],doordata[2],doordata[3]));
			}
			for each (var pistondata:Array in stage_props[stagenum].pistons) {
				addPiston(new Piston(16*doordata[0],16*doordata[1],doordata[2],doordata[3]));
			}
		}
		
		private var mapx:uint, mapy:uint;
		private var debounce:Boolean = false, kdebounce:Boolean = false, ekdebounce:Boolean = false;
		private var current_edit_tile:uint = 1;
		private var dragged_piston:Piston = null;
		private var sync_debounce:Boolean = false;
		private var dragged_piston_back:FlxPoint = null;
		override public function update():void {
			mapx = int(Math.min(19,Math.max(0,FlxG.mouse.screenX >> 4)));
			mapy = int(Math.min(15,Math.max(0,FlxG.mouse.screenY >> 4)));
			
			editCursor.x = mapx * 16;
			editCursor.y = mapy * 16;
			
			if (editing) { // edit mode
				if(FlxG.mouse.pressed() && !debounce) {
					current_stage_tiles[mapy][mapx] = EDIT_TILES[current_edit_tile];
					scene.setTile(mapx,mapy,TILE_CHARS[EDIT_TILES[current_edit_tile]],true);
					debounce = true;
				} else {
					debounce = false;
				}
				
				if(FlxG.keys.UP) {
					current_edit_tile = ((current_edit_tile + 1) % (EDIT_TILES.length));
					editCursor.play(TILE_C[EDIT_TILES[current_edit_tile]]);
					FlxG.keys.UP = false; // debounce
				}
				if(FlxG.keys.DOWN) {
					current_edit_tile = ((current_edit_tile - 1) % (EDIT_TILES.length));
					editCursor.play(TILE_C[EDIT_TILES[current_edit_tile]]);
					FlxG.keys.DOWN = false; // debounce
				}
			} else { // game mode
				if (FlxG.mouse.pressed() && (dragged_piston != null)) {
					dragged_piston.x = editCursor.x;
					dragged_piston.y = editCursor.y;
				} else if (FlxG.mouse.pressed() && !debounce) {
					
					if(sm.state == 'titlescreen') {
						sm.trace_info = true;
						sm.changeState('ingame');
						debounce = true;
					} else {
						if (pump.click_test(FlxG.mouse.x, FlxG.mouse.y)) {
							pump.enable();
						}
						for each (var piston:Piston in current_pistons) {
							if(piston.mouseHitTest(editCursor)) {
								dragged_piston = piston;
								dragged_piston_back = new FlxPoint(piston.x,piston.y);
							}
						}
						if (dragged_piston == null) {
							debounce = true;
						}
						
					}
				} else {
					if(dragged_piston!=null) {
						var cx:int = dragged_piston.x/16;
						var cy:int = dragged_piston.y/16;
						if(current_stage_tiles[cy][cx] != PLACE__) {
							dragged_piston.x = dragged_piston_back.x;
							dragged_piston.y = dragged_piston_back.y;
						}
						dragged_piston = null;
					}
					debounce = false;
				}
				
				if(FlxG.keys.UP && !kdebounce) {
					crate_spawn_list.unshift(Heart.DIR_UP);
					FlxG.keys.UP = false;
				}
				if(FlxG.keys.DOWN && !kdebounce) {
					crate_spawn_list.unshift(Heart.DIR_DOWN);
					FlxG.keys.DOWN = false;
				}
				if(FlxG.keys.LEFT && !kdebounce) {
					crate_spawn_list.unshift(Heart.DIR_LEFT);
					FlxG.keys.LEFT = false;
				} else if(FlxG.keys.RIGHT && !kdebounce) {
					crate_spawn_list.unshift(Heart.DIR_RIGHT);
					FlxG.keys.RIGHT = false;
				}
				
			}
			
			if(FlxG.keys.E) {
				editing = !editing;
				editCursor.visible = editing;
				FlxG.keys.E = false;
			}
			if (FlxG.keys.S) {
				stages[current_stage_num] = makeStageStringFromArray(current_stage_tiles);
				game_save.data["stages"] = stages;
				trace("stage:\n"+stages[current_stage_num]);
				
				FlxG.keys.S = false;
			}
			
			
			
			if (int(frame_sync)%64==0) { // fine tuning do sincronismo dos pistões
				if(!sync_debounce) {
					for each(var piston:Piston in current_pistons) {
						piston.trigger();
					}
					for each(var door:Door in current_doors) {
						door.toggle();
					}
					if (crate_spawn_list.length > 0) {
						pump.spawnCrate(crate_spawn_list.pop());
					}
					sync_debounce = true;
				}
			} else {
				sync_debounce = false;
			}
			
			for each (var crate:Crate in current_crates) {
				if(crate.alive) {
					for each(var piston:Piston in current_pistons) {
						piston.collideWithCrate(crate);
					}
					for each(var door:Door in current_doors) {
						door.collideWithCrate(crate);
					}
				}
			}
			
			
			
			// animação dos tiles
			for(var y:uint = 0; y < 16; y++) {
				for(var x:uint = 0; x < 20; x++) {
					var tile:int = current_stage_tiles[y][x];
					var curtile:Number = TILE_CHARS[tile];
					if(TILE_C[tile] in ANIM_OFFSETS) {
						var anim:Array = ANIM_OFFSETS[TILE_C[tile]];
						var animfr:Number = (frame_sync) % (anim.length);
						current_stage_current_frames[y][x] = animfr;
						scene.setTile(x, y, int(curtile+anim[int(animfr)]));
					}
				}
			}
			
			frame_sync = (frame_sync+animspeed);
			if (frame_sync > 1024) frame_sync -= 1024.0;
			scene.update();
			super.update();
		}
		
		public function addCrate(crate:Crate):void {
			add(crate);
			current_crates.push(crate);
		}
		
		public function addDoor(door:Door):void {
			add(door);
			current_doors.push(door);
		}
		
		public function addPiston(piston:Piston):void {
			add(piston);
			current_pistons.push(piston);
		}
		
		override public function draw():void {
			super.draw();
			if (editing) {
				editCursor.drawDebug();
			}
		}
		
	}
}