package game.states
{
	import org.flixel.*;
	import org.flixel.data.*;
	import game.*; // HEY IS THERE A WAY TO GET RID OF THIS LINE
	
	

	// PlayState is the FlxState where all the actual gameplay happens.
    public class PlayState extends FlxState
    {	
		// General PlayState stuff
		public var totalElapsed :Number; // total elapsed time since state's start.
		
		// Visual/Parallax Layers
		public var lyrBackdrop :FlxGroup; // might not be needed
		public var lyrBGMap :FlxGroup; // the level iteself
		public var lyrBGSprites :FlxGroup; // items, gold, etc.
		public var lyrMGSprites :FlxGroup; // players, enemies, etc.
		public var lyrFGSprites :FlxGroup; // spells, darts, etc.
		public var lyrFGMap :FlxGroup; // since we're doing 3/4 view, we need this to overlay some things
		public var lyrFX :FlxGroup;
		public var lyrGUI :FlxGroup;
	
		// Our actual game stuff.
		public var players :Vector.<Player>;
		public var neighboringRooms :Vector.<Room>;
		public var curRoom :Room;
		
		
		
		// How do you doc functions again
		override public function create() : void
		{
			// Set up general state stuff.
			totalElapsed = 0.0;				//     UP    DOWN    LEFT    RIGHT    A    B    X    Y    START    SELECT   L1   L2   R1   R2
			(FlxG.gamepads[0] as FlxGamepad).bind("UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "A", "C", "ENTER", ""     , "" , "" , "" , "" );
			
			// Set up visual/parallax layers.
			lyrBackdrop = new FlxGroup();
			lyrBackdrop.scrollFactor = new FlxPoint(0, 0); // should it scroll? probably not?
			lyrBGMap = new FlxGroup();
			lyrBGSprites = new FlxGroup();
			lyrMGSprites = new FlxGroup();
			lyrFGSprites = new FlxGroup();
			lyrFGMap = new FlxGroup();
			lyrFX = new FlxGroup();
			lyrFX.scrollFactor = new FlxPoint(0, 0);
			lyrGUI = new FlxGroup();
			lyrGUI.scrollFactor = new FlxPoint(0, 0);
			
			// Add visual/parallax layers to the FlxState so that they update/render.
			add(lyrBackdrop);
			add(lyrBGMap);
			add(lyrBGSprites);
			add(lyrMGSprites);
			add(lyrFGSprites);
			add(lyrFGMap);
			add(lyrFX);
			add(lyrGUI);
			
			// Add a backdrop.
			// lyrBackdrop.add(new FlxSprite(0, 0, ResourceManager.GFX_TEST_BG));
			
			// Initialize players vec w/ one player (us) and three empty players.
			players = new <Player>[new Player(0, 0, "Ace20"), null, null, null];
			
			// Set up all level generators.
			LevelGenerator.initialize();
			
			// Load a randomized room.
			loadRoom(BasicGenerator.generate());
			
			// Add the GUIs for each player.
			lyrGUI.add(new PlayerStatusGUI(0, 0, players[0]), true);
			lyrGUI.add(new PlayerStatusGUI(150, 0, players[1]), true);
			lyrGUI.add(new PlayerStatusGUI(300, 0, players[2]), true);
			lyrGUI.add(new PlayerStatusGUI(450, 0, players[3]), true);
			
			// Set up the camera.
			FlxG.follow(players[0], 5); // the Lerp thing is fucking weird.
		}
		
		
		
		override public function update() :void
		{
			// Update totalElapsed.
			totalElapsed += FlxG.elapsed;
			
			// Update every add()'d game object.
			super.update(); // before totalElapsed update? or after?
		}
		
		
		
		// This function will load in room into curRoom and make the necessary game updates.
		public function loadRoom(room :Room) :void
		{
			if (room == null) return;
			
			lyrBackdrop.members = [];
			lyrBGMap.members = [];
			lyrBGSprites.members = [];
			lyrMGSprites.members = [];
			lyrFGSprites.members = [];
			lyrFGMap.members = [];
			lyrFX.members = [];
			
			curRoom = room;
			FlxG.followBounds(0, 0, room.floorMap.width - 32, room.floorMap.height);
			
			// Add the map layers.
			lyrBGMap.add(curRoom.floorMap, true);
			lyrFGMap.add(curRoom.wallsMap, true);
			// lyrFX.add(curRoom.lightMap, true); ?
			
			// Add the player(s) to the MGSprites layer.
			for (var i: int = 0; i < players.length; i++)
			{
				lyrMGSprites.add(players[i]);
			}
			
			players[0].x = curRoom.floorMap.width / 2;
			players[0].y = curRoom.floorMap.height / 2;
		}
	}
}