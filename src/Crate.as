package
{
	import flash.utils.setTimeout;
	
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.system.FlxAnim;
	
	import stateMachine.StateMachine;
	
	public class Crate extends FlxSprite
	{
		protected var stage:Array;
		public static const 
			STATE_STOPPED:int =0,
			STATE_DOWN:int = 1,
			STATE_UP:int = 2,
			STATE_LEFT:int = 3,
			STATE_RIGHT:int = 4,
			STATE_DESTROYING:int = 5,
			STATE_DESTROYED:int = 6;
		
		private var sm:StateMachine;
		public var normalspd:FlxPoint = new FlxPoint(0,0);
		public var collect:Boolean = false;
		
		public var walkqueue:Array = [];
		public var priority_walkqueue:Array = [];
		
		public function Crate(X:Number, Y:Number, _Stage:Array)
		{
			super(X, Y);
			sm = new StateMachine();
			stage = _Stage;
			this.loadGraphic(GameState.tilesheet,true,16,16);
			this.addAnimation('normal',[260]);
			this.addAnimation('break',[260,261,262,263,264,265,266,267],10,false);
			var self:Crate = this;
			sm.addState('stop',{
				enter:function():void {
					play('normal');
				}
			});
			sm.addState('waiting');
			sm.addState('arrived', {
				enter:function():void {
					trace('chegou');
				}
			});
			sm.addState('down',{
				enter:function():void {
					play('normal');
					for(var i:int = 0; i<16; i++) {
						walkqueue.push(
							new FlxPoint(0, 1)
						);
					}
				},
				from: '*'
			});
			sm.addState('up',{
				enter:function():void {
					play('normal');
					for(var i:int = 0; i<16; i++) {
						walkqueue.push(
							new FlxPoint(0, -1)
						);
					}
				}
			});
			sm.addState('left',{
				enter:function():void {
					play('normal');
					for(var i:int = 0; i<16; i++) {
						walkqueue.push(
							new FlxPoint(-1, 0)
						);
					}
				}
			});
			sm.addState('right',{
				enter:function():void {
					play('normal');
					for(var i:int = 0; i<16; i++) {
						walkqueue.push(
							new FlxPoint(1, 0)
						);
					}
				}
			});
			sm.addState('break',{
				enter:function():void {
					play('break');
				}
			});
			sm.addState('destroyed', {
				enter:function():void {
					kill();
				}
			});
			sm.initialState = 'stop';
			
			
			addAnimationCallback(function(anim:String, frame_num:int, frame_idx:Boolean):void {
				if(finished && anim=='break') {
					sm.changeState('destroyed');
				}
			});
		}
		
		
		public function walk():void {
			if((sm.state=="break")||(sm.state=="destroyed")) return;
				var tx:int = x>>4;
				var ty:int = y>>4;
				switch(stage[ty][tx]) {
					case GameState.BELT_UD:
					case GameState.BELT_LD:
					case GameState.BELT_RD:
						sm.changeState('down');
						break;
					case GameState.BELT_DU:
					case GameState.BELT_LU:
					case GameState.BELT_RU:
						sm.changeState('up');
						break;
					case GameState.BELT_LR:
					case GameState.BELT_DR:
					case GameState.BELT_UR:
						sm.changeState('right');
						break;
					case GameState.BELT_RL:
					case GameState.BELT_DL:
					case GameState.BELT_UL:
						sm.changeState('left');
						break;
					default:
						sm.changeState('break');
			} 
		}

		private var anim_counter:Number = 0;
		override public function update():void {
			var vx:int = x >> 4;
			var vy:int = y >> 4;
			var cx:int = x;
			var cy:int = y;
			if(walkqueue.length==0 && (sm.state != 'arrived')) {
				sm.changeState('waiting');
				walk();
			}
			super.update();
			anim_counter += GameState.animspeed;
			while(anim_counter >= 1.0) {
				if(walkqueue.length > 0) {
					var pt:FlxPoint = walkqueue.pop() as FlxPoint;
					x += pt.x;
					y += pt.y;
				}
				if(priority_walkqueue.length > 0) {
					var pt:FlxPoint = priority_walkqueue.pop() as FlxPoint;
					x += pt.x;
					y += pt.y;
				}
				anim_counter -= 1.0;
			}
		}
		
		public function crash():void {
			sm.changeState('break');
		}
		private var evade_debounce:int = 0;
		public function evadePiston(dir:int):void {
			if(priority_walkqueue.length == 0) {
				for(var i:int = 0; i<4; i++) {
					priority_walkqueue.push( 
						new FlxPoint([0.0,4.0,0.0,-4.0][dir],
									 [-4.0,0.0,4.0,0.0][dir]));					
				}
			}
		}
		
		public function win(dir:int):void {
			flicker(1);
			var self:Crate = this;
			setTimeout(function(){
				self.kill();
			}, 1000);
			if(sm.state != 'arrived') {
				sm.changeState('arrived');
			}
		}
		
	}
}