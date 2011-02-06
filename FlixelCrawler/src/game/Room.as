package game 
{
	import flash.utils.Dictionary;
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxTilemap;


	
	// The Room class represents a single level, either of a dungeon or a town.
	public class Room extends FlxGroup
	{
		// General room info
		public var dungeonLevel :int;
		public var name :String;
		public var tileSet :Class;
		public var floorMap :FlxTilemap, wallsMap :FlxTilemap;
		// public var lightMap? lights up your character's line of vision (like Nethack), or in a circle 
							//  around you (maybe only in dark areas), or both?
		
		
		
		public function Room(DungeonLevel :int = 0, Name :String = "Main", TileSet :Class = null)
		{
			dungeonLevel = DungeonLevel;
			name = Name;
			if (tileSet == null) tileSet = ResourceManager.GFX_CAVE_TILES;
			else tileSet = TileSet;
			
			floorMap = new FlxTilemap();
			wallsMap = new FlxTilemap();
			// lightMap = new FlxTilemap();
			// add(bgMap, true); // don't add() it?
		}
		
		
		
		// Update all the enmies, monsters, etc.
		override public function update() :void
		{
			// before update stuff
			
			super.update();
			// 
			
			// after update stuff
		}
		
		
		
		// Render the floor, then players + walls vertically
		override public function render() :void
		{
			// do it, bro.
		}
	}
}