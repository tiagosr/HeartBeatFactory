package
{
	import org.flixel.FlxSprite;
	import org.osmf.net.StreamingURLResource;
	
	import stateMachine.StateMachine;
	
	public class Alavanca extends FlxSprite
	{
		public static const HORIZONTAL:int = 0;
		public static const VERTICAL:int = 1;
		
		private var sm:StateMachine;
				
		private var sentido:int; 
		private var nextstate:String;
		public function Alavanca(X:Number=0, Y:Number=0, Sentido:int = HORIZONTAL)
		{
			sentido = Sentido;
			super(X, Y);
			sm = new StateMachine();
			sm.addState("desligando", {
				enter: function():void {
					nextstate = "desligado";
					play('desligando');
				},
				from:"ligado"
			});
			sm.addState("ligando", {
				enter: function():void {
					nextstate = "ligado";
					play('ligando');
				},
				from: "desligado"
			});
			sm.addState("ligado", {
				enter: function():void {
					nextstate = null;
					play('ligado');
				},
				from: "ligando"
			});
			sm.addState("ligado", {
				enter: function():void {
					nextstate = null;
					play('ligado');
				},
				from: "ligando"
			});

			var f:int = sentido == HORIZONTAL? 160: 140;
			loadGraphic(GameState.tilesheet,true, false,16,16);
			addAnimation('ligado',[f]);
			addAnimation('desligado',[f+4]);
			addAnimation('ligando',[0, 1, 2, 3, 4].map(function(i,a,b):int{return f+(i as int);}),20,false);
			addAnimation('desligando',[4, 3, 2, 1, 0].map(function(i,a,b):int{return f+(i as int);}),20,false);
			addAnimationCallback(fimDaAnimacao);
			sm.initialState = 'ligando';
			
		}

		
		public function clique():void
		{
			if(sm.state == "ligado") {
				sm.changeState('ligando');
			} else if(sm.state == 'desligado')
			{
				sm.changeState('ligando');
			}
		}
		
		private function fimDaAnimacao(nome:String,frameNumber:Number,frameIndex:Number):void
		{
			if(finished){
				if(nextstate!=null) {
					sm.changeState(nextstate);
				}
			}
		}
	}
}
