package com.subfty.game;
import com.subfty.sub.display.ImgSprite;
import com.subfty.sub.helpers.Vector2D;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
 * ...
 * @author Filip Loster
 */

class Bullet extends Sprite {
	private var SPEED = 500.0;
	private static var MAX_LEN = 30.0;
	
	public var img:ImgSprite;
	private var direction:Vector2D;
	private var len:Float;
	private var _life:Float;
	private var _type:Int;
	
	private static var bData:BitmapData = null;
	private static var bData2:BitmapData = null;
	
	public function new(p:Sprite, type:Int = 1) {
		super();
		p.addChild(this);
	
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		
		if(bData == null)
			bData = Assets.getBitmapData("img/bullet.png");
		if(bData2 == null)
			bData2 = Assets.getBitmapData("img/alien_bullet.png");			
			
		this._type = type;
			
		switch(type){
		case 1:
			img = new ImgSprite(this, new Bitmap(bData));
			img.setWidth(10);
			img.setHeight(18);
		case 2:
			img = new ImgSprite(this, new Bitmap(bData2));
			img.setWidth(15);
			img.setHeight(15);
			
		}
		this.addChild(img);
		
		img.setImgOnCenter();
		
		direction = new Vector2D(0, 1);
		this.visible = false;
	}
	
	public function fire(x:Float, y:Float, angle:Float):Void {
		img.setX(x);
		img.setY(y);
		
		direction.x = 1;
		direction.y = 0;
		direction.rotate(Vector2D.degToRad(angle));
		
		_life = 3000;
		this.visible = true;
		
		switch(_type) {
			case 1:
				SPEED = 900;
			case 2:
				SPEED = 500;
		}
	}
	
	public function kill() {
		this.visible = false;
	}
	
	private function step(e:Event):Void {
		if (this.visible) {
			img.setX(img.getX() - direction.x * SPEED * Main.delta/1000);
			img.setY(img.getY() - direction.y * SPEED * Main.delta / 1000);
			
			_life -= Main.delta;
			if (_life < 0) kill();
			
		}
	}
}