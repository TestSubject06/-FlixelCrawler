package scenes
{
	import org.flixel.FlxState;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	
	

    public class PlayState extends FlxState
    {	
		/**** VARIABLES ****/
		public var totalElapsed :Number;


		
		
		override public function create() : void
		{
			totalElapsed = 0.0;
			
			/*			
			lyrBackground3 = new FlxGroup();
			lyrBackground3.scrollFactor.x = .25;
			lyrBackground3.scrollFactor.y = .25;
			lyrBackground2 = new FlxGroup();
			lyrBackground2.scrollFactor.x = .5;
			lyrBackground2.scrollFactor.y = .5;
			lyrBackground1 = new FlxGroup();
			lyrBGEntities = new FlxGroup();
			lyrFGEntities = new FlxGroup();
			lyrProjectiles = new FlxGroup();
			lyrForeground = new FlxGroup();
			lyrGUI = new FlxGroup();
			lyrGUI.scrollFactor.x = 0;
			lyrGUI.scrollFactor.y = 0;
			
			add(lyrBackground3);
			add(lyrBackground2);
			add(lyrBackground1);
			add(lyrBGEntities);
			add(lyrFGEntities);
			add(lyrProjectiles);
			add(lyrForeground);
			add(lyrGUI);
			*/
			
			//player = new Player(0, 0);
		}
		
		
		
		override public function update() :void
		{
			super.update(); // before? or after?
			totalElapsed += FlxG.elapsed;
		}
	}
}