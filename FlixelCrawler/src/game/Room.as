package game 
{
	import org.flixel.*;


	
	// The Room class is an information holder for the core info a client needs to load 
	// different levels of the dungeon.
	public class Room extends FlxGroup
	{
		public var depth :int; // The dLVL of this level.
		public var tileSet :Class; // The tileset for this level.
		public var generator :Function; // The generator function that generates this level.
		public var seed :int; // The random seed the generator will use.
		public var roomsAbove :Vector.<Room>; 
		public var roomsBelow :Vector.<Room>;
		public var stairsUpCount :int; // most of the time this = # of rooms above
		public var stairsDownCount :int; // most of the time this = # of rooms below
		
		
		
		public function Room(Seed :int = 0, Generator :Function = null, TileSet :Class = null, Depth :int = 0)
		{
			seed = Seed;
			generator = (Generator != null) ? (Generator) : (BasicGenerator.generate);
			tileSet = TileSet;
			depth = Depth;
			
			roomsAbove = new Vector.<Room>();
			roomsBelow = new Vector.<Room>();
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