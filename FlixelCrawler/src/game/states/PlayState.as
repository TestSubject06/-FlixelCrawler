package game.states
{
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
	import game.ResourceManager; // Nope.
	import game.Player;
	import playerio.*
	
	

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
		public var playerHUDS:Vector.<PlayerStatusGUI>;
		public var neighboringRooms :Vector.<Room>;
		public var curRoom :Room;
		
		//MP stuff
		public var connection:Connection;
		public var playerIndex:int;
		
		
		
		override public function create():void
		{
			// Show the mouseNEVERMIND MOUSE DOESN'T EXIST YET LOLL
			// FlxG.mouse.cursor.visible = false;
			
			// Stage is defined by the time create() is called, so connection must be done here rather than the constructor.
			var blah :Prompt = new Prompt(200, 200, "What's your name?", tryConnect);
			
			add(blah);
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
			FlxG.log("Alright Connected to a Game. Though nothing cool happens yet");
			this.connection = connection;
			
			connection.addMessageHandler("GameInit", handleGameInit);
			connection.addMessageHandler("GameJoin", handlePlayerJoin);
			connection.addMessageHandler("GameLeft", handlePlayerLeft);
			connection.addMessageHandler("move", handlePlayerMove);
		}
		
		
		
		// This is called when a client first connects. this tells the player of all the positions of everything it needs to know.
		private function handleGameInit(m :Message, id :int) :void
		{
			//setup a null array for the client to fill
			players = new <Player>[null, null, null, null];
			
			//Fill it with the current players (only names right now)
			for (var a:int = 1; a < m.length; a += 4) {
				//Make a new player             Server's X      Server's Y     Server's Name    no gfx so >:C
				var player:Player = new Player(m.getInt(a+2), m.getInt(a+3), m.getString(a + 1),null);
				players[Number(m.getString(a))] = player;
				
				//Make sure player 0 doesnt control all the people who were there first. 'cause thats gay.
				players[Number(m.getString(a))].playerIndex = Number(m.getString(a));
			}
			
			//set the player index (controller port essentially)
			playerIndex = id;
			
			//get the HUDS down
			playerHUDS = new <PlayerStatusGUI>[new PlayerStatusGUI(2, 2, players[0]), new PlayerStatusGUI(164, 2, players[1]), new PlayerStatusGUI(326, 2, players[2]), new PlayerStatusGUI(488, 2, players[3])];
			lyrGUI.add(playerHUDS[0], true);
			lyrGUI.add(playerHUDS[1], true);
			lyrGUI.add(playerHUDS[2], true);
			lyrGUI.add(playerHUDS[3], true);
			
			//Take control of your player
			players[playerIndex].takeControl(playerIndex);
			
			//bind your keys to your 'virtual controller'
			FlxG.gamepads[playerIndex].bind("UP", "DOWN", "LEFT", "RIGHT", "Z", "X", "A", "C", "ENTER", ""     , "" , "" , "" , "" );
			
			//Tell the camera to follow your player
			FlxG.follow(players[playerIndex], 5);
			
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
			var player:Player = new Player(200, 200, m.getString(1),null);
			players[id] = player;
			lyrFGSprites.add(player);
			players[id].takeControl(id);
			//and give that player to his HUD
			playerHUDS[id].addPlayer(players[id]);
			//FlxG.log(players[Number(id) - 1]);
		}
		
		
		
		// This is called when someone leaves the game!
		private function handlePlayerLeft(m :Message, id :int) :void
		{
			FlxG.log("User ID: " + (Number(id)) + " has left");
			//Boo someone left. Quick tear his shit down!
			lyrFGSprites.remove(players[Number(id)]); // wow that's kind of extreme don't you think
			players[Number(id)] = null;
			playerHUDS[Number(id)].removePlayer();
		}
		
		
		
		// This is called when something went wrong. ):
		private function handleError(error :PlayerIOError) :void
		{
			FlxG.log("Couldn't Connect");
			FlxG.log(error.getStackTrace());
		}
		
		
		
		// This sets up the game stuff.
		public function init() :void
		{
			// Set up general state stuff.
			totalElapsed = 0.0;
			
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
			
			////          |
			////          |
			////        \ | /
			////         \|/
			////          V
			//this DEFINATELY needs to happen serverside. or AT LEAST the first client to generate tells the server about it.
			//	Stay tuned for more news on that at '11.
			loadRoom(BasicGenerator.generate());
			lyrBGMap.add(curRoom, true);
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