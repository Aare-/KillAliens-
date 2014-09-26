package com.subfty.game;
import com.subfty.sub.helpers.Vector2D;
import nme.Assets;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.Lib;
import nme.text.Font;
import nme.text.TextField;
import nme.text.TextFormat;

/**
 * ...
 * @author Filip Loster
 */

class MenuScene extends Sprite{
	
	private var _startGame:Bool;
	var font:Font;
	var format:TextFormat;
	
	var title:TextField;
	var touchToStart:TextField;
	var colorFluct:Float;
	
	public function new(p:Sprite) {
		super();
		
		font = Assets.getFont("fonts/PressStart2P.ttf");
		format = new TextFormat(font.fontName, 20, 0xFFFFFF);
		
		title = new TextField();
		title.defaultTextFormat = format;
		title.x = 50 * Main.aspect.scaleFactor;
		title.y = 100 * Main.aspect.scaleFactor;
		title.width = 1024*Main.aspect.scaleFactor;
		title.height = 200*Main.aspect.scaleFactor;
		title.text = "KILL ALIENS!";
		title.alpha = 0.8;
		title.scaleX = title.scaleY = 4*Main.aspect.scaleFactor;
		title.selectable = false;
		title.embedFonts = true;
		this.addChild(title);
		
		touchToStart = new TextField();
		touchToStart.defaultTextFormat = format;
		touchToStart.x = 250 * Main.aspect.scaleFactor;
		touchToStart.y = 500 * Main.aspect.scaleFactor;
		touchToStart.width = 1024*Main.aspect.scaleFactor;
		touchToStart.height = 200 * Main.aspect.scaleFactor;
		#if (flash && gamepad)
			touchToStart.text = "-PRESS A START-";
		#else
			touchToStart.text = "-TOUCH TO START-";
		#end
		touchToStart.alpha = 0.8;
		touchToStart.scaleX = touchToStart.scaleY = 1.6 * Main.aspect.scaleFactor;
		touchToStart.selectable = false;
		touchToStart.embedFonts = true;
		this.addChild(touchToStart);
		
		p.addChild(this);
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		Lib.stage.addEventListener(TouchEvent.TOUCH_TAP, clicked);
		
		#if !(flash && gamepad)
			Lib.stage.addEventListener(MouseEvent.CLICK, clicked);
		#end
		
		_startGame = false;
		colorFluct = 0;
	}
	
	public function clicked(e):Void {
		if (this.visible) {
			_startGame = true;
		}
	}
	
	private function step(e:Event):Void {
		if (!this.visible) return;
		
		colorFluct += Main.delta * 0.3;
		colorFluct %= 360;
		touchToStart.alpha = 0.6 + Math.sin(Vector2D.degToRad(colorFluct)) * 0.3;
		
		#if (flash && gamepad)
			var gamepads : Array<com.subfty.sub.helpers.GamepadProxy.Gamepad> = com.subfty.sub.helpers.GamepadProxy.getGamepads();
			var gamepad:com.subfty.sub.helpers.GamepadProxy.Gamepad = if (gamepads != null) gamepads[0] else null;
			
			if (gamepad != null)
				if (gamepad.buttons[0] > 0.9)
					clicked(null);
		
		#end
		
		if (_startGame) {
			Main.startGame();
			_startGame = false;
		}
	}
	
}