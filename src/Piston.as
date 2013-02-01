package
{
	import org.flixel.FlxGroupX;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	import stateMachine.*;
	
	public class Piston extends FlxGroupX
	{
		
		public static const
			DIR_UP:int = 0,
			DIR_RIGHT:int = 1,
			DIR_DOWN:int = 2,
			DIR_LEFT:int = 3;
		private var dir:int = DIR_UP;
		private var pspr:FlxSprite;
		private var bspr:FlxSprite;
		
		private var nextstate:String;
		private var sm:StateMachine;
		
		public function Piston(X:Number=0, Y:Number=0, direction:int=DIR_UP, open:Boolean = true)
		{
			super(X, Y);
			dir = direction;
			var f:int = (function(d:int):int {
				return [180, 200, 220, 240][d];
			})(direction);
			var f2:int = (function(d:int):int {
				return [40, 20, 40, 20][d];
			})(direction);
			
			pspr = new FlxSprite((dir==DIR_LEFT)?-16:((dir==DIR_RIGHT)?16:0),
				(dir==DIR_UP)?-16:((dir==DIR_DOWN)?16:0));
			
			pspr.loadGraphic(GameState.tilesheet,true,false,16,16);
			pspr.addAnimation('abrindo',[19, 9, 8, 7, 6, 5, 4, 3, 2].map(function(i:*, a,b):int {
				return f+(i as int);
			}),30,false);
			pspr.addAnimation('aberto',[10, 11, 12, 13, 14, 15, 16, 17].map(function(i:*, a,b):int {
				return f+(i as int);
			}),30, true);
			pspr.addAnimation('guardando',[2, 3, 4, 5, 6, 7, 8, 9, 19].map(function(i:*, a,b):int {
				return f+(i as int);
			}),30,false);
			pspr.addAnimation('guardado',[19],0, false);
			pspr.addAnimationCallback(function(anim:String,b,c) {
				if(pspr.finished) {
					if(nextstate != null) {
						sm.changeState(nextstate);
					}
				}
			});
			
			bspr = new FlxSprite(0,0);
			bspr.loadGraphic(GameState.tilesheet,true,false,16,16);
			bspr.addAnimation('liga',[f+1],0,false);
			bspr.addAnimation('desliga',[f],0,false);
			add(bspr);
			add(pspr);
			
			sm = new StateMachine();
			sm.addState("guardado",{
				enter: function():void {
					nextstate = null;
					pspr.play('guardado');
					bspr.play('desliga');
				},
				from:"guardando"
			});
			sm.addState("guardando", {
				enter: function():void {
					nextstate = 'guardado';
					pspr.play('guardando');
					bspr.play('desliga');
				},
				from:"aberto"
			});
			sm.addState("aberto", {
				enter: function():void {
					nextstate = null;
					pspr.play('aberto');
					bspr.play('liga');
				},
				from:"abrindo"
			});
			sm.addState("abrindo", {
				enter: function():void {
					nextstate="aberto";
					pspr.play('abrindo');
					bspr.play('liga');
				},
				from:"guardado"
			});
			sm.initialState = open?"aberto":"guardado";
		}
		public function go(state:String) {
			sm.changeState(state);
		}
		public function collideWithCrate(crate:Crate):void {
			if(sm.state == "abrindo") {
				if(crate.overlaps(pspr)) {
					//trace("moveu");
					crate.evadePiston(dir);
				}
			}else if(sm.state == "guardado") {
				
			} else {
				if(crate.overlaps(pspr)) {
					//trace("quebrou");
					//crate.crash();
					crate.evadePiston(dir);
				}				
			}
		}
		public function mouseHitTest(cursor:FlxObject):Boolean {
			
			return bspr.overlaps(cursor); //tá sempre on-screen
		}
		
		public function trigger():void {
			if(sm.state == 'guardado') {
				sm.changeState('abrindo');
			} else {
				sm.changeState('guardando');
			}
		}
		

	}
}