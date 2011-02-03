package game 
{
	import org.flixel.data.FlxGamepad;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;


	
	public class Player extends FlxSprite
	{
		public var moveSpeed :Number;
		
		
		
		public function Player(X :Number, Y :Number)
		{
			super(X, Y);
			
			moveSpeed = 180.0;
			loadGraphic(ResourceManager.GFX_ENEMY1);
			width = 30;
			height = 30;
		}
		
		
		
		override public function update() :void
		{
			// before update stuff
			
			super.update();
			
			// after update stuff
		}
		
		
		
		override protected function updateMotion() :void
		{
			if ((FlxG.gamepads[0] as FlxGamepad).pressed("LEFT")) velocity.x = -moveSpeed;
			else if ((FlxG.gamepads[0] as FlxGamepad).pressed("RIGHT")) velocity.x = moveSpeed;
			else velocity.x = 0;
			if ((FlxG.gamepads[0] as FlxGamepad).pressed("UP")) velocity.y = -moveSpeed;
			else if ((FlxG.gamepads[0] as FlxGamepad).pressed("DOWN")) velocity.y = moveSpeed;
			else velocity.y = 0;
			
			super.updateMotion();
		}
	}
}