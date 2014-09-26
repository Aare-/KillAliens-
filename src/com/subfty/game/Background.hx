package com.subfty.game;
import com.subfty.sub.display.ImgSprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import nme.text.Font;
import nme.text.TextField;
import nme.text.TextFormat;

/**
 * ...
 * @author Filip Loster
 */

class Background extends Sprite {
	
	var background:ImgSprite;
	var movingStars1:ImgSprite;
	var movingStars2:ImgSprite;
	
	var plData1:BitmapData;
	var plData2:BitmapData;
	var plData3:BitmapData;
	var planet1:ImgSprite;
	var planet1delay:Float;
	
	public static var font:Font;
	public static var format:TextFormat;
	public var score:TextField;
	
	public var explosion:ImgSprite;
	
	public function new(p:Sprite) 
	{
		super();
		p.addChild(this);
		
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		
	  //BACKGROUND IMG INIT
		background = new ImgSprite(this, new Bitmap(Assets.getBitmapData("img/background.png")));
		background.setX(-Lib.current.stage.x);
		background.setY(-20);
		background.setWidth(Lib.current.stage.stageWidth+Lib.current.stage.x*2);
		background.setHeight(Lib.current.stage.stageHeight+20);
		
		//var b:Bitmap = new Bitmap(Assets.getBitmapData("img/moving_stars.png"));
		movingStars1 = new ImgSprite(this,new Bitmap(Assets.getBitmapData("img/moving_stars.png")));
		movingStars1.setX(0);
		movingStars1.setY(0);
		movingStars1.setWidth(1024);
		movingStars1.setHeight(600);
		
		movingStars2 = new ImgSprite(this, new Bitmap(Assets.getBitmapData("img/moving_stars.png")));
		movingStars2.setX(0);
		movingStars2.setY(0-600);
		movingStars2.setWidth(1024);
		movingStars2.setHeight(600);
		
		plData1 = Assets.getBitmapData("img/planet_1.png");
		plData2 = Assets.getBitmapData("img/planet_2.png");
		plData3 = Assets.getBitmapData("img/planet_3.png");
		
		planet1 = new ImgSprite(this, new Bitmap(plData1));
		planet1.visible = false;
		planet1.setWidth(300);
		planet1.setHeight(300);
		planet1.setImgOnCenter();
		
		font = Assets.getFont("fonts/PressStart2P.ttf");
		format = new TextFormat(font.fontName, 10, 0xFFFFFF);
		
		score = new TextField();
		score.defaultTextFormat = format;
		score.x = 200 * Main.aspect.scaleFactor;
		score.y = 250*Main.aspect.scaleFactor;
		score.width = 512*Main.aspect.scaleFactor;
		score.height = 200*Main.aspect.scaleFactor;
		score.text = "";
		score.alpha = 0.2;
		score.selectable = false;
		score.embedFonts = true;
		score.scaleX = score.scaleY = 16 * Main.aspect.scaleFactor;
		this.addChild(score);
		
		explosion = new ImgSprite(this, new Bitmap(Assets.getBitmapData("img/explosion.png")));
		explosion.setImgOnCenter();
		explosion.setWidth(80);
		explosion.setHeight(80);
		explosion.visible = false;
		
		planet1delay = -5;
	}
	
	private function step(e:Event):Void {
		movingStars1.setY(movingStars1.getY() + 300 * Main.delta/1000.0);
		
		if (movingStars1.getY() > 600) movingStars1.setY( -600);
		
		if (movingStars1.getY() > 0)
			movingStars2.setY(movingStars1.getY() - movingStars2.getHeight());
		else
			movingStars2.setY(movingStars1.getY()+movingStars1.getHeight());
		
		planet1delay -= Main.delta;
		if (!planet1.visible && planet1delay < 0) {
			
			planet1.setX(1024 * Math.random());
			planet1.setY(0 - planet1.getHeight());
			planet1.visible = true;
		}
		if (planet1.visible) {
			planet1.setY(planet1.getY() + 300 * Main.delta/1000.0*0.5);
			if (planet1.getY() > Main.STAGE_H+planet1.getHeight()){
				planet1.visible = false;
				planet1delay = 1000 + Math.random() * 2000;
				var d:Float = Math.floor(Math.random() * 3);
				if(d == 0)
					planet1.image.bitmapData = plData1;
				else if(d == 1)
					planet1.image.bitmapData = plData2;
				else
					planet1.image.bitmapData = plData3;
			}
		}
		
	}
	
}