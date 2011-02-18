package game 
{
	import game.states.*;
	import org.flixel.*;
	import org.flixel.data.*;


	
	// Objects that can be interacted with (such as stairs, chests, loot on the ground, etc.) should
	// extend this class!
	public class InteractSprite extends FlxSprite
	{
		public var actionTooltip :FlxText;
		public var actionKeySprite :FlxSprite;
		public var interactRect :FlxObject; // Can't be an FlxRect because can't overlap it.
		public var callback :Function;
		
		
		
		public function InteractSprite(X :Number = 0, Y :Number = 0, ActionName :String = "Interact!", Callback :Function = null)
		{
			super(X, Y);
			
			this.moves = false;
			actionTooltip = new FlxText(X - 24, Y - 26, 200, ActionName);
			actionTooltip.setFormat(null, 12);
			callback = Callback;
			actionTooltip.visible = false;
			interactRect = new FlxObject(X, Y, 32, 32);
		}
		
		
		
		override public function update() :void
		{
			if (ResourceManager.playState.player.overlaps(interactRect))
			{
				actionTooltip.visible = true;
				
				if (ResourceManager.playState.player.justPressed("A") && ResourceManager.playState.justChangedRoom != true)
				{
					callback.call();
				}
			}
			else
			{
				actionTooltip.visible = false;
			}
			
			super.update();
			
			// after update stuff
		}
	}
}