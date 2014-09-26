package com.subfty.sub.helpers;

import nme.display.DisplayObject;
import nme.display.Sprite; 
import nme.events.Event;
import nme.Lib;
 
/**
 * @author Camden Reslink
 */
 
class FixedAspectRatio {
	private var intendedWidth:Float;
	private var intendedHeight:Float;
	private var intendedAspectRatio:Float;
	private var screenAspectRatio:Float;
	private var sprite:Sprite;
	
	public var scaleFactor:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	
	private var boundingBars:Sprite;
	
	public function new ( stage:Sprite, intendedWidth:Float, intendedHeight:Float ) {
		this.sprite = stage;
		this.intendedWidth = intendedWidth;
		this.intendedHeight = intendedHeight;
	}
	
	public function fix( e:Event ):Void {
		screenAspectRatio = (sprite.stage.stageWidth / sprite.stage.stageHeight);
		intendedAspectRatio = intendedWidth/intendedHeight;
		if ( screenAspectRatio > intendedAspectRatio ) {
			var scaleInfoArray:Array<Float> = screenIsWider();
			scaleFactor = scaleInfoArray[0];
			offsetX = scaleInfoArray[1];
			offsetY = scaleInfoArray[2];
		} else {
			var scaleInfoArray:Array<Float> = screenIsNarrower();
			scaleFactor = scaleInfoArray[0];
			offsetX = scaleInfoArray[1];
			offsetY = scaleInfoArray[2];
		}
	}
	
	private function screenIsWider():Array<Float> {
		// The first entry of the returned array is the scale the app was multiplied to fit in the screen
		// The second entry of the returned array is the x-offset required (the width of one vertical black bar)
		// The third entry of the returned array is the y-offset required (the width of one horizontal black bar)
		
		var maskHeight:Float = sprite.stage.stageHeight;
		var maskWidth:Float = maskHeight * intendedAspectRatio;
		var maskX:Float = (sprite.stage.stageWidth - maskWidth) * 0.5;
		var maskY:Float = 0;
		
		if(boundingBars == null){
			boundingBars = new Sprite();
			Lib.stage.addChild(boundingBars);
		}
		boundingBars.graphics.clear();
		boundingBars.graphics.beginFill(0x000000);
		boundingBars.graphics.drawRect(0, 0, maskX, maskHeight);
		boundingBars.graphics.drawRect(maskX + maskWidth, 0, maskX, maskHeight);
		Lib.stage.addChild(boundingBars);
 
		var newScale:Float = sprite.stage.stageHeight / intendedHeight;
		sprite.x = maskX;
		return [newScale, maskX, maskY];
	}
	
	private function screenIsNarrower():Array<Float> {
		// The first entry of the returned array is the scale the app was multiplied to fit in the screen
		// The second entry of the returned array is the x-offset required (the width of one vertical black bar)
		// The third entry of the returned array is the y-offset required (the width of one horizontal black bar)
		
		var maskWidth:Float = sprite.stage.stageWidth;
		var maskHeight:Float = maskWidth * ( 1 / intendedAspectRatio );
		var maskX:Float = 0;
		var maskY:Float = (sprite.stage.stageHeight - maskHeight) * 0.5;
		
		if(boundingBars == null){
			boundingBars = new Sprite();
			Lib.stage.addChild(boundingBars);
		}
		boundingBars.graphics.clear();
		boundingBars.graphics.beginFill(0x000000);
		boundingBars.graphics.drawRect(0, 0, maskX, maskHeight);
		boundingBars.graphics.drawRect(maskX + maskWidth, 0, maskX, maskHeight);
		Lib.stage.addChild(boundingBars);
		
		var newScale:Float = sprite.stage.stageWidth / intendedWidth;
		sprite.y = maskY;
		return [newScale, maskX, maskY];
	}
	
}