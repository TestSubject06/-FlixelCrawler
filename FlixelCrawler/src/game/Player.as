package game 
{
	import org.flixel.*;
	import org.flixel.data.*;
	
	
	
	// This class represents a player in the game. You can only control one by yourself, but others exist to represent 
	// the other players whose games you are conected to!
	public class Player extends FlxSprite
	{
		//Default to player 0
		public var playerIndex :uint = 0;
		public var moveSpeed :Number;
		//public var walkSpeed :Number;
		//public var runSpeed :Number;
		public var name :String;
		public var faceImg :Class;
		public var lastSentPos :FlxPoint;
		public var canMove :Boolean;
		//lastReceivedPos :FlxPoint;
		
		
		
		public function Player(X :Number = 0, Y :Number = 0, Name :String = "GUEST", FaceImage :Class = null)
		{
			super(X, Y);
			
			moveSpeed = 250.0; // I like this speed!
			canMove = true;
			loadGraphic(ResourceManager.GFX_ENEMY1);
			width = 30;
			height = 30;
			name = Name;
			lastSentPos = new FlxPoint(x, y);
			//lastReceivedPos = null;
			
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
			if (playerIndex == ResourceManager.playState.playerIndex && canMove)
			{
				// We control this player.
				lastSentPos.x = x;
				lastSentPos.y = y;
				
				//Check the keys against your 'virtual controller' that we set up earlier.
				if (pressed("LEFT")) velocity.x = -moveSpeed;
				else if (pressed("RIGHT")) velocity.x = moveSpeed;
				else velocity.x = 0;
				
				if (pressed("UP")) velocity.y = -moveSpeed;
				else if (pressed("DOWN")) velocity.y = moveSpeed;
				else velocity.y = 0;
				
				super.updateMotion();
				
				//If the player has moved, send that shit!
				if ((lastSentPos.x != x || lastSentPos.y != y) && ResourceManager.playState.connection != null)
					ResourceManager.playState.connection.send("move", x, y, velocity.x, velocity.y);
			}
			else
			{
				// We don't control this player.
			}
		}
		
		
		
		// ... I don't even know. But it looks cool to takeControl of a sprite :D
		public function takeControl(playerIndex:uint):void
		{
			this.playerIndex = playerIndex;
		}
		
		
		
		public function pressed(button :String) :Boolean
		{
			return (ResourceManager.playState.controlType == 0) ? ((FlxG.gamepads[0] as FlxGamepad).pressed(button)) : ((FlxG.gamepads[1] as FlxGamepad).pressed(button));
		}
		
		public function justPressed(button :String) :Boolean
		{
			return (ResourceManager.playState.controlType == 0) ? ((FlxG.gamepads[0] as FlxGamepad).justPressed(button)) : ((FlxG.gamepads[1] as FlxGamepad).justPressed(button));
		}
	}
}