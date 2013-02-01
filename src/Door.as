package
{
	import org.flixel.FlxSprite;
	
	import stateMachine.StateMachine;
	
	public class Door extends FlxSprite
	{
		
		public static const
			DIR_UP:int = 0,
			DIR_RIGHT:int = 1,
			DIR_DOWN:int = 2,
			DIR_LEFT:int = 3;
		private var dir:int = DIR_UP;
		private var nextstate:String = null;
		private var sm:StateMachine = null;
		
		public function Door(X:Number=0, Y:Number=0, direcao:int = DIR_UP, open:Boolean = true)
		{
			super(X, Y,null);
			dir = direcao;
			var f:int = [320, 280, 300, 340][dir];
			this.loadGraphic(GameState.tilesheet,true,false,16,16);
			this.addAnimation('aberto',[f]);
			this.addAnimation('fechando',[(f),(f+1),(f+2),(f+3),(f+4),(f+5)],10,false);
			this.addAnimation('abrindo',[(f+5),(f+4),(f+3),(f+2),(f+1),(f+0)],10,false);
			this.addAnimation('fechado',[(f+5)]);
			sm = new StateMachine();
			sm.addState("fechado",{
				enter: function():void {
					nextstate = null;
					play('fechado');
				},
				from:"fechando"
			});
			sm.addState("fechando", {
				enter: function():void {
					nextstate = 'fechado';
					play('fechando');
				},
				from:"aberto"
			});
			sm.addState("aberto", {
				enter: function():void {
					nextstate = null;
					play('aberto');
				},
				from:"abrindo"
			});
			sm.addState("abrindo", {
				enter: function():void {
					nextstate="aberto";
					play('abrindo');
				},
				from:"fechado"
			});
			sm.initialState = open?"aberto":"fechado";
			this.addAnimationCallback(animCallback);
					
		}


		
		private function animCallback(nome:String,frameNumber:Number,frameIndex:Number):void
		{
			if(finished)
			{
				if(nextstate!=null) {
					sm.changeState(nextstate);
				}
			}
		}
		public function toggle():void {
			if(sm.state == 'aberto') {
				sm.changeState('fechando');
			} else {
				sm.changeState('abrindo');
			}
		}
		
		public function collideWithCrate(crate:Crate):void {
			if(crate.overlaps(this)) {
				if(sm.state == 'aberto') {
					crate.win(dir);
				}
			}
		}
	}
}