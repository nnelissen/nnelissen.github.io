var canvas;
var canvasContext;
    
var startTime;
var currentTime;
    
var totalScore = 0;
var planetLife = 10;
var asteroidsGone = 0;
    
var radiusPlanet = 50;
var radiusAsteroid = 10;
var radiusBullsEye = 10;
    
var checkOnsets = [];
    
var output = [];
    
var asteroidsX = [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10];
var asteroidsY = [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10];    
var asteroidsAngle = [Math.random(),Math.random(),Math.random(),Math.random(),Math.random(),Math.random(),Math.random(),Math.random(),Math.random(),Math.random()];
var asteroidsSpeed = [Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10,Math.random()*10];    
var asteroidNr = asteroidsX.length;
var asteroidOnset = [500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000]; // ms
 
var asteroids = [];
var asteroidState = [];   
// create 10 asteroids
for(var i = 0; i < asteroidNr; i++) {
    asteroids.push(new asteroidClass(asteroidsX[i], asteroidsY[i], asteroidsAngle[i], asteroidsSpeed[i]));
    //var asteroid1 = new asteroidClass(200,0,1,5);
    asteroidState.push(0);   
    checkOnsets.push(0);
} 

// asteroid class
function asteroidClass(x,y,ang,speed) {
    this.x = x;
    this.y = y;
    this.ang = ang;
    this.speed = speed;
    this.size = 10;
    //this.pic = asteroidPic;
    
    this.move = function() {
        this.x += Math.cos(this.ang) * this.speed;
        this.y += Math.sin(this.ang) * this.speed;
    }
    
    this.draw = function() {
        if (this.x < canvas.width && this.y < canvas.height) {
            colorCircle(this.x,this.y,radiusAsteroid,'red');
            drawBitmapCenteredWithRotation(asteroidPic, this.x,this.y, 0);
            return true;
        }
    }
    
    this.collision = function() {
        var r1 = radiusPlanet;
        var r2 = radiusAsteroid;
        var a = r1 + r2;
        var x = canvas.width/2 - this.x;
        var y = canvas.height/2 - this.y;
        if ( a > Math.sqrt( (x*x) + (y*y) ) ) {
            //console.log('collision');
            planetLife--;
            asteroidsGone++;
            return true;
        }
    }
    
    this.explosion = function(bullseyeX,bullseyeY) {
        var r1 = radiusBullsEye;
        var r2 = radiusAsteroid;
        var a = r1 + r2;
        var x = bullseyeX - this.x;
        var y = bullseyeY - this.y;
        if ( a > Math.sqrt( (x*x) + (y*y) ) ) {
            //console.log('explosion'); 
            totalScore++;
            asteroidsGone++;
            return true;
        }
    }
    
}
    

function calculateMousePos(evt) {
    var rect = canvas.getBoundingClientRect();
    var root = document.documentElement;
    var mouseX = evt.clientX - rect.left - root.scrollLeft;
    var mouseY = evt.clientY - rect.top - root.scrollTop;
    return{
        x:mouseX,
        y:mouseY
    };
    
}
    

window.onload = function() {
    canvas = document.getElementById("gameCanvas");
    canvasContext = canvas.getContext("2d");
    canvasContext.fillStyle = "black";
    canvasContext.fillRect(0,0,canvas.width,canvas.height);
    
    var d = new Date();
    startTime = d.getTime();
    
    loadImages();
      
    // use requestAnimationFrame(draw); instead?
    // see http://creativejs.com/resources/requestanimationframe/
    
    canvas.addEventListener('mousedown',
        function(evt) {
            var mousePos = calculateMousePos(evt);
            updateAsteroidExplosion(mousePos.x,mousePos.y);
        }
    );
    
}

function imageLoadingDoneSoStartGame() {
    var framesPerSecond = 30;
    setInterval(function() {
        checkAsteroidStatus();
        updateAsteroidPosition();
        drawEverything();
    }, 1000/framesPerSecond);
}

function checkAsteroidStatus() {
    var d = new Date();
    currentTime = d.getTime() - startTime;
    if (asteroidsGone == asteroidNr) {
        // game finished
        //console.log('game over');
    } else {   
        for(var i = 0; i < asteroids.length; i++) {
            if (asteroidState[i] == 0) { // not yet activated
                // check if it's time to activate
                if (asteroidOnset[i] <= currentTime) {
                    asteroidState[i] = 1; // activate
                    checkOnsets[i] = currentTime;
                    //console.log(currentTime);
                    //console.log('activated');
                    //console.log(asteroidState);
                }
            }
        }
    }
}
    

