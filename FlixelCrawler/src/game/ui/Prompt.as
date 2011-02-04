package game.ui 
{
	import org.flixel.*;
	
	public class Prompt extends FlxGroup
	{
		private var _background:FlxSprite;
		private var _name:FlxInputText;
		private var _prompt:FlxText;
		private var _confirm:FlxButton;
		private var _callback:Function;
		
		//This class bakes a small dialogue window. We can expand this later - I just slapped it together, easy enough to follow.
		public function Prompt(X:int, Y:int, text:String, callback:Function) 
		{
			super();
			_callback = callback;
			
			_background = new FlxSprite();
			_background.createGraphic(200, 50, 0xFF888888);
			_background.x = X;
			_background.y = Y;
			
			_prompt = new FlxText(X + 2, Y + 2, 196, text, true);
			_prompt.alignment = "center";
			
			_name = new FlxInputText(X + 2, Y + 15, 196, 20, "name", 0xFFFFFF, null, 10, "center");
			_name.filterMode = FlxInputText.ONLY_ALPHANUMERIC
			_name.setMaxLength(13);
			_name.backgroundColor = 0x222222;
			_name.alignment = "center";
			
			_confirm = new FlxButton(0, 0, confirm);
			_confirm.x = X + 50;
			_confirm.y = Y + 30;
			_confirm.width = 100;
			_confirm.height = 20;
			_confirm.loadText(new FlxText(25, 5, 45, "Confirm"));
			
			add(_background, true);
			add(_name, true);
			add(_prompt, true);
			add(_confirm, true);
		}
		
		private function confirm():void {
			if (_name.getText() != "") {
				_callback(_name.getText());
				destroy();
			}
		}
	}
}