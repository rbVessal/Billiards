package code
{
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.media.SoundChannel;
	import flash.media.Sound;

    public class Billiard extends Sprite
    {
        private var balls:Array;
        private var numBalls:uint = 16;
        private var bounce:Number = -1.0;
		
		//Create instance of border
		private var outerBorder:Border;
		//Create an instance of table
		private var table:Table;
		//Create an instance of an invisible wall
		private var invisibleWall:InvisibleWall;
		
		//Declare constant for border width
		private var BORDER_WIDTH:Number = 34.95;
		
		//Create attributes
		private var posX:Number = 0;
		private var posY:Number = 0;
		private var startingPosX:Number = 0;
		private var startingPosY:Number = 0;
		private var friction:Number = 0.95;
		private var mouseClickDown:Boolean = false;
		private var pockets:Array;
		private var numPockets:int = 6;
		private var cueBall:Ball;
		
		private var collision:Boolean = false;
		private var pocketCollision:Boolean = false;
		
		//Main game music
		private var gameThemeMusicChannel:SoundChannel;
		private var gameThemeMusic:Sound;
		//Collision sound effect
		private var collisionSoundChannel:SoundChannel;
		private var collisionSound:Sound;
		//Pocket sound effect
		private var pocketSoundChannel:SoundChannel;
		private var pocketSound:Sound;

        public function Billiard()
        {
            init();
        }

        private function init():void
        {
			//Intialize the soundchannel
			gameThemeMusicChannel = new SoundChannel();
			//Declare and intialize a URLRequest for the external sound
			var externalSoundRequest:URLRequest = new URLRequest("sounds/japaneseJazz.mp3");
			//Load the game theme music into the sound variable
			gameThemeMusic = new Sound(externalSoundRequest);
			//Play the external sound and make it loop forever
			gameThemeMusicChannel = gameThemeMusic.play(0, 9999);
			
			collisionSoundChannel = new SoundChannel();
			var externalSoundRequest2:URLRequest = new URLRequest("sounds/collision.mp3");
			collisionSound = new Sound(externalSoundRequest2);
			
			pocketSoundChannel = new SoundChannel();
			var externalSoundRequest3:URLRequest = new URLRequest("sounds/pocket.mp3");
			pocketSound = new Sound(externalSoundRequest3);
			
			//Initialize the outerborder
			outerBorder = new Border();
			addChild(outerBorder);
			outerBorder.x = 0;
			outerBorder.y = 0;
			
			//Initialize the table
			table = new Table();
			addChild(table);
			//Position the table
			table.x = stage.stageWidth/2 - table.width/2;
			table.y = stage.stageHeight/2 - table.height/2 + 1.5;
			
			//Initialize the invisible wall
			invisibleWall = new InvisibleWall();
			//Create pockets for the balls to fall in
			createPockets(15);
			
			//Position the cue ball and the balls in the triangle
			positionBallsOnTable(10);
			
			
			//Position the invisible wall
			addChild(invisibleWall);
			invisibleWall.x = 0;
			invisibleWall.y = 0;
			
			
			
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
        }
		
		private function createPockets(radius:Number)
		{
			pockets = new Array();
			var posX:Number;
			var posY:Number;
			
			for(var i:int = 0; i < numPockets; i++)
			{
				var ball:Ball = new Ball(radius, 0);
				//Place pockets
				//1st pocket in upper left corner
				if(i == 0)
				{
					posX = table.x;
					posY = table.y;
					ball.x = posX;
					ball.y = posY;
				}
				else if(i > 0 && i < 3)
				{
					posX += table.width/2;
					ball.x = posX;
					ball.y = posY;
				}
				else if(i == 3)
				{
					posY += table.height;
					ball.x = posX;
					ball.y = posY;
				}
				else if(i > 3 && i < 6)
				{
					posX -= table.width/2;
					ball.x = posX;
					ball.y = posY;
				}
				
				//Add them onto the stage
				addChild(ball);
				//Place them into the array
				pockets.push(ball);
				
				
			}
		}
		
		//Positions all of the balls on the billard table
		private function positionBallsOnTable(radius:Number)
		{
			//Create some balls
            balls = new Array();
			
			//Create the cue ball and position it
			//Create the cue ball
			cueBall = new Ball(radius, 0xffffff);
			cueBall.mass = radius;
			//Position it
			startingPosX = outerBorder.width/4;
			startingPosY = outerBorder.height/2;
			cueBall.x = startingPosX;
			cueBall.y = startingPosY;
			//trace("cueball's startingPos: " + startingPosX);
			//Add it onto the stage
			addChild(cueBall);
			//Add it to the balls array
			balls.push(cueBall);
			//trace("initial array length " + balls.length);
			
			//Use temp variable for setting up the balls in the triangle
			var tempX:Number;
			var tempY:Number; 
			var tempOffset:Number = 2;
			
            for(var i:uint = 1; i < numBalls; i++)
            {
				//Create the cue ball
                var ball:Ball = new Ball(radius, Math.random() * 0xffffff);
                ball.mass = radius;
				//trace("BEFORE   ball x " + ball.x + "y " + ball.y + "num   " + i);
				//5 balls in the back -- 5th column
				//first ball near the top
				if(i == 1)
				{
					tempX = table.width - table.width/5;
					tempY = table.height/2.2;
					ball.x = tempX;
					ball.y = tempY;
					
				}
				//other 4 balls for the 5th column
				else if(i > 1 && i < 6)
				{
					tempY += ball.radius * 2 + tempOffset;
					ball.x = tempX;
					ball.y = tempY;
				}
				//4 balls -- 4th column
				//first ball near the top
				else if(i == 6)
				{
					tempX -= ball.radius * 2 + tempOffset;
					tempY = balls[2].y - ball.radius;
					ball.x = tempX;
					ball.y = tempY;
				}
				//other 3 balls for the 4th column
				else if(i > 6 && i < 10)
				{
					tempY += ball.radius * 2 + tempOffset;
					ball.x = tempX;
					ball.y = tempY;
				}
				//3 balls -- 3rd column
				//first ball near the top
				else if(i == 10)
				{
					tempX -= ball.radius * 2 + tempOffset;
					tempY = balls[2].y;
					ball.x = tempX;
					ball.y = tempY;
				}
				else if(i > 10 && i < 13)
				{
					tempY += ball.radius * 2 + tempOffset;
					ball.x = tempX;
					ball.y = tempY;
				}
				//2 balls -- 2nd column
				//first ball near the top
				else if(i == 13)
				{
					tempX -= ball.radius * 2 + tempOffset;
					tempY = balls[7].y;
					ball.x = tempX;
					ball.y = tempY;
				}
				//other ball
				else if(i > 13 && i < 15)
				{
					tempY += ball.radius * 2 + tempOffset;
					ball.x = tempX;
					ball.y = tempY;
				}
				//1 ball -- 1st column
				else if(i == 15)
				{
					tempX -= ball.radius * 2 + tempOffset;
					tempY = balls[0].y;
					ball.x = tempX;
					ball.y = tempY;
				}
				
				
                ball.vx = 0;
                ball.vy = 0;
				
				//trace("AFTER   ball x " + ball.x + "y " + ball.y + "\n");
				addChild(ball);
				balls.push(ball);
				//trace("array's length" + balls.length);
			}
		}
		
		//Allows the user to hold down on the cueball to draw a virtual
		//cueball stick
		private function aimCueBall(mouseEvent:MouseEvent)
		{
			mouseClickDown = true;
			if(mouseClickDown)
			{
				addEventListener(Event.ENTER_FRAME, aim);
			}
			
		}
		
		private function aim(event:Event)
		{
			
			//Draw the line from the cue ball to the mouse
			invisibleWall.graphics.clear();
			invisibleWall.graphics.lineStyle(1, 0, 1);
			//trace("cueball's initial position: " + Ball(balls[0]).x + " y " +  Ball(balls[0]).y);
			invisibleWall.graphics.moveTo(balls[0].x, balls[0].y);
			invisibleWall.graphics.lineTo(mouseX, mouseY);
			
		}
		
		//Calculates the direction and magnitude of the velocity of the cue stick
		//And adds that to vx and vy
		private function releaseCueBall(mouseEvent:MouseEvent)
		{
			mouseClickDown = false;
			removeEventListener(Event.ENTER_FRAME, aim);
			//Clear the line once the user lets go of the mouse click
			invisibleWall.graphics.clear();
			
			//Calculate the distance between the cueball and the user's mouse
			var deltaX:Number = mouseX - balls[0].x;
			var deltaY:Number = mouseY - balls[0].y;
			//Calculate the magnitude of the velocity
			//var velocity = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
			//trace("deltaX: " + deltaX + "deltaY: " + deltaY);
			//var angle = Math.atan2(deltaY, deltaX);
			
			//Get the angle of the ball
			
			//Convert it to radians
			//var radians = angle * Math.PI/180;
			//trace(velocity);
			//Calculate the velocity components
			var vx = deltaX;
			var vy = deltaY;
			//Use these velocity components for the ball
			balls[0].vx = -vx;
			balls[0].vy = -vy;
		}
		
        private function onEnterFrame(event:Event):void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, aimCueBall);
			addEventListener(MouseEvent.MOUSE_UP, releaseCueBall);
			
			for(var i:uint = 0; i < numBalls; i++)
			{
				var ball:Ball = balls[i];
				ball.vx *= friction;
				ball.vy *= friction;
				ball.x += ball.vx;
				ball.y += ball.vy;
				checkWalls(ball);
				if(collision)
				{
					collisionSoundChannel = collisionSound.play();
					collision = false;
				}
				checkPockets(ball);
				if(pocketCollision)
				{
					pocketSoundChannel = pocketSound.play();
					pocketCollision = false;
				}
				
			}
			for(i = 0; i < numBalls - 1; i++)
			{
				var ballA:Ball = balls[i];
				for(var j:Number =i+1;j< numBalls; j++)
				{
					var ballB:Ball = balls[j];
					checkCollision(ballA, ballB);
					if(collision)
					{
						collisionSoundChannel = collisionSound.play();
						collision = false;
					}
					
				}
			}
			
			//Check for winning condition
			if(numBalls == 1)
			{
				//Reset the playing field
				balls.splice(0, 1);
				removeChild(cueBall);
				numBalls = 16;
				positionBallsOnTable(10);
				
			}
		}
		
		//Check collisions between the balls and the pockets of the billard table
		private function checkPockets(ball:Ball):void
		{
			for(var i:int = 0; i < numPockets; i++)
			{
				//Calculate the distance between the pocket and the ball
				var distanceX:Number = Ball(pockets[i]).x - ball.x;
				var distanceY:Number = Ball(pockets[i]).y - ball.y;
				var distance:Number = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
				var minDistance:Number = Ball(pockets[i]).radius + ball.radius;
				//Remove the ball from the stage if they are colliding
				if(distance < minDistance)
				{
					if(ball != Ball(balls[0]))
					{
						//trace("hit");
						//Remove that ball from the array
						balls.splice(balls.indexOf(ball), 1);
						removeChild(ball);
						//Update the number of balls
						numBalls--;
					}
					pocketCollision = true;
					
				}
			}
		}
				
		//Check collisions between the balls and the walls of the billard table
        private function checkWalls(ball:Ball):void
        {
			
            if(ball.x + ball.radius > outerBorder.getBounds(outerBorder).right - BORDER_WIDTH)
            {
                ball.x = outerBorder.getBounds(outerBorder).right - BORDER_WIDTH - ball.radius;
                ball.vx *= bounce;
				collision = true;
				ball.vx *= friction;
				
            }
            else if(ball.x - ball.radius < outerBorder.getBounds(outerBorder).left + BORDER_WIDTH)
            {
                ball.x = ball.radius + BORDER_WIDTH;
                ball.vx *= bounce;
				collision = true;
				ball.vx *= friction;
				
            }
            if(ball.y + ball.radius > outerBorder.getBounds(outerBorder).bottom - BORDER_WIDTH)
            {
                ball.y = outerBorder.getBounds(outerBorder).bottom - BORDER_WIDTH - ball.radius;
                ball.vy *= bounce;
				collision = true;
				ball.vy *= friction;
				
            }
            else if(ball.y - ball.radius < outerBorder.getBounds(outerBorder).top + BORDER_WIDTH)
            {
                ball.y = ball.radius + BORDER_WIDTH;
                ball.vy *= bounce;
				collision = true;
				ball.vy *= friction;
				
            }
        }

        private function checkCollision(ball0:Ball, ball1:Ball):void
        {
            var dx:Number = ball1.x - ball0.x;
            var dy:Number = ball1.y - ball0.y;
            var dist:Number = Math.sqrt(dx*dx + dy*dy);
            if(dist < ball0.radius + ball1.radius)
            {
                // calculate angle, sine, and cosine
                var angle:Number = Math.atan2(dy, dx);
                var sin:Number = Math.sin(angle);
                var cos:Number = Math.cos(angle);

                // rotate ball0's position
                var pos0:Point = new Point(0, 0);

                // rotate ball1's position
                var pos1:Point = rotate(dx, dy, sin, cos, true);

                // rotate ball0's velocity
                var vel0:Point = rotate(ball0.vx,
                                        ball0.vy,
                                        sin,
                                        cos,
                                        true);

                // rotate ball1's velocity
                var vel1:Point = rotate(ball1.vx,
                                        ball1.vy,
                                        sin,
                                        cos,
                                        true);

                // collision reaction
                var vxTotal:Number = vel0.x - vel1.x;
                vel0.x = ((ball0.mass - ball1.mass) * vel0.x +
                          2 * ball1.mass * vel1.x) /
                          (ball0.mass + ball1.mass);
                vel1.x = vxTotal + vel0.x;

                // update position
				var absV:Number = Math.abs(vel0.x) + Math.abs(vel1.x);
				var overlap:Number = (ball0.radius + ball1.radius)
									  - Math.abs(pos0.x - pos1.x);
				pos0.x += vel0.x / absV * overlap;
				pos1.x += vel1.x / absV * overlap;

                // rotate positions back
                var pos0F:Object = rotate(pos0.x,
                                          pos0.y,
                                          sin,
                                          cos,
                                          false);

                var pos1F:Object = rotate(pos1.x,
                                          pos1.y,
                                          sin,
                                          cos,
                                          false);

                // adjust positions to actual screen positions
                ball1.x = ball0.x + pos1F.x;
                ball1.y = ball0.y + pos1F.y;
                ball0.x = ball0.x + pos0F.x;
                ball0.y = ball0.y + pos0F.y;

                // rotate velocities back
                var vel0F:Object = rotate(vel0.x,
                                          vel0.y,
                                          sin,
                                          cos,
                                          false);
                var vel1F:Object = rotate(vel1.x,
                                          vel1.y,
                                          sin,
                                          cos,
                                          false);
                ball0.vx = vel0F.x;
                ball0.vy = vel0F.y;
                ball1.vx = vel1F.x;
                ball1.vy = vel1F.y;
            }
        }

        private function rotate(x:Number,
                                y:Number,
                                sin:Number,
                                cos:Number,
                                reverse:Boolean):Point
        {
            var result:Point = new Point();
            if(reverse)
            {
                result.x =x*cos+y* sin;
                result.y =y*cos-x* sin;
            }
            else
            {
                result.x =x*cos-y* sin;
                result.y =y*cos+x* sin;
            }
			collision = true;
            return result;
        }
    }
}