function updateAsteroidExplosion(x,y) {
    for(var i = 0; i < asteroids.length; i++) {
        if (asteroidState[i] == 1) {
            if (asteroids[i].explosion(x,y)) {
                var d = new Date();
                currentTime = d.getTime() - startTime;
                asteroidState[i] = 3;
                        
                output.push({
                    "asteroidId":i, 
                    "onsetTime":checkOnsets[i], 
                    "status":3, 
                    "mouseX":x, 
                    "mouseY":y, 
                    "offsetTime":currentTime
                });
                        
                //console.log(output);
            }
        }
    }
}
  
function updateAsteroidPosition() {
    for(var i = 0; i < asteroids.length; i++) {
        if (asteroidState[i] == 1) {
            asteroids[i].move();
            if (asteroids[i].collision()) {
                var d = new Date();
                currentTime = d.getTime() - startTime;
                asteroidState[i] = 2;
                
                output.push({
                    "asteroidId":i, 
                    "onsetTime":checkOnsets[i], 
                    "status":2, 
                    "mouseX":-10, 
                    "mouseY":-10, 
                    "offsetTime":currentTime
                });
                    
                //console.log(asteroidState);
            }        
        }
    }
}

function drawEverything() {
    // clear canvas
    canvasContext.clearRect(0, 0, canvas.width, canvas.height);
    
    // black background
    colorRect(0,0,canvas.width,canvas.height,'black');
    
    // planet
    colorCircle(canvas.width/2,canvas.height/2,radiusPlanet,'white');
    drawBitmapCenteredWithRotation(planetPic, canvas.width/2,canvas.height/2, 0);
    
    // asteroids
    for(var i = 0; i < asteroids.length; i++) {
        if (asteroidState[i] == 1) {
            if (!asteroids[i].draw()) {
                var d = new Date();
                currentTime = d.getTime() - startTime;
                asteroidState[i] = 4; // disappeared off screen
                asteroidsGone++;
            
                output.push({
                    "asteroidId":i, 
                    "onsetTime":checkOnsets[i], 
                    "status":4, 
                    "mouseX":-10, 
                    "mouseY":-10, 
                    "offsetTime":currentTime
                });

            }
        }
    }
    canvasContext.fillText(planetLife,canvas.width/2,canvas.height/2);
}

    
    
    
    
    
    
    
// functions to draw objects
    
function colorRect(leftX,topY,width,height,drawColor) {
    canvasContext.fillStyle = drawColor;
    canvasContext.fillRect(leftX,topY,width,height);
}
    
function colorCircle(centerX,centerY,radius,drawColor) {
    canvasContext.beginPath();
    canvasContext.arc(centerX, centerY, radius, 0, 2 * Math.PI, true);
    canvasContext.fillStyle = drawColor;
    canvasContext.fill();
    //canvasContext.lineWidth = 5;
    //canvasContext.strokeStyle = '#003300';
    //canvasContext.stroke();
}

function drawBitmapCenteredWithRotation (useBitmap, atX,atY, withAng) {
    canvasContext.save();
    canvasContext.translate(atX,atY);
    canvasContext.rotate(withAng);
    canvasContext.drawImage(useBitmap,-useBitmap.width/2,-useBitmap.height/2);
    canvasContext.restore();
}
    
    
// image loading code
var asteroidPic = document.createElement("img");
var planetPic = document.createElement("img");

var picsToLoad = 0;

function countLoadedImagesAndLaunchIfReady() {
    picsToLoad--;
    if(picsToLoad == 0){
        imageLoadingDoneSoStartGame();
    }
}

function beginLoadingImage(imgVar,fileName) {
    imgVar.onload = countLoadedImagesAndLaunchIfReady;
    imgVar.src = "img/"+fileName;    
}

function loadImages() {
    var imageList = [
        {varName: asteroidPic, theFile: "Asteroid.png"},
        {varName: planetPic, theFile: "Earth.png"},
    ];
    
    picsToLoad = imageList.length;
    
    for(var i=0; i<imageList.length; i++) {
        beginLoadingImage(imageList[i].varName,imageList[i].theFile); 
    }
}