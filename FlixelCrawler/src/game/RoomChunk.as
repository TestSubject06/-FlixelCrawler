package game 
{
	import org.flixel.FlxPoint;


	
	// This class just an information holder for a chunk of a level. It holds the chunk's map data 
	// along with helpful information on it to speed up level generation.
	// Chunks can be anything from small rooms to entire levels!
	public class RoomChunk
	{
		// The actual map data
		public var map :Vector.<Vector.<int>>;
		
		// Helpful variables
		public var width :int, height :int;
		public var doorLocs :Vector.<FlxPoint>;
		
		
		
		public function RoomChunk(MapFile :Class = null)
		{
			// Set up this chunk based on the map data!
			if (MapFile == null) MapFile = ResourceManager.MAP_CHUNK000;
			var data :String = new MapFile();
			
			var rows:Array = data.split("\n");
			
			height = rows.length;
			
			var r :int = 0;
			var temp :Array = [];
			
			while (r < height)
			{
				var cols :Array = rows[r].split(",");
				r++;
				
				if (cols.length <= 1)
				{
					height -= 1;
					continue;
				}
				else if (width == 0)
					width = cols.length;
					
				temp[temp.length] = cols;
			}
			
			map = new Vector.<Vector.<int>>(width, true);
			for (var i :int = 0; i < width; i++) map[i] = new Vector.<int>(height, true);
			
			for (i = 0; i < width; i++)
			{
				for (var j :int = 0; j < height; j++)
				{
					map[j][i] = temp[i][j];
				}
			}
			
			// a single 3 (DOOR) means a doorLoc there, but adjacent 3s means also a physical door there?
			// sounds good!
		}
	}
}