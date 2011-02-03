package 
{
	import org.flixel.FlxGame;
	import states.*;

	// Make the SWF be 800x600
	[SWF(width = "640", height = "480", backgroundColor = "#000000")]
	
	// Set Preloader class name.
    [Frame(factoryClass="Preloader")]

	
	
    public class FlixelCrawler extends FlxGame
    {
        public function FlixelCrawler()
        {
			trace("AND THUS THEY EMBARKED ON A GREAT JOURNEY TO CREATE THE GREATEST GAME EVER MADE.");
			
			// ResourceManager.initialize();
			
			// Make the FlxGame have 640x480 resolution at regular 1x pixel zoom. Start the game in PlayState.
			super(640, 480, PlayState, 1);
        }
    }
}
