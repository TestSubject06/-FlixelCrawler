package game.states
{
	import adobe.utils.CustomActions;
	import org.flixel.*;
	import org.flixel.data.*;
	import game.*; // HEY IS THERE A WAY TO GET RID OF THIS LINE
	
	import flash.desktop.Clipboard;
	import game.PlayerStatusGUI;
	import game.Room;
	import game.ui.Prompt;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxGroup;
	import org.flixel.FlxState;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import org.flixel.data.FlxGamepad;
	import game.ResourceManager;
	import game.Player;
	import playerio.*
	
	

	// PlayState is the FlxState where all the actual gameplay happens.
    public class PlayState extends FlxState
    {	
		// General PlayState stuff
		public var totalElapsed :Number; // total elapsed time since state's start.
		public var controlType :int; // 0 is LUDR movement, 1 is WASD movement
		
		// Our actual game stuff.
		public var players :Vector.<Player>;
		public var player :Player;
		public var playerHUDS:Vector.<PlayerStatusGUI>;
		public var dungeonSeed :int; // The random number used to add some randomness to the dungeon layout.
		public var dungeonLayout :Vector.<Vector.<Room>>; // The layout of the entire dungeon.
		public var curRoom :Room; // The room the player is currently in.
		public var justChangedRoom :Boolean;
		
		// The visual stuff for the room.
		public var floorMap :FlxTilemap;
		public var floorShadowsMap :FlxTilemap;
		public var wallMap :FlxTilemap;
		public var transWallMap :FlxTilemap;
		public var lightingMap :FlxTilemap;
		
		// Object groupings
		public var stairsUp :FlxGroup;
		public var stairsDown :FlxGroup;
		public var enemies :FlxGroup;
		public var chests :FlxGroup;
		
		// Visual layers that sit on top of everything
		public var lyrFX :FlxGroup;
		public var lyrGUI :FlxGroup;
		
		// Multiplayer connection stuff
		public var connection:Connection;
		public var playerIndex:int;
		
		
		
		override public function create():void
		{
			// We immediately set ResourceManager.playState to this instance.
			ResourceManager.playState = this;
			
			// Show the mouseNEVERMIND MOUSE DOESN'T EXIST YET LOLL
			// FlxG.mouse.cursor.visible = false;
			
			// Stage is defined by the time create() is called, so connection must be done here rather than the constructor.
			add(new Prompt(200, 200, "Where is the mouse cursor?", tryConnect)); //"What is your player's name?"
		}
		
		
		
		private function tryConnect(name :String) :void
		{
			// Try to connect to the game server once player has input his/her name
			PlayerIO.connect(
				stage,								//Referance to stage
				"draw-pad-lclpqsfmaums4xannguamw",	//Game id yeah - im using DrawPad's Server to start with. Whats it to ya.
				"public",							//Connection id, default is public
				name,								//Username
				"",									//User auth. Can be left blank if authentication is disabled on connection
				handleConnect,						//Function executed on successful connect
				handleError							//Function executed if we recive an error
			);
			
			// Hide the mouse.
			// FlxG.mouse.cursor.visible = false;
		}
		
		
		
		
		// This function gets called when a connection the server is established.
		private function handleConnect(client :Client) :void
		{
			// Set up all the actual game state stuff.
			init();
			
			//Set developmentsever (Comment out to connect to your server online)
			client.multiplayer.developmentServer = "24.107.232.63:8184"; //This is MY IP so that while im running the server others can connect to me. this is for
																		 //Testing purposes only.
			//Create pr join the room test
			client.multiplayer.createJoinRoom(
				"crawler",							//Room id. If set to null a random roomid is used
				"Crawler",							//The game type started on the server
				true,								//Should the room be visible in the lobby?
				{maxplayers:4},						//Room data. This data is returned to lobby list. Variabels[sic] can be modifed on the server
				{},									//User join data
				handleJoin,							//Function executed on successful joining of the room
				handleError							//Function executed if we got a join error
			);
		}
		
		
		
		// Handles a succesfully established connection by adding event callbacks.
		private function handleJoin(connection :Connection) :void
		{
			// Now that we've established a connection, set up all our event callbacks.
			//FlxG.log("Alright Connected to a Game. Though nothing cool happens yet");
			this.connection = connection;
			
			connection.addMessageHandler("GameInit", handleGameInit);
			connection.addMessageHandler("GameJoin", handlePlayerJoin);
			connection.addMessageHandler("GameLeft", handlePlayerLeft);
			connection.addMessageHandler("move", handlePlayerMove);
		}
		
		
		
		// This is called when a client first connects. this tells the player of all the positions of everything it needs to know.
		private function handleGameInit(m :Message, id :int) :void
		{
			FlxG.log("Handling Game Init");
			
			// Set up the tilemaps for the current level.
			floorMap = new FlxTilemap();
			floorMap.solid = false;
			floorMap.moves = false;
			
			floorShadowsMap = new FlxTilemap();
			floorShadowsMap.solid = false;
			floorShadowsMap.moves = false;
			
			wallMap = new FlxTilemap();
			wallMap.solid = true;
			wallMap.moves = false;
			
			transWallMap = new FlxTilemap();
			transWallMap.solid = false;
			transWallMap.moves = false;
			
			lightingMap = new FlxTilemap();
			lightingMap.solid = false;
			lightingMap.moves = false;
			
			// Set up the entities for the current level.
			stairsUp = new FlxGroup();
			stairsDown = new FlxGroup();
			enemies = new FlxGroup();
			chests = new FlxGroup();
			
			// Set up visual layers on top of the room.
			lyrFX = new FlxGroup();
			lyrFX.scrollFactor = new FlxPoint(0, 0);
			lyrGUI = new FlxGroup();
			lyrGUI.scrollFactor = new FlxPoint(0, 0);
			
			// Add all these tilemaps and entity groups to update() loop.
			add(floorMap);
			add(stairsUp);
			add(stairsDown);
			add(floorShadowsMap);
			add(chests);
			add(enemies);
			add(wallMap);
			add(transWallMap);
			add(lightingMap);
			add(lyrFX);
			add(lyrGUI);
			
			// Each player is null by default.
			player = new Player(200, 200, "TEST", null);
			players = new <Player>[null, null, null, null];
			
			// Set the dungeon layout seed to something random, and set up the dungeon layout.
			dungeonSeed = 10; //int(Math.random() * int.MAX_VALUE)
			
			// Set the first room up w/ a random seed.
			//var firstRoomSeed :int = 20;
			
			// If we got a message (a connection), load them in. Otherwise, just do singleplayer.
			// I THINK I BROKE THIS AGAINLOL
			
			if (m != null)
			{
				//Fill it with the current players (only names right now)
				for (var a:int = 2; a < m.length; a += 4)
				{
					//Make a new player            Server's X     Server's Y     Server's Name     no gfx so >:C
					var p:Player = new Player(m.getInt(a+2), m.getInt(a+3), m.getString(a+1), null);
					players[m.getInt(a)] = p;
					
					//Make sure player 0 doesnt control all the people who were there first. 'cause thats gay.
					players[m.getInt(a)].playerIndex = m.getInt(a);
					//FlxG.log(player.active);
				}
				
				// Set dungeon seed
				// dungeonSeed = m.getInt(?);
				
				// Set first room seed.
				// firstRoomSeed = m.getInt(?);
		    }
			else
			{
				// We couldn't connect to a server, so just start a local game.
				// Set player 0 to be us.
				players[0] = player;
				player.playerIndex = 0;
				
				FlxG.log("NO GAMEINIT MESSAGE RECEIVED. LOADING TEST MAP.");
			}
			
			// Add all players to the update loop.
			for (var i :int; i < 4; i++)
			{
				if (players[i] != null) add(players[i]);
			}
			
			// Make the players' HUDS and also add them to the update loop.
			playerHUDS = new <PlayerStatusGUI>[new PlayerStatusGUI(2, 2, players[0]), new PlayerStatusGUI(164, 2, players[1]), new PlayerStatusGUI(326, 2, players[2]), new PlayerStatusGUI(488, 2, players[3])];
			lyrGUI.add(playerHUDS[0], true);
			lyrGUI.add(playerHUDS[1], true);
			lyrGUI.add(playerHUDS[2], true);
			lyrGUI.add(playerHUDS[3], true);
			
			//Take control of your player
			//players[playerIndex].takeControl(playerIndex);
			
			// Generate the dungeon layout.
			generateDungeonLayout();	
			
			// Bind your inputs!
								// UP    DOWN    LEFT    RIGHT    A        X   B   Y    START    SELECT  LI   L2   R1   R2
			FlxG.gamepads[0].bind("UP", "DOWN", "LEFT", "RIGHT", "ENTER", "", "", "X", "SPACE", "T"   , "A", "S", "D", "");
			FlxG.gamepads[1].bind("W" , "S"   , "A"   , "D"    , "ENTER", "", "", "J", "SPACE", "T"   , "1", "2", "3", "");
			
			// Setup the room
			loadRoom(dungeonLayout[0][0], 0);
			
			// Some helpful text
			if (players[1] == null)
				FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1] + " Sprite2: " + players[2] + " Sprite3: " + players[3]);
			if (players[2] == null && players[1] != null)
				FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1].playerIndex + " Sprite2: " + players[2] + " Sprite3: " + players[3]);
			if (players[3] == null && players[1] != null && players[2] != null)
				FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1].playerIndex + " Sprite2: " + players[2].playerIndex + " Sprite3: " + players[3]);
			if (players[3] != null && players[1] != null && players[2] != null)
				FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1].playerIndex + " Sprite2: " + players[2].playerIndex + " Sprite3: " + players[3].playerIndex);
		}
		
		
		
		// Handle recieving movement locations from the server. - IGNORE YOUR OWN OR ELSE! (until later.)
		private function handlePlayerMove(m :Message, id :int, X :int, Y :int, velX :Number, velY :Number) :void
		{
			if (Number(id) == playerIndex) return;
			
			players[Number(id)].x = X;
			players[Number(id)].y = Y;
		}
		
		
		
		// This is called when someone joins the game!
		private function handlePlayerJoin(m :Message, id :int) :void
		{
			if (id == playerIndex) return;
			
			//A new user has joined! Lets give him a player
			if (players[id] != null)
			{
				players[id].playerIndex = id;
			}
			else
			{
				players[id] = new Player(200, 200, m.getString(1),null);
				add(players[id]);
			}
			players[id].takeControl(id);
			
			//and give that player to his HUD
			playerHUDS[id].addPlayer(players[id]);
		}
		
		
		
		// This is called when someone leaves the game!
		private function handlePlayerLeft(m :Message, id :int) :void
		{
			FlxG.log("User ID: " + (Number(id)) + " has left");
			//Boo someone left. Quick tear his shit down!
			players[id] = null;
			playerHUDS[id].removePlayer();
		}
		
		
		
		// This is called when something went wrong. ):
		private function handleError(error :PlayerIOError) :void
		{
			FlxG.log("Couldn't Connect");
			FlxG.log(error.getStackTrace());
			
			handleGameInit(null, 0);
		}
		
		
		
		// This sets up the game stuff.
		public function init() :void
		{
			// Set up general state stuff.
			totalElapsed = 0.0;
			
			// Set up the level generator.
			LevelGenerator.initialize();
			
			justChangedRoom = false;
			// Add the GUIs for each player.
			//lyrGUI.add(new PlayerStatusGUI(0, 0, players[0]), true);
			//lyrGUI.add(new PlayerStatusGUI(150, 0, players[1]), true);
			//lyrGUI.add(new PlayerStatusGUI(300, 0, players[2]), true);
			//lyrGUI.add(new PlayerStatusGUI(450, 0, players[3]), true);
			
			////          |
			////          |
			////        \ | /
			////         \|/
			////          V
			//this DEFINATELY needs to happen serverside. or AT LEAST the first client to generate tells the server about it.
			//	Stay tuned for more news on that at '11.
			
		}
		
		
		
		override public function update() :void
		{
			// Update totalElapsed.
			totalElapsed += FlxG.elapsed;
			// Update every add()'d game object.
			
			if (justChangedRoom)
			{
				justChangedRoom = false;
				FlxG.follow(player, 6);
			}
			// Update the camera's followAdjust according the player's INPUTS, not movement. (wait, that'll suck for sharp turning)
			//FlxG.followAdjust(player.buttonHeldDuration (not if hitting wall though)/cameraTweenDuration, etc); // update in real time
			
			super.update(); // before totalElapsed update? or after?
			
			// do collides AFTER the update.
			if (players != null && wallMap != null) players[playerIndex].collide(wallMap);
		}
		
		
		
		// This function will load in room into curRoom and make the necessary game updates.
		public function loadRoom(room :Room, stairIndex :int) :void
		{
			if (room == null) return;
			
			stairsUp.members = [];
			stairsDown.members = [];
			enemies.members = [];
			chests.members = [];
			lyrFX.members = [];
			
			/*
			floorMap = new FlxTilemap();
			floorShadowsMap = new FlxTilemap();
			wallMap = new FlxTilemap();
			transWallMap = new FlxTilemap();
			lightingMap = new FlxTilemap();
			*/
			
			var movedDownward :Boolean = true;
			if (curRoom != null && curRoom.depth > room.depth) movedDownward = false;
			
			curRoom = room;
			curRoom.generator.call(NaN, curRoom.seed, curRoom.tileSet);
			
			FlxG.followBounds(0, 0, floorMap.width, floorMap.height);
			FlxG.unfollow();
			
			// Put our player at the stairs he came from.
			if (movedDownward && stairsUp.members[stairIndex] != null) // why check this again?
			{
				player.x = (stairsUp.members[stairIndex] as FlxObject).x;
				player.y = (stairsUp.members[stairIndex] as FlxObject).y;
			}
			else if (!movedDownward && stairsDown.members[stairIndex] != null)
			{
				player.x = (stairsDown.members[stairIndex] as FlxObject).x;
				player.y = (stairsDown.members[stairIndex] as FlxObject).y;
			}
			else
			{
				FlxG.log("FUCK");
			}
			
			justChangedRoom = true;
			player.canMove = true;
			
			FlxG.flash.start(FlxU.getColor(0, 0, 0, 1.0), 0.3, null, true);
		}
		
		
		
		public function generateDungeonLayout() :void
		{
			// Get the dungeon layout ready for generation.
			dungeonLayout = new Vector.<Vector.<Room>>();
			
			var doneGenerating:Boolean = false;
			var curDepth :int = 0;
			
			// Set the randomSeed for the dungeon.
			FlxU.randomSeed = dungeonSeed;
			
			// Generate the dungeon layout from the dungeon seed.
			while (!doneGenerating)
			{
				// First of all, set up the level underneath the current one.
				dungeonLayout.push(new Vector.<Room>());
				
				if (curDepth == 0)
				{
					// Make a room on this level since there isn't one there already.
					dungeonLayout[0].push(new Room(int(FlxU.random() * int.MAX_VALUE), BasicGenerator.generate, ResourceManager.GFX_DUNGEON_TILES, curDepth));
					dungeonLayout[curDepth][0].roomsAbove[0] = null; // this is the top floor, no rooms above.
				}
				else if (curDepth > 0 && curDepth < 6)
				{
					// We are on levels 1 to 5 of the dungeon.
					// Make a new room here.
					dungeonLayout[curDepth].push(new Room(int(FlxU.random() * int.MAX_VALUE), BasicGenerator.generate, ResourceManager.GFX_DUNGEON_TILES, curDepth));
					
					// Connect it to the room above.
					dungeonLayout[curDepth - 1][0].roomsBelow[0] = dungeonLayout[curDepth][0];
					dungeonLayout[curDepth][0].roomsAbove[0] = dungeonLayout[curDepth - 1][0];
				}
				else if (curDepth >= 6 && curDepth < 10 - 1) // Maximum depth of 10 levels, for now.
				{
					// We are on levels 6 to 9 of the dungeon.
					// Make a new room here.
					dungeonLayout[curDepth].push(new Room(int(FlxU.random() * int.MAX_VALUE), BasicGenerator.generate, ResourceManager.GFX_DUNGEON_TILES, curDepth));
					
					// Connect it to the room above.
					dungeonLayout[curDepth-1][0].roomsBelow[0] = dungeonLayout[curDepth][0];
					dungeonLayout[curDepth][0].roomsAbove[0] = dungeonLayout[curDepth-1][0];
				}
				else
				{
					// We've reached the bottom of the dungeon!
					// Make a new room here.
					dungeonLayout[curDepth].push(new Room(int(FlxU.random() * int.MAX_VALUE), BasicGenerator.generate, ResourceManager.GFX_DUNGEON_TILES, curDepth));
					dungeonLayout[curDepth][0].roomsBelow[0] = null; // this is the bottom floor, no rooms below.
					
					// Connect it to the room above.
					dungeonLayout[curDepth-1][0].roomsBelow[0] = dungeonLayout[curDepth][0];
					dungeonLayout[curDepth][0].roomsAbove[0] = dungeonLayout[curDepth-1][0];
					
					// We're done generating this dungeon.
					doneGenerating = true;
				}
				
				curDepth++;
			}
		}
	}
}