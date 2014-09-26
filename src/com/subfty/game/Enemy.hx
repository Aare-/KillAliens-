package com.subfty.game;
import com.subfty.sub.helpers.Vector2D;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import com.subfty.sub.display.ImgSprite;
import nme.media.Sound;

/**
 * ...
 * @author Filip Loster
 */

class Enemy extends Sprite{
	public var ship:ImgSprite;
	private var attention:ImgSprite;
	
	private var _radius:Float;
	private var _angle:Float;
	private var _pos:Vector2D;
	private var _centerX:Float;
	private var _centerY:Float;
	
	private var _lookAt:Vector2D;
	private var _player:Player;
	
	public var exploding:Bool=false;
	private var explodingTime:Float;
	
  //MOVEMENT DATA
	private var _frequency:Float;
	private var _minRadius:Float;
	private var _floating:Float;
	private var _speed:Float;
	
  //BITMAP DATAS
	private static var _alienBD:BitmapData = null;
	private static var _atentionBD:BitmapData = null;
	private static var _explosionBD:BitmapData = null;
	
  //BULLETS
	public static var bullets : Array<Bullet>;
	private var _shootDelay:Float;
	
	//private static var explosion:Sound;
	//private static var lazorShoot:Sound;
	
	public function new(p:Sprite, player:Player) {
		super();
		
	  //LOADING STATIC DATA
		if (bullets == null)
			bullets = new Array<Bullet>();
		if(_atentionBD == null)
			_atentionBD = Assets.getBitmapData("img/atention.png");
		if(_alienBD == null)
			_alienBD = Assets.getBitmapData("img/alien.png");	
		if(_explosionBD == null)
			_explosionBD = Assets.getBitmapData("img/explosion.png");	
			
		this._player = player;
		
		p.addChild(this);
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		
		_pos = new Vector2D(1, 0);
		_lookAt = new Vector2D(0, 0);
			
		ship = new ImgSprite(this, new Bitmap(_alienBD));
		ship.setImgOnCenter();
		
		ship.setX(100);
		ship.setY(300);
		ship.setWidth(80);
		ship.setHeight(80);
		
		attention = new ImgSprite(this, new Bitmap(_atentionBD));
		attention.setImgOnCenter();
		
		attention.setX(100);
		attention.setY(300);
		attention.setWidth(60);
		attention.setHeight(60);
		attention.visible = false;
		
		this.visible = false;
		
		/*if (explosion == null) {
			explosion = Assets.getSound ("sounds/explosion.wav");
			lazorShoot = Assets.getSound ("sounds/laser_02.wav");
		}*/
	}
	
	private function step(e:Event):Void {
		if (!this.visible) return;
		
		if (exploding) {
			ship.image.bitmapData = _explosionBD;
			ship.setImgOnCenter();
			attention.visible = false;
			
			explodingTime -= Main.delta;
			if (explodingTime <= 0) kill();
			
			return;
		}
		
		_pos.x = 1;
		_pos.y = 0;
		_pos.rotate(_angle);
		_pos.mult(_radius);
		
		ship.setX(_pos.x+_centerX);
		ship.setY(_pos.y + _centerY);
		
		_lookAt.x = ship.getX() - _player.ship.getX();
		_lookAt.y = ship.getY() - _player.ship.getY();
		_lookAt.normalize();
		ship.rotation = _lookAt.getAngle()-90;
		
	  //CALCULATING POSITION
		_floating += (0.01 + 0.03 * _frequency) * Main.delta;
		_floating %= 360;
		
		_radius = 500 - (Math.sin((Vector2D.degToRad(_floating))+1)/2)*(500-_minRadius);// 0.006 * Main.delta;
		_angle += _speed * Main.delta;
		
		var diagonalW = ship.getWidth()*0.5;
		if (ship.getX() + diagonalW < 0) {
			attention.setWidth(Math.min(60, Math.max(20, (1 + (ship.getX() + diagonalW) / 300) * 40)));
			
			attention.visible = true;
			attention.setX(attention.getWidth()/2);
			attention.setY(ship.getY());

		}else if (ship.getX() - diagonalW > Main.STAGE_W) {
			attention.setWidth(Math.min(60,Math.max(20,(1-(ship.getX()-diagonalW-Main.STAGE_W)/300)*40)));
			
			attention.visible = true;
			attention.setX(Main.STAGE_W-attention.getWidth()/2);
			attention.setY(ship.getY());
		}else if (ship.getY() + diagonalW < 0) {
			attention.setWidth(Math.min(60, Math.max(20, (1 + (ship.getY() + diagonalW) / 300) * 40)));
			
			attention.visible = true;
			attention.setX(ship.getX());
			attention.setY(attention.getWidth()/2);
		}else if (ship.getY() - diagonalW > Main.STAGE_H) {
			attention.setWidth(Math.min(60,Math.max(20, (1 - (ship.getY() - diagonalW - Main.STAGE_H) / 300 ) * 40)));
			
			attention.visible = true;
			attention.setX(ship.getX());
			attention.setY(Main.STAGE_H-attention.getWidth()/2);
		}else {
			attention.visible = false;
		}
		
		attention.setHeight(attention.getWidth());
		attention.setX(Math.max(Math.min(attention.getX(), Main.STAGE_W - attention.getWidth() / 2), attention.getWidth() / 2));
		attention.setY(Math.max(Math.min(attention.getY(), Main.STAGE_H - attention.getWidth() / 2), attention.getWidth() / 2));
		attention.image.alpha = Math.min(attention.getWidth() - 20, 10) / 10.0;
		
	  //SHOOTING
		_shootDelay -= Main.delta;
		if (_shootDelay <= 0) {
			fire();
			_shootDelay = getShootDelay();
		}
	}
	
	public function spawn():Void {
		this.visible = true;
		
		ship.image.bitmapData = _alienBD;
		ship.setImgOnCenter();
		
		_angle = 360 * Math.random();
		_pos.x = 1;
		_pos.y = 0;
		_pos.rotate(Vector2D.degToRad(_angle));
		_radius = 500;
		 
		_centerX = Main.STAGE_W*0.1+Main.STAGE_W*0.8*Math.random();
		_centerY = Main.STAGE_H*0.1+Main.STAGE_H*0.8*Math.random();
		
		_shootDelay = getShootDelay();
		exploding = false;
		
		explodingTime = 500;
	  //CALCULATING MOVEMENT DETAILS
	    _floating = -90;
		_frequency = Math.random();
		_minRadius = 100 + 200 * Math.random();
		_speed = 0.0004 + 0.0008 * Math.random();
		  if (Math.random() > 0.5) _speed *= -1;
		
		
		step(null);
		while (!attention.visible) {
			_angle += 10;
			step(null);
		}
	}
	
	public function explode(addScore:Bool  = true):Void {
		this.exploding = true;
		//explosion.play();
		
		if(addScore)
			Main.sGame.addToScore(100);
	}
	
	public function kill():Void {
		
		this.visible = false;
	}
	
  //FIRING
	private function fire():Void {
		if (attention.visible || exploding) return;
		for (i in 0...bullets.length)
			if (!bullets[i].visible) {
				bullets[i].fire(ship.getX(), ship.getY(), _lookAt.getAngle());
				bullets[i].img.rotation = _lookAt.getAngle() - 90;
				//lazorShoot.play();
				return;
			}
		
		bullets.push(new Bullet(this,2));
		fire();
	}
	private inline function getShootDelay():Float {
		return 1000 + Math.random() * 3000;
	}
}