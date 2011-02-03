package game 
{
	import org.flixel.data.FlxGamepad;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxU;
	import org.flixel.FlxSprite;
	import org.flixel.FlxGroup;
	import org.flixel.FlxText;


	
	public class PlayerStatusGUI extends FlxGroup
	{
		public var player :Player;
		public var bg :FlxSprite;
		public var faceIcon :FlxSprite;
		public var name :FlxText;
		public var hpBar :FlxSprite;
		public var mpBar :FlxSprite;
		
		
		
		public function PlayerStatusGUI(X :Number = 0, Y :Number = 0, player :Player = null)
		{
			// Link to player.
			this.player = player;
			scrollFactor = new FlxPoint(0, 0); // gotta do this.
			
			if (player != null)
			{
				// Set up GUI sprites and whatnot.
				bg = new FlxSprite(0, 0, ResourceManager.GFX_PLAYER_HUD_BG);
				if (player.faceImg != null) faceIcon = new FlxSprite(3, 3, player.faceImg);
				else faceIcon = new FlxSprite(3, 3, ResourceManager.GFX_PLAYER_FACE_ICON);
				if (player.name != null) name = new FlxText(faceIcon.x + 42, faceIcon.y - 2, 100, player.name);
				else name = new FlxText(faceIcon.x + 42, faceIcon.y, 100, "NULL");
				name.setFormat(null, 10, FlxU.getColor(255, 255, 255));
				hpBar = new FlxSprite(name.x, name.y + 16);
				hpBar.loadGraphic(ResourceManager.GFX_PLAYER_HP_BAR, true, false, 102, 12);
				var framesArray :Array = [];
				while (framesArray.length < 48) // 48 is number of frames in hp bar anim
					framesArray[framesArray.length] = framesArray.length;
				hpBar.addAnimation("idle", framesArray, 15);
				hpBar.play("idle");
				mpBar = new FlxSprite(hpBar.x, hpBar.y + hpBar.height + 2, ResourceManager.GFX_PLAYER_MP_BAR);
				
				// Add all the sprites to members.
				add(bg, true);
				add(faceIcon, true);
				add(name, true);
				add(hpBar, true);
				add(mpBar, true);
			}
		}
		
		
		
		override public function update() :void
		{
			// before update stuff
			
			super.update();
			
			// after update stuff
		}
	}
}