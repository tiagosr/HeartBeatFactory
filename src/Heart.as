package
{
	import org.flixel.FlxG;
	import org.flixel.FlxGroupX;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	public class Heart extends FlxGroupX
	{
		public static const
		DIR_UP:int = 0,
			DIR_RIGHT:int = 1,
			DIR_DOWN:int = 2,
			DIR_LEFT:int = 3;
		
		public var spawn_list:Array = [];
		protected var next_spawn:Object = null;
		public var state:GameState;
		public var done:Boolean = false, enabled:Boolean = false;
		protected var ht:FlxSprite, hl:FlxSprite, hr:FlxSprite, hb:FlxSprite, hc:FlxSprite;
		
		public function Heart(X:Number=0, Y:Number=0, State:GameState = null)
		{
			super(X, Y);
			state = State;
			var htl:FlxSprite = new FlxSprite(-16,-16);
			ht = new FlxSprite(0,-16);
			var htr:FlxSprite = new FlxSprite(16,-16);
			hl = new FlxSprite(-16, 0);
		 	hc = new FlxSprite(0,0);
			hr = new FlxSprite(16, 0);
			var hbl:FlxSprite = new FlxSprite(-16, 16);
			hb = new FlxSprite(0,16);
			var hbr:FlxSprite = new FlxSprite(16, 16);
			_x = X;
			_y = Y;
			htl.loadGraphic(GameState.tilesheet,true,false,16,16);
			htl.addAnimation('normal',[29]);
			htl.play('normal');
			add(htl);
			ht.loadGraphic(GameState.tilesheet,true,false,16,16);
			ht.addAnimation('normal',[30]);
			ht.play('normal');
			add(ht);
			htr.loadGraphic(GameState.tilesheet,true,false,16,16);
			htr.addAnimation('normal',[31]);
			htr.play('normal');
			add(htr);
			hl.loadGraphic(GameState.tilesheet,true,false,16,16);
			hl.addAnimation('normal',[49]);
			hl.play('normal');
			add(hl);
			hc.loadGraphic(GameState.tilesheet,true,false,16,16);
			hc.addAnimation('normal',[50]);
			hc.play('normal');
			add(hc);
			hr.loadGraphic(GameState.tilesheet,true,false,16,16);
			hr.addAnimation('normal',[51]);
			hr.play('normal');
			add(hr);
			hbl.loadGraphic(GameState.tilesheet,true,false,16,16);
			hbl.addAnimation('normal',[69]);
			hbl.play('normal');
			add(hbl);
			hb.loadGraphic(GameState.tilesheet,true,false,16,16);
			hb.addAnimation('normal',[70]);
			hb.play('normal');
			add(hb);
			hbr.loadGraphic(GameState.tilesheet,true,false,16,16);
			hbr.addAnimation('normal',[71]);
			hbr.play('normal');
			add(hbr);
			this.exists = true;
		}
		
		public function click_test(x:int, y:int):Boolean {
			return hc.overlapsPoint(new FlxPoint(x,y));
		}

		public function spawnCrate(from_exit:int):Crate {
			// TODO: anim das setinhas
			var crate:Crate = new Crate(_x+[0, 16, 0, -16][from_exit], _y+[-16, 0, 16, 0][from_exit],state.current_stage_tiles);
			state.addCrate(crate);
			return crate;
		}
		
		
		public function enable():void {
			enabled = true;
		}
		
		public function trigger():void {
			if(enabled) {
				if(next_spawn != null) {
					next_spawn.ticks--;
					// TODO: anim das setinhas
					if(next_spawn.ticks == 0) {
						spawnCrate(next_spawn.from);
						next_spawn = null;
						trigger();
					}
				} else if(spawn_list.length > 0) {
					next_spawn = spawn_list.pop();
					trigger();
				} else {
					done = true;
				}
			}
		}
		
		
		

	}
}