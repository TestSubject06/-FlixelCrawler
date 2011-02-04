package game.states
{
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
		
		override public function create():void {
			//the create is where stage is defined, so connection must be done here and not constructor.
			var blah:Prompt = new Prompt(200, 200, "What's your name?", function(name:String) {
				PlayerIO.connect(
					stage,								//Referance to stage
					"draw-pad-lclpqsfmaums4xannguamw",	//Game id yeah - im using DrawPad's Server to start with. Whats it to ya.
					"public",							//Connection id, default is public
					name,								//Username
					"",									//User auth. Can be left blank if authentication is disabled on connection
					handleConnect,						//Function executed on successful connect
					handleError							//Function executed if we recive an error
				);   
			});
			add(blah);
		}
		
		private function handleConnect(client:Client):void {
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
		
		private function handleJoin(connection:Connection):void {
			FlxG.log("Alright Connected to a Game. Though nothing cool happens yet");
			this.connection = connection;
			
			//This is run when a client first connects. this tells the player of all the positions of everything it needs to know.
			connection.addMessageHandler("GameInit", function(m:Message, id:int) {
				//setup a null array for the client to fill
				players = new <Player>[null, null, null, null];
				
				//Fill it with the current players (only names right now)
				for (var a:int = 1; a < m.length; a += 4) {
					//Make a new player             Server's X      Server's Y     Server's Name    no gfx so >:C
					var player:Player = new Player(m.getInt(a+2), m.getInt(a+3), m.getString(a + 1),null);
					players[Number(m.getString(a))] = player;
					//Make sure player 0 doesnt control all the people who were there first. 'cause thats gay.
					players[Number(m.getString(a))].playerIndex = Number(m.getString(a));
					lyrFGSprites.add(player);
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
				if (players[1] == null)
					FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1] + " Sprite2: " + players[2] + " Sprite3: " + players[3]);
				if (players[2] == null && players[1] != null)
					FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1].playerIndex + " Sprite2: " + players[2] + " Sprite3: " + players[3]);
				if (players[3] == null && players[1] != null && players[2] != null)
					FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1].playerIndex + " Sprite2: " + players[2].playerIndex + " Sprite3: " + players[3]);
				if (players[3] != null && players[1] != null && players[2] != null)
					FlxG.log("Current sprites are: Sprite0: " + players[0].playerIndex + " Sprite1: " + players[1].playerIndex + " Sprite2: " + players[2].playerIndex + " Sprite3: " + players[3].playerIndex);
			});
			
				//Someone has joined the game!
			connection.addMessageHandler("GameJoin", function(m:Message, id:int) {
				if (id != playerIndex) {
					//A new user has joined! Lets give him a player
					var player:Player = new Player(200, 200, m.getString(1),null);
					players[id] = player;
					lyrFGSprites.add(player);
					players[id].takeControl(id);
					//and give that player to his HUD
					playerHUDS[id].addPlayer(players[id]);
					//FlxG.log(players[Number(id) - 1]);
				}
			});
			
			//Someone has left the game.
			connection.addMessageHandler("GameLeft", function(m:Message, id:int) {
					FlxG.log("User ID: " + (Number(id)) + " has left");
					//Boo someone left. Quick tear his shit down!
					lyrFGSprites.remove(players[Number(id)]);
					players[Number(id)] = null;
					playerHUDS[Number(id)].removePlayer();
			});
			
			//Handle recieving movement locations from the server. - IGNORE YOUR OWN OR ELSE! (until later.)
			connection.addMessageHandler("move", function(m:Message, id:int, X:int, Y:int, velX:Number, velY:Number) {
					if(Number(id) != playerIndex){
						players[Number(id)].x = X;
						players[Number(id)].y = Y;
					}
			});
		}
		private function handleError(error:PlayerIOError):void {
			FlxG.log("Couldn't Connect");
			FlxG.log(error.getStackTrace());
		}
		// How do you doc functions again
		public function init() : void
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
			
			////          |
			////          |
			////        \ | /
			////         \|/
			////          V
			//this DEFINATELY needs to happen serverside. or AT LEAST the first client to generate tells the server about it.
			//	Stay tuned for more news on that at '11.
			loadRoom(generateRoom());
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
			curRoom = room;
			FlxG.followBounds(0, 0, room.map.width - 32, room.map.height);
		}
		
		
		
		// This function will randomly generate a room!
		public function generateRoom() :Room
		{
			// Create a room of random width and height.
			var room :Room = new Room();
			
			var minSize :int = 40;
			var maxSize :int = 160;
			var w :int = minSize + (Math.random() * (maxSize - minSize));
			var h :int = minSize + (Math.random() * (maxSize - minSize));
			var level :Vector.<Vector.<int>> = new Vector.<Vector.<int>>(w, true);
			
			for (var i :int = 0; i < w; i++)
			{
				level[i] = new Vector.<int>(h, true);
			}
			
			// Generate the layout for the room.
			//var rooms 
			
			for (var j :int = 0; j < h; j++)
			{
				for (i = 0; i < w; i++)
				{
					level[i][j] = Room.FLOOR;
				}
			}

			// Convert this level to CSV.
			var mapCSV :String = "";
			
			for (j = 0; j < h; j++)
			{
				for (i = 0; i < w; i++)
				{
					//hoo-boy you sure do like your compact.
					mapCSV += (j == h-1 && i == w-1) ? (level[i][j].toString()) : ("" + level[i][j] + ",");
				}
				
				mapCSV += "\n";
			}
			
			// Finally, create a tilemap from this CSV.
			room.map.loadMap(mapCSV, room.tileSet, 32, 32);
			
			return room;
		}
	}
}