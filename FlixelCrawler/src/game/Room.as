package game 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxTilemap;


	
	// The Room class represents a single level, either of a dungeon or a town.
	public class Room extends FlxGroup
	{
		// Room tile consts
		public static const FLOOR :int = 16;
		public static const LEFT_WALL :int = 10;
		public static const TOP_WALL :int = 14;
		public static const RIGHT_WALL :int = 12;
		public static const BOTTOM_WALL :int = 22;
		public static const UL_CORNER :int = 4;
		public static const UR_CORNER :int = 7;
		public static const BL_CORNER :int = 19;
		public static const BR_CORNER :int = 1;
		
		// Room info
		public var dungeonLevel :int;
		public var name :String;
		public var tileSet :Class;
		public var map :FlxTilemap;
		
		
		
		public function Room(DungeonLevel :int = 0, Name :String = "Main", TileSet :Class = null)
		{
			dungeonLevel = DungeonLevel;
			name = Name;
			if (tileSet == null) tileSet = ResourceManager.GFX_CAVE_TILES;
			else tileSet = TileSet;
			
			map = new FlxTilemap();
			add(map, true);
		}
		
		
		
		override public function update() :void
		{
			// before update stuff
			
			super.update();
			
			// after update stuff
		}
	}
}