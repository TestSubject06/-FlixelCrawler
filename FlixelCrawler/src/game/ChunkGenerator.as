package game
{
	import org.flixel.*;
	import org.flixel.data.*;
	
	
	
	// The ChunkGenerator level generator uses one single prefab chunk as the entire level. Nice for unique or important levels.
	public class ChunkGenerator extends LevelGenerator
	{
		// A list of every chunk. (LevelGenerator should probably keep track of this instead).
		private static var _prefabs :Vector.<RoomChunk>;
		
		
		
		// Generates a level from a specific chunk.
		public static function generate(TileSet :Class = null, Chunk :RoomChunk = null) :Room
		{
			if (TileSet == null) _tileSet = ResourceManager.GFX_MARKED_TILES;
			else _tileSet = TileSet;
			if (Chunk == null) Chunk = _prefabs[0];
			
			
			
			// Create and load up the room.
			return convertToRoom();
		}
		
		
		
		// This should probably also go in LevelGenerator.
		public static function pasteChunk(Chunk :RoomChunk, X :int, Y :int) :void
		{
			for (var j :int = 0; j < _prefabs[0].height; j++)
			{
				for (var i :int = 0; i < _prefabs[0].width; i++)
				{
					_level[X + i][Y + j] = _prefabs[0].map[i][j];
				}
			}
		}
		
		
		
		// This should probably also go in LevelGenerator.
		public static function initialize() :void
		{
			_prefabs = new <RoomChunk>[
				new RoomChunk(ResourceManager.MAP_CHUNK000)];
		}
	}
}