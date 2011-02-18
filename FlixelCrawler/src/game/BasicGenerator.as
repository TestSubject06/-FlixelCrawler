package game
{
	import org.flixel.*;
	import org.flixel.data.*;
	
	
	
	// TODO: - Find out why the whole thing used to freeze up before the iterations bandage, and see if we can fix it.
	//       - Make the adjacent rooms allow for multiple doors per wall instead of just the center. This will make maps a LOT (ALOT) more interesting!
	//       - Add stairs to generated levels.
	//       - Implement prefabs, possibly non-rectangular rooms?
	//       - Put actual wooden doors in some passages, or maybe just if they're 2 wide (mix of passages and doors!)
	
	// The BasicGenerator level generator creates levels by starting with one room in the center
	// and then building new rooms outward from its walls. 
	public class BasicGenerator extends LevelGenerator
	{
		// A list of every chunk.
		private static var _prefabs :Vector.<RoomChunk>;
		private static var possibleDoors :Vector.<FlxPoint>;
		
		
		
		// Generates a basic level made up of random chunks.
		public static function generate(RandomSeed :int = NaN, TileSet :Class = null) :void
		{
			FlxU.randomSeed = RandomSeed;
			if (TileSet == null) _tileSet = ResourceManager.GFX_DUNGEON_TILES;
			else _tileSet = TileSet;
			
			// Create a level of somewhat random width and height.
			var minSize :int = 30;
			var maxSize :int = 120;
			_w = minSize + (FlxU.random() * (maxSize - minSize));
			_h = minSize + (FlxU.random() * (maxSize - minSize));
			_level = new Vector.<Vector.<int>>(_w, true);
			for (var i :int = 0; i < _w; i++) _level[i] = new Vector.<int>(_h, true);
			
			possibleDoors = new Vector.<FlxPoint>();
			
			var prefabChance :Number = 0.01; // chance of a room being a prefab.
			var chunkCount :int = int(((_w + _h) / (2 * 15)) +  FlxU.random() * ((_w + _h) / (2 * 10)));
			
			// Build the map!
			var cc :int = 0;
			var iterations :int = 0;
			while (cc < chunkCount && iterations < 1000)
			{
				// Random chunk width and height (includes walls).
				var cw :int = 5 + (2 * int(FlxU.random() * 13));
				var ch :int = 5 + (2 * int(FlxU.random() * 13));
				var cx :int;
				var cy :int;
				
						
				// Very first chunk generated.
				if (cc == 0)
				{
					if (FlxU.random() < prefabChance)
					{
						// prefab level? (RARE)
						// probably not, I'd think the broad phase (PlayState) would handle that
						// a cool prefab starting room wouldn't be terrible though...
					}
					else
					{
						// Place a new chunk in the center of the room
						cx = (_w/2) - (cw/2);
						cy = (_h/2) - (ch/2);
						
						makeChunk(cx, cy, cw, ch, -1);
						
						iterations++;
					}
				}
				// All other rooms
				else
				{
					var chunkCreated :Boolean = false;
					
					// Keep trying to make chunks by checking random doors and building off of them.
					while (!chunkCreated && iterations < 1000)
					{
						var rdi :int = FlxU.random() * possibleDoors.length; // randomDoor index
						var randomDoor :FlxPoint = possibleDoors[rdi]; // A random potential door
						
						// Figure out which way this random door opens up toward.
						var doorDirection :int;
						if (_level[randomDoor.x - 1][randomDoor.y] == EMPTY) doorDirection = 0;
						else if (_level[randomDoor.x][randomDoor.y - 1] == EMPTY) doorDirection = 1;
						else if (_level[randomDoor.x + 1][randomDoor.y] == EMPTY) doorDirection = 2;
						else if (_level[randomDoor.x][randomDoor.y + 1] == EMPTY) doorDirection = 3;
						else
						{
							iterations++;
							continue; // this door already connecting two chunks together.
						}
						
						if (FlxU.random() < prefabChance)
						{
							//prefab chunk (will need rotation)
							// Generate the layout for the room.
							
							// pasteChunk(_prefabs[0], 
						}
						else
						{
							// Try to create a new, random chunk off of this door.
							var chunkOffset :int = (doorDirection == 0 || doorDirection == 2) ? (ch/2) : (cw/2); // Centers the new chunk's wall on this door.
							
							// Attempt to make the chunk for each door direction.
							switch (doorDirection)
							{
								// Passage opens to the left
								case 0:
									cx = randomDoor.x - cw;
									cy = randomDoor.y - chunkOffset;
								
									// Check to make sure our chunk will fit left of this door
									if (checkRectAvailable(cx, cy, cw, ch, rdi))
									{
										// Randomly generate a chunk left of this door.
										makeChunk(cx, cy, cw, ch, rdi);
										chunkCreated = true;
									}
									
									break;
									
								// Passage opens up above
								case 1:
									cx = randomDoor.x - chunkOffset;
									cy = randomDoor.y - ch;
									
									// Check to make sure our chunk will fit left of this door
									if (checkRectAvailable(cx, cy, cw, ch, rdi))
									{
										// Randomly generate a chunk left of this door.
										makeChunk(cx, cy, cw, ch, rdi);
										chunkCreated = true;
									}
									
									break;
									
								// Passage opens to the right
								case 2:
									cx = randomDoor.x + 1;
									cy = randomDoor.y - chunkOffset;
								
									// Check to make sure our chunk will fit left of this door
									if (checkRectAvailable(cx, cy, cw, ch, rdi))
									{
										// Randomly generate a chunk left of this door.
										makeChunk(cx, cy, cw, ch, rdi);
										chunkCreated = true;
									}
									
									break;
									
								// Passage opens beneath.
								case 3:
									cx = randomDoor.x - chunkOffset;
									cy = randomDoor.y + 1;
								
									// Check to make sure our chunk will fit left of this door
									if (checkRectAvailable(cx, cy, cw, ch, rdi))
									{
										// Randomly generate a chunk left of this door.
										makeChunk(cx, cy, cw, ch, rdi);
										chunkCreated = true;
									}
									
									break;
							}
						}
						
						iterations++;
					}
				}
				
				cc++;
			}
			
			var stairsX :int = 0, stairsY :int = 0;
			var curStairs :Stairs;
			// TESTING: Put in dumb stairs
			// The up ones
			if (ResourceManager.playState.curRoom.roomsAbove[0] != null || ResourceManager.playState.curRoom.depth == 0)
			{
				while (_level[stairsX][stairsY] != GROUND)
				{
					stairsX = int(FlxU.random() * _w);
					stairsY = int(FlxU.random() * _h);
				}
				curStairs = new Stairs(stairsX * 32, stairsY * 32, ResourceManager.playState.curRoom.roomsAbove[0]);
				ResourceManager.playState.stairsUp.add(curStairs);
				ResourceManager.playState.stairsUp.add(curStairs.actionTooltip);
				stairsX = 0;
				stairsY = 0;
			}
			
			// The down ones.
			if (ResourceManager.playState.curRoom.roomsBelow[0] != null)
			{
				while (_level[stairsX][stairsY] != GROUND)
				{
					stairsX = int(FlxU.random() * _w);
					stairsY = int(FlxU.random() * _h);
				}
				curStairs = new Stairs(stairsX * 32, stairsY * 32, ResourceManager.playState.curRoom.roomsBelow[0]);
				ResourceManager.playState.stairsDown.add(curStairs);
				ResourceManager.playState.stairsDown.add(curStairs.actionTooltip);
				FlxG.log("");
			}
			
			// Load up the room!
			loadTilemaps();
		}
		
		
		
		// This functions similarly to makeChunk, except instead of making an empty rectangle it
		// pastes the map from a prefab chunk.
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
		
		
			
		// Fills in a room on the level and adds random features to it.
		public static function makeChunk(X :int, Y :int, W :int, H :int, DoorIndex :int) :void
		{
			// Clear out the area we need w/ GROUND surrounded by walls.
			for (var j :int = 0; j < H; j++)
			{
				for (var i :int = 0; i < W; i++)
				{
					_level[X + i][Y + j] = (i == 0 || i == W - 1 || j == 0 || j == H - 1) ? (WALL) : (GROUND);
				}
			}
			
			var connectingDoor :FlxPoint = (DoorIndex >= 0 && DoorIndex < possibleDoors.length) ? (possibleDoors[DoorIndex]) : (null);
			var adjacentSpace :FlxPoint;
			var digDirection :FlxPoint;
			var digDist :int;
			
			var leftDoorCount :int, topDoorCount :int, rightDoorCount :int, bottomDoorCount :int;
			
			if (connectingDoor != null)
			{
				// Make a tunnels of GROUND from old door to this new chunk.
				if (connectingDoor.x < X)
				{
					digDist = X - connectingDoor.x + 1;
					
					digDirection = new FlxPoint(1, 0);
					adjacentSpace = new FlxPoint(0, 1 - (2 * int(FlxU.random() * 2)));
				}
				else if (connectingDoor.y < Y)
				{
					digDist = Y - connectingDoor.y + 1;
					
					digDirection = new FlxPoint(0, 1);
					adjacentSpace = new FlxPoint(1 - (2 * int(FlxU.random() * 2)), 0);
				}
				else if (connectingDoor.x >= X + W)
				{
					digDist = connectingDoor.x - (X + W - 1) + 1;
					
					digDirection = new FlxPoint( -1, 0);
					adjacentSpace = new FlxPoint(0, 1 - (2 * int(FlxU.random() * 2)));
				}
				else if (connectingDoor.y >= Y + H)
				{
					digDist = connectingDoor.y - (Y + H - 1) + 1;
					
					digDirection = new FlxPoint(0, -1);
					adjacentSpace = new FlxPoint(1 - (2 * int(FlxU.random() * 2)), 0);
				}
				
				// Make two tunnels in this direction, side by side.
				for (i = 0; i < digDist; i++)
				{
					_level[connectingDoor.x + (i * digDirection.x)][connectingDoor.y + (i * digDirection.y)] = GROUND;
					_level[connectingDoor.x + adjacentSpace.x + (i * digDirection.x)][connectingDoor.y + adjacentSpace.y + (i * digDirection.y)] = GROUND;
				}
					
				// 50% chance of making a third tunnel.
				if (FlxU.random() < 0.5)
				{
					for (i = 0; i < digDist; i++)
					{
						_level[connectingDoor.x - adjacentSpace.x + (i * digDirection.x)][connectingDoor.y - adjacentSpace.y + (i * digDirection.y)] = GROUND;
					}
				}
				
				// We're done linking this new chunk to the old one, so delete this door from possible doors list.
				possibleDoors[DoorIndex] = possibleDoors[possibleDoors.length - 1];
				possibleDoors.pop();
				
// --- HEY ---> // Add new possible doors all along each wall of this chunk to the possible doors list.
			}
			else
			{
				
			}
			
			//if (connectingDoor == null)
			//{
				
			//}
			//for (i = 0; i <  H - 4
			// Left doors
			if ((connectingDoor == null) || (connectingDoor.x < X + W && X > 1))
			{
				possibleDoors[possibleDoors.length] = new FlxPoint(X, Math.floor(Y + (H/2)));
			}
			
			// Top doors
			if ((connectingDoor == null) || (connectingDoor.y < Y + H && Y > 1))
			{
				possibleDoors[possibleDoors.length] = new FlxPoint(Math.floor(X + (W/2)), Y);
			}
			
			// Right doors
			if ((connectingDoor == null) || (connectingDoor.x > X && X + W - 1 < _w - 2))
			{
				possibleDoors[possibleDoors.length] = new FlxPoint(X + W - 1, Math.floor(Y + (H/2)));
			}
			
			// Bottom doors
			if ((connectingDoor == null) || (connectingDoor.y > Y && Y + H - 1 < _h - 2))
			{
				possibleDoors[possibleDoors.length] = new FlxPoint(Math.floor(X + (W/2)), Y + H - 1);
			}
		}
		
		
		
		// Checks to see if a room of a certain size will fit in a certain spot.
		public static function checkRectAvailable(X :int, Y :int, W :int, H :int, DoorIndex :int) :Boolean
		{
			if (X < 0 || X + W - 1 >= _w || Y < 0 || Y + H - 1 >= _h) return false;
			
			var rectFree :Boolean = true;
			
			// Check the actual chunk area first.
			for (var j :int = 0; j < H; j++)
			{
				for (var i :int = 0; i < W; i++)
				{
					if (_level[X + i][Y + j] != EMPTY)
					{
						rectFree = false;
						break;
					}
				}
				
				if (!rectFree) break;
			}
			
			var connectingDoor :FlxPoint = (DoorIndex >= 0 && DoorIndex < possibleDoors.length) ? (possibleDoors[DoorIndex]) : (null);
			if (connectingDoor != null)
			{
				// Check the tunnel from connectingDoor to this new chunk
				
			}
			
			return rectFree;
		}
		
		
		
		// Load in all the chunks!
		public static function initialize() :void
		{
			_prefabs = new <RoomChunk>[
				new RoomChunk(ResourceManager.MAP_CHUNK000)];
		}
	}
}