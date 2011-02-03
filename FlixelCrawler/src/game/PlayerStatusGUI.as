package game 
{
	import org.flixel.data.FlxGamepad;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxGroup;


	
	public class PlayerStatusGUI extends FlxGroup
	{
		var player :Player;
		
		
		
		public function PlayerStatusGUI(X :Number = 0, Y :Number = 0, player :Player = null)
		{
			super(X, Y);
			this.player = player;
		}
		
		
		
		override public function update() :void
		{
			// before update stuff
			
			super.update();
			
			// after update stuff
		}
	}
}