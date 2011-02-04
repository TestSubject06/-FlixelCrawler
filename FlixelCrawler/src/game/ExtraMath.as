package game
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxObject;
	
	
	
	// The ExtraMath class contains some convenience function for working with vectors!
	public class ExtraMath
	{
		
		// Flixel's overlap is a bit buggy sometimes. i wrote my own at some point (though it's only for 2 objects ):
		/*
		public static function overlap(Object1:FlxObject, Object2:FlxObject, Callback:Function = null) :Boolean
		{
			// Make sure the objects actually exist.
			if( (Object1 == null) || !Object1.exists ||
				(Object2 == null) || !Object2.exists )
				return false;
			
			// Use the FlxQuadTree if checking for overlaps of groups.
			if (Object1 as FlxGroup != null || Object2 as FlxGroup != null)
			{
				FlxObject o
				
				FlxU.quadTree.add(Object1, FlxQuadTree.A_LIST);
				FlxU.quadTree.add(Object2, FlxQuadTree.B_LIST);
				//FlxU.quadTree.overlap(
				return false;
			}
			
			// Just do simple overlap checking otherwise
			var disty :Number, distx :Number; 
			
			distx = Math.abs((Object2.x + (Object2.width/2)) - (Object1.x + (Object1.width/2))); 
			disty = Math.abs((Object2.y + (Object2.height/2)) - (Object1.y + (Object1.height/2))); 
				
			if ((distx <= (Object2.width + Object1.width) / 2) && (disty <= (Object2.height + Object1.height) / 2)) 
			{
				if (Callback != null) Callback.call();
				return true; 
			}
				
			return false;
		}
		*/
		
		
		
		public static function normalize(v :FlxPoint) :FlxPoint
		{
			var mag : Number = magnitude(v);
			
			var res : FlxPoint = new FlxPoint(0, 0);
			if (v.x != 0)
			{
				res.x = v.x / mag;
			}
			if (v.y != 0)
			{
				res.y = v.y / mag;
			}
			
			return res;
		}
		
		
		
		public static function magnitude(v :FlxPoint) :Number
		{
			return Math.sqrt( (v.x*v.x) + (v.y*v.y) );
		}
		
		public static function subtract(a :FlxPoint, b :FlxPoint) :FlxPoint
		{
			return new FlxPoint(a.x - b.x, a.y - b.y);
		}
		
		
		
		
		public static function deg2rad(d :Number) : Number
		{
			return d * Math.PI / 180;
		}
		
		public static function rad2deg(r :Number) : Number
		{
			return r * 180 / Math.PI;
		}
	}
}