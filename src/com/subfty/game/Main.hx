package com.subfty.game;

import com.subfty.sub.display.ImgSprite;
import com.subfty.sub.helpers.FixedAspectRatio;
import haxe.Firebug;
import haxe.Log;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.FPS;
import nme.events.Event;
import nme.Lib;

/**
 * ...
 * @author Filip Loster
 */

class Main extends Sprite 
{
	public static var STAGE_W:Int = 1024;
	public static var STAGE_H:Int = 600;
	
	public static var aspect:FixedAspectRatio;

  //TIMER
	private static var prevFrame:Int = -1;
	public static var delta:Int = 0;
	
  //SCENES
	public static var bg:Background;
	public static var sGame:GameScene;
	public static var sMenu:MenuScene;
	
	public function new() {
		super();
		
		aspect = new FixedAspectRatio(this, STAGE_W, STAGE_H);
		
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}

	static public function main() {
		var stage = Lib.current.stage;
		
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	
	private function init(e) {
		aspect.fix(null);
		
	  //INITING SCENES
		bg = new Background(this);
		sGame = new GameScene(this);
		sMenu = new MenuScene(this);
		
		this.stage.addEventListener(Event.RESIZE, aspect.fix);
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		
		sGame.visible = false;
	}
	
	function step(e:Event){
		if (prevFrame < 0) prevFrame = Lib.getTimer();
		delta = Lib.getTimer() - prevFrame;
		prevFrame = Lib.getTimer();
		
	}

  //GAME ACTIONS
	public static function startGame():Void {
		sMenu.visible = false;
		
		sGame.initGame();
	}
	public static function showMenu():Void {
		sGame.visible = false;
		sMenu.visible = true;
		
		for (i in 0...sGame.enemies.length)
			sGame.enemies[i].kill();
		
		bg.explosion.setX(sGame.player.ship.getX());
		bg.explosion.setY(sGame.player.ship.getY());
		bg.explosion.visible = true;
	}
}
