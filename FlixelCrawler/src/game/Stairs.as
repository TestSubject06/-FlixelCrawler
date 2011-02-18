package game 
{
	import game.states.*;
	import org.flixel.*;
	import org.flixel.data.*;


	
	// Objects that can be interacted with (such as stairs, chests, loot on the ground, etc.) should
	// extend this class!
	public class Stairs extends InteractSprite
	{
		public var toRoom :Room;
		public var index :int;
		
		
		
		public function Stairs(X :Number = 0, Y :Number = 0, ToRoom :Room = null, Index :int = 0)
		{
			// The stairs go UP by default.
			super(X, Y, "Go Higher!", fadeScreen);
			
			toRoom = ToRoom;
			index = Index;
			
			
			
			// Check if we need to switch to down stairs
			if (toRoom == null)
			{
				active = false;
				visible = false;
			}
			else if (ResourceManager.playState.curRoom.depth < toRoom.depth)
			{
				actionTooltip.text = "Go Deeper!";
				loadGraphic(ResourceManager.GFX_STAIRS_DOWN);
			}
			else
			{
				loadGraphic(ResourceManager.GFX_STAIRS_UP);
			}
		}
		
		
		
		public function fadeScreen() :void
		{
			ResourceManager.playState.player.canMove = false;
			FlxG.fade.start(FlxU.getColor(0, 0, 0, 1.0), 0.3, useStairs);
		}
		
		
		
		public function useStairs() :void
		{
			FlxG.fade.stop();
			ResourceManager.playState.loadRoom(toRoom, index);
		}
	}
}