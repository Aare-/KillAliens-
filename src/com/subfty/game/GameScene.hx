package com.subfty.game;
import nme.Assets;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;
import nme.text.Font;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

/**
 * ...
 * @author Filip Loster
 */

class GameScene extends Sprite{
	public var player:Player;

	private var _scoreV:Int;
	
	public var enemies : Array<Enemy>;
	private var enemySpawnDelay:Float = 0;
	
	public var bootTime:Float;
	private var _gameTime:Float;
	
	public function new(p:Sprite) {
		super();
		p.addChild(this);

		
		enemies = new Array<Enemy>();
		player = new Player(this);
		player.visible = false;
		
		Lib.stage.addEventListener(Event.ENTER_FRAME, step);
		
	}
	
	public function initGame():Void {
		for (i in 0...enemies.length)
			enemies[i].kill();
		if (Enemy.bullets != null)
			for (i in 0...Enemy.bullets.length)
				Enemy.bullets[i].kill();
		if(player.bullets != null)
			for (i in 0...player.bullets.length)
				player.bullets[i].kill();
		
		player.init();
		_scoreV = 0;
		addToScore(0);
		
		bootTime = 1500;
		
		enemySpawnDelay = 0;
		
		_gameTime = 0;
		this.visible = true;
		player.visible = true;
		
		Main.bg.explosion.visible = false;
	}
	
	public function addToScore(ammount:Int):Void {
		_scoreV += ammount;
	
		Main.bg.score.text = Std.string(_scoreV);
	}
	
	private function step(e:Event):Void {
		player.visible = false;
		if (!this.visible) return;
		player.visible = true;
		
		if (bootTime > 0) {
			bootTime -= Main.delta;
			return;
		}
		
		_gameTime += Main.delta;
		
		enemySpawnDelay -= Main.delta;
		if (enemySpawnDelay < 0) {
			enemySpawnDelay = getEnemyDelay();
			spawnEnemy();
		}
		
	  //CHECKING COLLISIONS
		  //PLAYER WITH ENEMY
		    for (i in 0...enemies.length) 
				if (enemies[i].visible) 
					if (areColliding(player.ship.getX(), player.ship.getY(),
									 enemies[i].ship.getX(), enemies[i].ship.getY(),
									 enemies[i].ship.getWidth() / 2 + player.ship.getWidth() / 2)) {
										enemies[i].explode(false);
										Main.showMenu();
									 }
				
		  //PLAYER WITH BULLETS
			if(Enemy.bullets != null)
				for (i in 0...Enemy.bullets.length)
					if (Enemy.bullets[i].visible)
						if (areColliding(player.ship.getX(), player.ship.getY(),
										 Enemy.bullets[i].img.getX(), Enemy.bullets[i].img.getY(),
										 Enemy.bullets[i].img.getWidth() / 2 + player.ship.getWidth() / 2)) {
										Main.showMenu();
									 }
					
			
		  //BULLET WITH ENEMY
			for (i in 0...player.bullets.length)
				if (player.bullets[i].visible)
					for (j in 0...enemies.length) 
						if (enemies[j].visible && !enemies[j].exploding) 
							if (areColliding(player.bullets[i].img.getX(), player.bullets[i].img.getY(),
											 enemies[j].ship.getX(), enemies[j].ship.getY(),
											 player.bullets[i].img.getHeight()/2+enemies[j].ship.getWidth()/2)){
								player.bullets[i].kill();
								enemies[j].explode();
							}
						
				
				
	}
	
	private inline function getEnemyDelay():Float {
		var maxDiff:Float = 2 * 60 * 1000;
		return 400;// + (maxDiff - Math.min(maxDiff, _gameTime)) / maxDiff * 1500;
	}
	private function spawnEnemy():Void{
		for (i in 0...enemies.length)
			if (!enemies[i].visible) {
				enemies[i].spawn();
				return;
			}
		
		enemies.push(new Enemy(this, player));
		spawnEnemy();
	}
	
	public inline function areColliding(a_x:Float, a_y:Float, b_x:Float, b_y:Float, len:Float):Bool {
		return Math.sqrt(Math.pow(b_x - a_x,2) + Math.pow(b_y - a_y,2)) <= len;
	}
}