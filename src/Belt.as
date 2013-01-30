package
{
	/*
	 * Belt (codename)
	 * A game for the 2013 Global Game Jam
	 * by Tiago Rezende & Bruno Ferraz
	 *
	 * Made with Flixel, AS3-State-Machine and the Flex SDK
	 */
	import flash.display.Sprite;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGame;

	[SWF(width='640',height='512',backgroundColor='#000000',frameRate='60')]
	public class Belt extends FlxGame
	{
		public function Belt()
		{
			super(320,256,GameState,2);
		}
	}
}