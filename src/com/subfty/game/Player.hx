package com.subfty.game;
import com.subfty.sub.display.ImgSprite;
import com.subfty.sub.helpers.GamepadProxy;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.Lib;
import nme.events.TouchEvent;
import nme.media.Sound;
import nme.media.SoundTransform;
import nme.text.TextField;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;

/**
 * ...
 * @author Filip Loster
 */

class Player extends Sprite{
	public var ship:ImgSprite;
	
  //PLAYER STATE
	public var speed:Float = 0;
	private var MAX_SPEED:Float = 300;
	
	public var bullets : Array<Bullet>;
	private var fireDelay:Float=0;
	
  //TIMER
	var prevFrame:Int = -1;
	var delta:Int = 0;
	
  //DEBUG SCORE
    var touch:TextField;
	
  //INPUT
	private var clicked:Bool = false;
	private var deltaX:Float = 0;
	private var deltaY:Float = 0;
	private var prevX:Float = 0;
	private var prevY:Float = 0;
	
	private var gun:Bool=false;

	//var laserShoot:Sound;
	
	public function new(p:Sprite) {
		super();
		
		//laserShoot = Assets.getSound ("sounds/laser_01.wav");
		
		p.addChild(this);
		
		bullets = new Array<Bullet>();
		
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		
		#if !(flash && gamepad)
				//Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
				//Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
				//Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
				
				// Find out whether multitouch is supported

					// If so, set the input mode and hook up our event handlers
					// TOUCH_POINT means simple touch events will be dispatched, 
					// rather than gestures or mouse events
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

				/*Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);*/
				
				
				Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		#end
		
		ship = new ImgSprite(this, new Bitmap(Assets.getBitmapData("img/ship.png")));
		ship.setImgOnCenter();
		
		
		ship.setWidth(80);
		ship.setHeight(80);
		
		#if (flash && gamepad)
			GamepadProxy.start();
		#end
		
		touch= new TextField();
		touch.defaultTextFormat = Background.format;
		touch.x = 300 * Main.aspect.scaleFactor;
		touch.y = 250*Main.aspect.scaleFactor;
		touch.width = 512*Main.aspect.scaleFactor;
		touch.height = 200*Main.aspect.scaleFactor;
		touch.text = "x: y: ";
		touch.alpha = 0.5;
		touch.selectable = false;
		touch.embedFonts = true;
		touch.scaleX = touch.scaleY = 4 * Main.aspect.scaleFactor;
		//this.addChild(touch);
	}
	
	public function init():Void {
		ship.setX(512);
		ship.setY(500);
		
		speed = 0;
		clicked = false;
		
		deltaX = 0;
		deltaY = 0;
		
		for(i in 0...bullets.length)
			bullets[i].kill();
			
		fireDelay = 100;
	}
	
  //TOUCH EVENTS
		/*private function onTouchBegin(e):Void {
			clicked = true;
			
			prevX = e.stageX / Main.aspect.scaleFactor;
			prevY = e.stageY / Main.aspect.scaleFactor;
			
			touched(e,
					prevX,
					prevY);
		}
		private function onTouchMove(e):Void {
			touched(e, 
					e.stageX / Main.aspect.scaleFactor,
					e.stageY / Main.aspect.scaleFactor);
		}
		private function onTouchEnd(e):Void {
			clicked = false;
		}*/

		private function onTouchBegin(e:TouchEvent):Void {
			clicked = true;
			
			//touch.text = "tb x: " + e.stageX + " y: " + e.stageY;
			
			prevX = e.stageX / Main.aspect.scaleFactor;
			prevY = e.stageY / Main.aspect.scaleFactor;
			
			touched(e,
					prevX,
					prevY);
		}
		private function onTouchMove(e:TouchEvent):Void {
			//touch.text = "tm x: " + e.stageX + " y: " + e.stageY;
			touched(e, 
					e.stageX / Main.aspect.scaleFactor,
					e.stageY / Main.aspect.scaleFactor);
		}
		private function onTouchEnd(e:TouchEvent):Void {
			//touch.text = "te x: " + e.stageX + " y: " + e.stageY;
			clicked = false;
		}

	private function touched(e, X:Float, Y:Float):Void {
		if (clicked) {
		  //MOVEMENT
			deltaX = (X - prevX)*3.3;
			deltaY = (Y - prevY)*3.3;
			
			prevX = X;
			prevY = Y;
		}
	}

  //FRAME
	private function step(e:Event):Void {
		if (!this.visible) return;
		
		
		
		fireDelay -= Main.delta;
		#if ! (flash && gamepad)
			if (fireDelay < 0) {
				fire();
				fireDelay = 100;
			}
		#end
		
		if (Main.sGame.bootTime > 0) {
			if (Math.floor(Main.sGame.bootTime / 200) % 2 == 0)
				ship.visible = false;
			else
				ship.visible = true;
		}else 
			ship.visible = true;
			
		if (prevFrame < 0) prevFrame = Lib.getTimer();
		delta = Lib.getTimer() - prevFrame;
		
		#if (flash && gamepad)
			var gamepads : Array<com.subfty.sub.helpers.GamepadProxy.Gamepad> = com.subfty.sub.helpers.GamepadProxy.getGamepads();
			var gamepad:com.subfty.sub.helpers.GamepadProxy.Gamepad = if (gamepads != null) gamepads[0] else null;
			
			if (gamepad != null){				
				
				if(Math.abs(gamepad.axes[2]) > 0.5)
					deltaX = gamepad.axes[2] * 35;
				if(Math.abs(gamepad.axes[3]) > 0.5)
					deltaY = gamepad.axes[3] * 35;
					
				if (gamepad.buttons[4] > 0.5 || gamepad.buttons[5] > 0.5 || gamepad.buttons[6] > 0.5 || gamepad.buttons[7] > 0.5) 
					if (fireDelay < 0) {
						fire();
						fireDelay = 100;
					}
			}
		
		#end
		
		ship.setX(Math.max(Math.min(ship.getX() + deltaX, Main.STAGE_W - ship.getWidth() / 2), ship.getWidth() / 2));
		ship.setY(Math.max(Math.min(ship.getY() + deltaY, Main.STAGE_H - ship.getHeight() / 2), ship.getHeight() / 2));
	
		deltaX = deltaY = 0;
		
	  //SPEEDING UP
	    if (speed < MAX_SPEED)
			speed += 0.1 * delta;
		
		prevFrame = Lib.getTimer();
	}
	
	private function fire():Void {
		if (!this.visible)
			return;
		for (i in 0...bullets.length)
			if (!bullets[i].visible) {
				
				if(gun)
					bullets[i].fire(ship.getX()+35, ship.getY()+10, 90);
				else
					bullets[i].fire(ship.getX() - 35, ship.getY()+10, 90);
				gun = !gun;
				return;
			}
		
		bullets.push(new Bullet(this));
		fire();
	}
}