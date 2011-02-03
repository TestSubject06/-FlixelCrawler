package states
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import game.*;
	
	

    public class PlayState extends FlxState
    {	
		/**** VARIABLES ****/
		public var totalElapsed :Number;


		
		
		override public function create() : void
		{
			totalElapsed = 0.0;
			
			// This is how I typically handle layers
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
			
			// And now for some random hacky stuff to get something to display!
			FlxG.play(ResourceManager.RANDOM_SONG, 1.0, true); // this song doesn't fit at allLOL
			add(new FlxSprite(0, 0, ResourceManager.GFX_MOCK_RPG));
			add(new FlxSprite(FlxG.width / 2, FlxG.height / 2, ResourceManager.GFX_ENEMY1));
		}
		
		
		
		override public function update() :void
		{
			super.update(); // before? or after?
			totalElapsed += FlxG.elapsed;
		}
	}
}