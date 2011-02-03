package game 
{	
	// SEE ABOUT MAKING AND EMBEDDING AN "ASSETS.SWF" LATER ON INSTEAD OF ALL THIS JUNK
	
	// The structure of this resource manager would be nicer if there were some way we could do something like 
	//		ResourceManager.bgm.SONG01
	// instead of
	//		ResourceManager.BGM_SONG01
	//
	// but whateverLOL
	


	public class ResourceManager
	{
		// Assets directory // NEVERMIND CAN'T USE VARIABLES FOR EMBED PATHS
		// private static const ASSETS_DIR :String = "../../assets/";
		// private static const GFX_DIR :String = ASSETS_DIR + "gfx/";
		
		// GFX EMBEDS
		[Embed(source = "../../assets/gfx/mockRPG.png")] public static const GFX_MOCK_RPG :Class;
		[Embed(source = "../../assets/gfx/enemy.png")] public static const GFX_ENEMY1 :Class;
		
		// SFX EMBEDS
		[Embed(source = "../../assets/sfx/player_hurt.mp3")] public static const SFX_PLAYER_HURT :Class;
		
		// BGM EMBEDS
		//[Embed(source = "../../assets/bgm/no_music.mp3")] public static const BGM_NO_MUSIC :Class;
		//[Embed(source = "../../assets/bgm/beep_boop.mp3")] public static const RANDOM_SONG :Class;
		
		// MAP EMBEDS
		
		// FONT EMBEDS
		
		
		
		// Variables
		/*
		public static var gfx :Vector.<Class>; // no this is dumb, why would anyone access a resource this way
		public static var sfx :Vector.<Class>;
		public static var bgm :Vector.<Class>;
		public static var maps :Vector.<Class>;
		public static var fonts :Vector.<Class>;
		*/
	}
}