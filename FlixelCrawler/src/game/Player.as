package game 
{
	import org.flixel.data.FlxGamepad;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import game.states.PlayState;


	
	// This class represents a player in the game. You can only control one by yourself, but others exist to represent 
	// the other players whose games you are conected to!
	public class Player extends FlxSprite
	{
		//Default to player 0
		public var playerIndex:uint = 0;
		public var moveSpeed :Number;
		public var name :String;
		public var faceImg :Class;
		
		
		
		public function Player(X :Number = 0, Y :Number = 0, Name :String = "GUEST", FaceImage :Class = null)
		{
			super(X, Y);
			
			moveSpeed = 680.0;
			loadGraphic(ResourceManager.GFX_ENEMY1);
			width = 30;
			height = 30;
			name = Name;
			if (FaceImage == null) faceImg = ResourceManager.GFX_PLAYER_FACE_ICON;
			else faceImg = FaceImage;
		}
		
		
		
		override public function update() :void
		{
			// before update stuff
			
			super.update();
			
			// after update stuff
		}
		
		
		
		override protected function updateMotion() :void
		{
			var firstx:Number = x;
			var firsty:Number = y;
			//Check the keys against your 'virtual controller' that we set up earlier.
			if ((FlxG.gamepads[playerIndex] as FlxGamepad).pressed("LEFT")) velocity.x = -moveSpeed;
			else if ((FlxG.gamepads[playerIndex] as FlxGamepad).pressed("RIGHT")) velocity.x = moveSpeed;
			else velocity.x = 0;
			if ((FlxG.gamepads[playerIndex] as FlxGamepad).pressed("UP")) velocity.y = -moveSpeed;
			else if ((FlxG.gamepads[playerIndex] as FlxGamepad).pressed("DOWN")) velocity.y = moveSpeed;
			else velocity.y = 0;
			
			super.updateMotion();
			//If the player has moved, send that shit!
			if (firstx != x || firsty != y) {
				PlayState(FlxG.state).connection.send("move", x, y, velocity.x, velocity.y);
			}
		}
		
		// ... I don't even know. But it looks cool to takeControl of a sprite :D
		public function takeControl(playerIndex:uint):void {
			this.playerIndex = playerIndex;
		}
	}
}