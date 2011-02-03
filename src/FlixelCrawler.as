package 
{
	import org.flixel.FlxGame;

	// Make the SWF be 800x600
	[SWF(width = "800", height = "600", backgroundColor = "#000000")]
	
	// Set Preloader class name.
    [Frame(factoryClass="Preloader")]

	
	
    public class FlixelCrawler extends FlxGame
    {
        public function FlixelCrawler()
        {
			trace("AND THUS THEY EMBARKED ON A GREAT JOURNEY TO CREATE THE GREATEST GAME EVER MADE.");
			
			// ResourceManager.initialize();
			
			// Make the FlxGame have 800x600 resolution at regular 1x pixel zoom. Start the game in PlayState.
			super(800, 600, PlayState, 1);
        }
    }
}
