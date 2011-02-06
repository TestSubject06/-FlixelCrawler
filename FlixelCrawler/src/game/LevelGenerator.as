package game
{
	import org.flixel.*;
	import org.flixel.data.*;
	
	
	
	// The LevelGenerator class is a base class for all level generators!
	public class LevelGenerator
	{
		// Flag for initializing static stuff
		private static var initialized :Boolean = false;
		
		// Level tile indices
		private static var _empty :int = 0;
		private static var _ground :int = -1;
		private static var _wall :int = -1;
		private static var _door :int = -1;
		private static var _stairs :int = -1;
		private static var _chest :int = -1;
		private static var _water :int = -1;
		
		// Graphic tile indices
		// Floors
		private static var _ul_floor :int = -1;
		private static var _u_floor :int = -1;
		private static var _ur_floor :int = -1;
		private static var _l_floor :int = -1;
		private static var _c_floor :int = -1;
		private static var _r_floor :int = -1;
		private static var _bl_floor :int = -1;
		private static var _b_floor :int = -1;
		private static var _br_floor :int = -1;
		
		// Wall tops
		private static var _ul_wall_top :int = -1;
		private static var _u_wall_top :int = -1;
		private static var _ur_wall_top :int = -1;
		private static var _l_wall_top :int = -1;
		private static var _c_wall_top :int = -1;
		private static var _r_wall_top :int = -1;
		private static var _bl_wall_top :int = -1;
		private static var _b_wall_top :int = -1;
		private static var _br_wall_top :int = -1;
		
		// Wall sides
		private static var _ul_wall_side :int = -1;
		private static var _u_wall_side :int = -1;
		private static var _ur_wall_side :int = -1;
		private static var _bl_wall_side :int = -1;
		private static var _b_wall_side :int = -1;
		private static var _br_wall_side :int = -1;
		
		// Thin wall tops (most are impossible to get)
		// private static var _l_thinwall_top :int = -1;
		// private static var _horiz_thinwall_top :int = -1;
		// private static var _r_thinwall_top :int = -1;
		// private static var _u_thinwall_top :int = -1;
		private static var _vert_thinwall_top :int = -1;
		private static var _b_thinwall_top :int = -1;
		// private static var _c_thinwall_top :int = -1;
		
		// Thin wall sides
		private static var _u_thinwall_side :int = -1;
		private static var _b_thinwall_side :int = -1;
		
		// Transparent wall tops
		private static var _ul_wall_top_trans  :int = -1;
		private static var _u_wall_top_trans :int = -1;
		private static var _ur_wall_top_trans :int = -1;
		private static var _l_wall_top_trans :int = -1;
		private static var _c_wall_top_trans :int = -1;
		private static var _r_wall_top_trans :int = -1;
		private static var _bl_wall_top_trans :int = -1;
		private static var _b_wall_top_trans :int = -1;
		private static var _br_wall_top_trans :int = -1;
		
		// Transparent wall sides
		private static var _ul_wall_side_trans :int = -1;
		private static var _u_wall_side_trans :int = -1;
		private static var _ur_wall_side_trans :int = -1;
		
		// Transparent thin wall tops & side
		private static var _l_thinwall_top_trans :int = -1;
		private static var _horiz_thinwall_top_trans :int = -1;
		private static var _r_thinwall_top_trans :int = -1;
		private static var _u_thinwall_top_trans :int = -1;
		private static var _vert_thinwall_top_trans :int = -1; // 
		private static var _b_thinwall_top_trans :int = -1;
		private static var _c_thinwall_top_trans :int = -1;
		private static var _u_thinwall_side_trans :int = -1;
		
		private static const GFX_VARIATIONS :int = 3;
		
		// The level data
		protected static var _level :Vector.<Vector.<int>>;
		protected static var _floorMap :Vector.<Vector.<int>>
		protected static var _wallsMap :Vector.<Vector.<int>>
		protected static var _w :int;
		protected static var _h :int;
		protected static var _tileSet :Class;
		
		
		
		// Converts the generated level to a CSV string for tilemap loading.
		// This function autotiles the level according the the graphic tile indices.
		protected static function convertToRoom() :Room
		{
			// Run through map and turn all EMPTY tiles into WALL tiles. Also, make sure the level
			// is surrounded by wall tiles.
			for (var j :int = 0; j < _h; j++)
			{
				for (var i :int = 0; i < _w; i++)
				{
					if (_level[i][j] == EMPTY || (i == 0 || j == 0 || i == _w - 1 || j == _h - 1)) _level[i][j] = WALL;
				}
			}
			
			// init variables
			_floorMap = new Vector.<Vector.<int>>(_w, true);
			for (i = 0; i < _w; i++) _floorMap[i] = new Vector.<int>(_h, true);
			_wallsMap = new Vector.<Vector.<int>>(_w, true);
			for (i = 0; i < _w; i++) _wallsMap[i] = new Vector.<int>(_h, true);
			
			// The auto-tiling algorithm! This converts the raw level data into graphical tiles indices.
			// Notte that this function isn't completely optimized for the walls, since you could probably record
			// the level indices that have already been processed by the wall-tiling part. Despite that, this should
			// be plenty fast enough for room changing.
			// 
			// Fun fact: you could rotate the entire map 90 degrees and this auto-tiling algorithm would still work just fine!
			//                   ... you'd need to rotate the graphics for chests and stuff though. Not really a big deal.
			
			// Go through each level tile individually to auto-tile it and possibly several tiles above it (if it is a wall).
			for (j = 0; j < _h; j++)
			{
				for (i = 0; i < _w; i++)
				{
					// Helpful for checking the tiles around this one.
					var curTile :int = _level[i][j];
					var leftTile :int = (i != 0) ? (_level[i-1][j]) : (WALL); // Set to WALL for convenience
					var upTile :int = (j != 0) ? (_level[i][j-1]) : (-1); // NOT this one, however, since it determines when we stop for walls.
					var rightTile :int = (i + 1 != _w) ? (_level[i+1][j]) : (WALL); // Set to WALL for convenience
					var downTile :int = (j + 1 != _h) ? (_level[i][j+1]) : (-1); // this is -1 so that the filling will work
					
					switch (curTile)
					{
						case GROUND:
							if (leftTile == WALL && upTile == WALL) _floorMap[i][j] = _ul_floor;
							else if (upTile == WALL && rightTile == WALL) _floorMap[i][j] = _ur_floor;
							else if (upTile == WALL) _floorMap[i][j] = _u_floor;
							else if (leftTile == WALL && downTile == WALL) _floorMap[i][j] = _bl_floor;
							else if (rightTile == WALL && downTile == WALL) _floorMap[i][j] = _br_floor;
							else if (downTile == WALL) _floorMap[i][j] = _b_floor;
							else if (leftTile == WALL) _floorMap[i][j] = _l_floor;
							else if (rightTile == WALL) _floorMap[i][j] = _r_floor;
							else  _floorMap[i][j] = _c_floor; // + x % GFX VARIATIONS or something so that it's not just the same tile over and over.
							
							break;
						
						case WALL:
							// shiiiiit dude
							// okay, so basically we're gonna need to make two FlxGroups in PlayState for walls behind and in front of the player.
							// Once frame, we start by clearing out these two groups. Go through every wall tile that is within a small box around
							// every player and check if any walls there have a small y position than that player and put them... wait....
							// 
							// what if there is a player in front of a wall and another behind it?
							// perhaps we could add the player into each group right after the end of the row he is on? that way he'd be on top of all the tiles on that row...
							// 
							// or we could overwrite the render for the map to render the wall tilemap's FlxTileblocks row by row, checking to see if the player is on that row, in which case
							// everything under him is rendered on top of him...
							// Would that work?
							//
// ---------- THIS ----------> Yeah, morganq says to render the rooms w/ floor first, then walls + player vertically
							
							// Thin vertical wall or single column.
							if (leftTile != WALL && rightTile != WALL && downTile != WALL)
							{
								// Set the base wall for the floor map to be a thin vert wall side.
								_floorMap[i][j] = _b_thinwall_side;
								
								// Check if this is longer vertical wall or just a single pillar.
								if (upTile == WALL)
								{
									// Long vertical wall. Put the corresponding SOLID upper wall side tile.
									_wallsMap[i][j - 1] = _u_thinwall_side;
									
									// Now, move upwards gradually from this tile, setting each's wallTop correctly.
									autoTileWallTopsUpward(i, j); // start here since it doesn't have a top yet.
								}
								else if (upTile != -1)
								{
									// This is a single vertical column.
									_wallsMap[i][j - 1] = _u_thinwall_side_trans;
									if (j - 2 >= 0) _wallsMap[i][j - 2] = _c_thinwall_top_trans;
								}
							}
							// Bottom-left piece of wall or leftmost piece of thin, horizontal wall.
							else if (leftTile != WALL && rightTile == WALL && downTile != WALL)
							{
								// Set the base wall for the floor map to be a bl wall side.
								_floorMap[i][j] = _bl_wall_side;
								
								// Check if this wall is a thin horizontal one or not.
								if (upTile == WALL)
								{
									_wallsMap[i][j - 1] = _ul_wall_side;
									
									// Now, move upwards gradually from this tile, setting each's wallTop correctly.
									autoTileWallTopsUpward(i, j); // start here since it doesn't have a top yet.
								}
								else if (upTile != -1)
								{
									_wallsMap[i][j - 1] = _ul_wall_side_trans;
									if (j - 2 >= 0) _wallsMap[i][j - 2] = _l_thinwall_top_trans;
								}
							}
							// Bottom center piece of a wide wall.
							else if (leftTile == WALL && rightTile == WALL && downTile != WALL)
							{
								_floorMap[i][j] = _b_wall_side;
								
								if (upTile == WALL)
								{
									_wallsMap[i][j - 1] = _u_wall_side;
									
									// Now, move upwards gradually from this tile, setting each's wallTop correctly.
									autoTileWallTopsUpward(i, j); // start here since it doesn't have a top yet.
								}
								else if (upTile != -1)
								{
									_wallsMap[i][j - 1] = _u_wall_side_trans;
									if (j - 2 >= 0) _wallsMap[i][j - 2] = _horiz_thinwall_top_trans;
								}
							}
							// Bottom-right piece of wall or leftmost piece of thin, horizontal wall.
							else if (leftTile == WALL && rightTile != WALL && downTile != WALL)
							{
								_floorMap[i][j] = _br_wall_side;
								
								if (upTile == WALL)
								{
									_wallsMap[i][j - 1] = _ur_wall_side;
									
									// Now, move upwards gradually from this tile, setting each's wallTop correctly.
									autoTileWallTopsUpward(i, j); // start here since it doesn't have a top yet.
								}
								else if (upTile != -1)
								{
									_wallsMap[i][j-1] = _ur_wall_side_trans;
								}
							}
							// Finally, make sure all the dark spots are filled in by auto-tiling upwards from the very bottom.
							else if (downTile == -1)
							{
								// This is the bottom-most tile of the map
								autoTileWallTopsUpward(i, _h + 1);
							}
							
							break;
						
						case DOOR:
							
							break;
						
						case STAIRS:
							
							break;
						
						case CHEST:
							
							break;
						
							/*
						case default:
							bgMap[i][j] = 0;
							break;
							*/
					}
				}
			}
			
			// Convert maps to CSV.
			var floorMapCSV :String = "";
			var wallsMapCSV :String = "";
			
			for (j = 0; j < _h; j++)
			{
				for (i = 0; i < _w; i++)
				{
					floorMapCSV += (i == _w - 1 && j == _h - 1) ? ("" + _floorMap[i][j]) : ("" + _floorMap[i][j] + ", ");
					wallsMapCSV += (i == _w-1 && j == _h - 1) ? ("" + _wallsMap[i][j]) : ("" + _wallsMap[i][j] + ", ");
				}
				
				floorMapCSV += "\n";
				wallsMapCSV += "\n";
			}
			
			// Finally, create a room that has everything our map does!
			var room :Room = new Room();
			room.floorMap.loadMap(floorMapCSV, _tileSet, 32, 32);
			room.wallsMap.loadMap(wallsMapCSV, _tileSet, 32, 32);
			
			return room;
		}
		
		
		
		// Take in a level tile and uses it to tile its wall tops and all walls above it.
		protected static function autoTileWallTopsUpward(X :int, Y :int) :void
		{
			if (Y == _h + 1) FlxG.log("X: " + X + ", Y: " + Y);
			// This is our counter for when we move upwards from tiles to check if there is anything there.
			var i :int = 0;
			while (true)
			{
				// The level tiles around us that we will be checking.
				var leftTile :int = (X != 0) ? (_level[X-1][Y-i]) : (WALL); // Set the ones offscreen to WALL for convenience
				var rightTile :int = (X + 1 != _w) ? (_level[X+1][Y-i]) : (WALL);
				var downTile :int = (Y - i + 1 != _h) ? (_level[X][Y-i+1]) : (WALL);
				var upTwiceTile :int = (Y - i - 2 >= 0) ? (_level[X][Y-i-2]) : (-1); // We need to check up twice for transparency reasons.
				
				// Probably need a special check for the bottom tiles on the map...?
				// actually that probably ought to go up above in the switch cases
				// or wait, actually they just skip setting their sides and call us earlier!
				// we'll still need to have a special check though
				
				if (upTwiceTile == WALL)
				{
					// This tiles above this one are guaranteed WALLs, so we know this tile's wallTop will be solid.
					if (leftTile != WALL && rightTile != WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _b_thinwall_top;
					else if (leftTile == WALL && rightTile != WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _br_wall_top;
					else if (leftTile != WALL && rightTile == WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _bl_wall_top;
					else if (leftTile != WALL && rightTile != WALL && downTile == WALL) _wallsMap[X][Y - i - 2] = _vert_thinwall_top;
					else if (leftTile == WALL && rightTile == WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _b_wall_top;
					else if (leftTile != WALL && rightTile == WALL && downTile == WALL) _wallsMap[X][Y - i - 2] = _l_wall_top;
					else if (leftTile == WALL && rightTile != WALL && downTile == WALL) _wallsMap[X][Y - i - 2] = _r_wall_top;
					else _wallsMap[X][Y - i - 2] = _c_wall_top;
					
					i++;
					continue;
				}
				else if (upTwiceTile == -1)
				{
					// The wall we're currently on has a top that is off the top of the map (not visible).
					break;
				}
				else
				{
					// There's no wall 2 blocks up, so this WALL and the one above's tops need to be transparent (which is
					// for the wallMap 2 and 3 spots above this level tile).
					// Wall top for this WALL on level.
					if (leftTile != WALL && rightTile != WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _b_thinwall_top_trans;
					else if (leftTile == WALL && rightTile != WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _br_wall_top_trans;
					else if (leftTile != WALL && rightTile == WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _bl_wall_top_trans;
					else if (leftTile != WALL && rightTile != WALL && downTile == WALL) _wallsMap[X][Y - i - 2] = _vert_thinwall_top_trans;
					else if (leftTile == WALL && rightTile == WALL && downTile != WALL) _wallsMap[X][Y - i - 2] = _b_wall_top_trans;
					else if (leftTile != WALL && rightTile == WALL && downTile == WALL) _wallsMap[X][Y - i - 2] = _l_wall_top_trans;
					else if (leftTile == WALL && rightTile != WALL && downTile == WALL) _wallsMap[X][Y - i - 2] = _r_wall_top_trans;
					else _wallsMap[X][Y - i - 2] = _c_wall_top_trans;
					
					// Update L and R since we're moving up one (don't need U or D - U is not a wall and D is definitely a wall).
					leftTile = (X != 0) ? (_level[X-1][Y-i-1]) : (WALL); // Set the ones offscreen to WALL for convenience
					rightTile = (X != _w-1) ? (_level[X+1][Y-i-1]) : (WALL);
					
					// Wall top for the WALL above on level
					if (Y - i - 3 < 0) break; // in case this is off the top.
					
					if (leftTile != WALL && rightTile != WALL) _wallsMap[X][Y - i - 3] = _u_thinwall_top_trans;
					else if (leftTile == WALL && rightTile != WALL) _wallsMap[X][Y - i - 3] = _ur_wall_top_trans;
					else if (leftTile != WALL && rightTile == WALL) _wallsMap[X][Y - i - 3] = _ul_wall_top_trans;
					else _wallsMap[X][Y - i - 3] = _c_thinwall_top_trans;
					
					break;
				}
			}
		}
		
		
		
		// This function initializes the mapping for level tiles to graphical tiles using a Dictionary.
		public static function initialize() :void
		{
			if (initialized) return;
			
			// The level index list.
			var levelIndices :String = new ResourceManager.MAP_LEVEL_INDICES();
			var tokens :Array = levelIndices.split(/[\n ]/);
			
			for (var i :int = 0; i < tokens.length; i++)
			{
				var curToken :String = tokens[i];
				var nextToken :String = tokens[i + 1];
				
				if (curToken == "ground" && (nextToken as int) != -1)
				{
					_ground = int(nextToken);
				}
				if (curToken == "wall" && (nextToken as int) != -1)
				{
					_wall = int(nextToken);
				}
				if (curToken == "door" && (nextToken as int) != -1)
				{
					_door = int(nextToken);
				}
				if (curToken == "stairs" && (nextToken as int) != -1)
				{
					_stairs = int(nextToken);
				}
				if (curToken == "chest" && (nextToken as int) != -1)
				{
					_chest = int(nextToken);
				}
				if (curToken == "water" && (nextToken as int) != -1)
				{
					_water = int(nextToken);
				}
			}
			
			// Warning messages if something didn't get set right.
			if (_ground == -1) FlxG.log("WARNING: ''_ground'' index not set.");
			if (_wall == -1) FlxG.log("WARNING: ''_wall'' index not set.");
			if (_door == -1) FlxG.log("WARNING: ''_door'' index not set.");
			if (_stairs == -1) FlxG.log("WARNING: ''_stairs'' index not set.");
			if (_chest == -1) FlxG.log("WARNING: ''_chest'' index not set.");
			if (_water == -1) FlxG.log("WARNING: ''_water'' index not set.");
			
			// The graphical tiles index list.
			var graphicIndices :String = new ResourceManager.MAP_TESTGRAPHIC_INDICES();
			tokens = graphicIndices.split(/[\n ]/);
			
			for (i = 0; i < tokens.length; i++)
			{
				curToken = tokens[i];
				nextToken = tokens[i + 1];
				
				// Floors
				if (curToken == "ul_floor" && (nextToken as int) != -1)
				{
					_ul_floor = int(nextToken);
					continue;
				}
				else if (curToken == "u_floor" && (nextToken as int) != -1)
				{
					_u_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "ur_floor" && (nextToken as int) != -1)
				{
					_ur_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "l_floor" && (tokens[i+1] as int) != -1)
				{
					_l_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "c_floor" && (tokens[i+1] as int) != -1)
				{
					_c_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "r_floor" && (tokens[i+1] as int) != -1)
				{
					_r_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "bl_floor" && (tokens[i+1] as int) != -1)
				{
					_bl_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "b_floor" && (tokens[i+1] as int) != -1)
				{
					_b_floor = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "br_floor" && (tokens[i+1] as int) != -1)
				{
					_br_floor = int(tokens[i + 1]);
					continue;
				}
				
				// Wall tops
				else if (curToken == "ul_wall_top" && (tokens[i+1] as int) != -1)
				{
					_ul_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "u_wall_top" && (tokens[i+1] as int) != -1)
				{
					_u_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "ur_wall_top" && (tokens[i+1] as int) != -1)
				{
					_ur_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "l_wall_top" && (tokens[i+1] as int) != -1)
				{
					_l_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "c_wall_top" && (tokens[i+1] as int) != -1)
				{
					_c_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "r_wall_top" && (tokens[i+1] as int) != -1)
				{
					_r_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "bl_wall_top" && (tokens[i+1] as int) != -1)
				{
					_bl_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "b_wall_top" && (tokens[i+1] as int) != -1)
				{
					_b_wall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "br_wall_top" && (tokens[i+1] as int) != -1)
				{
					_br_wall_top = int(tokens[i + 1]);
					continue;
				}
				
				// Wall sides
				else if (curToken == "ul_wall_side" && (tokens[i+1] as int) != -1)
				{
					_ul_wall_side = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "u_wall_side" && (tokens[i+1] as int) != -1)
				{
					_u_wall_side = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "ur_wall_side" && (tokens[i+1] as int) != -1)
				{
					_ur_wall_side = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "bl_wall_side" && (tokens[i+1] as int) != -1)
				{
					_bl_wall_side = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "b_wall_side" && (tokens[i+1] as int) != -1)
				{
					_b_wall_side = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "br_wall_side" && (tokens[i+1] as int) != -1)
				{
					_br_wall_side = int(tokens[i + 1]);
					continue;
				}
				
				// Thin wall tops
				else if (curToken == "vert_thinwall_top" && (tokens[i+1] as int) != -1)
				{
					_vert_thinwall_top = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "b_thinwall_top" && (tokens[i+1] as int) != -1)
				{
					_b_thinwall_top = int(tokens[i + 1]);
					continue;
				}
				
				// Thin wall sides
				else if (curToken == "u_thinwall_side" && (tokens[i+1] as int) != -1)
				{
					_u_thinwall_side = int(tokens[i + 1]);
					continue;
				}
				else if (curToken == "b_thinwall_side" && (tokens[i+1] as int) != -1)
				{
					_b_thinwall_side = int(tokens[i + 1]);
					continue;
				}
			}
			
			// Warning messages if something didn't get set right.
			// Floors
			if (_ul_floor == -1) FlxG.log("WARNING: ''_ul_floor'' index not set.");
			if (_u_floor == -1) FlxG.log("WARNING: ''_u_floor'' index not set.");
			if (_ur_floor == -1) FlxG.log("WARNING: ''_ur_floor'' index not set.");
			if (_l_floor == -1) FlxG.log("WARNING: ''_l_floor'' index not set.");
			if (_c_floor == -1) FlxG.log("WARNING: ''_c_floor'' index not set.");
			if (_r_floor == -1) FlxG.log("WARNING: ''_r_floor'' index not set.");
			if (_bl_floor == -1) FlxG.log("WARNING: ''_bl_floor'' index not set.");
			if (_b_floor == -1) FlxG.log("WARNING: ''_b_floor'' index not set.");
			if (_br_floor == -1) FlxG.log("WARNING: ''_br_floor'' index not set.");
			
			// fucking others too.
			
			// And now we initialize all the baby generators!
			BasicGenerator.initialize();
			
			// Finally, set initialized to true so all this doesn't happen again!
			initialized = true;
		}
		
		
		
		// These get functions are so that the level and graphic indices are read only.
		static public function get EMPTY() :int { return _empty; }
		static public function get GROUND() :int { return _ground; }
		static public function get WALL() :int { return _wall; }
		static public function get DOOR() :int { return _door; }
		static public function get STAIRS() :int { return _stairs; }
		static public function get CHEST() :int { return _chest; }
		static public function get WATER() :int { return _water; }
		
		// Fuck these too.
		/*
		static public function get FLOOR() :int { return _floor; }
		static public function get LEFT_WALL() :int { return _left_wall; }
		static public function get TOP_WALL() :int { return _top_wall; }
		static public function get RIGHT_WALL() :int { return _right_wall; }
		static public function get BOTTOM_WALL() :int { return _bottom_wall; }
		static public function get UL_CORNER() :int { return _ul_corner; }
		static public function get UR_CORNER() :int { return _ur_corner; }
		static public function get BL_CORNER() :int { return _bl_corner; }
		static public function get BR_CORNER() :int { return _br_corner; }
		*/
	}
}