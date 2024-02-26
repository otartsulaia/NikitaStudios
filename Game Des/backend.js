let playerelement;
let groundelement;
let groundRect;
let enemyElement; // Reference to the enemy element
let enemy; // Object to store enemy properties
let requestId;


function startgame(){
    console.log("Start Activated");

    playerelement = document.querySelector('.main');
    groundelement = document.querySelector('.ground');
    groundRect = groundelement.getBoundingClientRect();

    

    player = {
        x: parseInt(playerelement.style.left, 10) || 0,
        y: parseInt(playerelement.style.top, 10) || 0,
        width: playerelement.offsetWidth,
        height: playerelement.offsetHeight,
        vy: 0,
        gravity: 1,
        jumpstrength: -20,
        vx:0,
        friction: 1,
        leapstrength:20,

        leapleft: false,
        leftright: false, 
        leaping: false,
        onGround: true,
    }

    ground = {
        x: groundRect.left,
        y: groundRect.top,
    }
    checkKeyPress();

    
    enemyElement = document.querySelector('.enemy'); // Initialize enemy element
    
    enemy = {
        x: parseInt(enemyElement.style.left, 10) || 200,
        y: parseInt(enemyElement.style.bottom, 10) || 150,
        vx: 2, // Speed at which the enemy moves towards the player
    };
    requestId = requestAnimationFrame(updategame);

}
function updategame() {
    updateplayer();
    updateEnemy();
    checkCollision();
    requestId = requestAnimationFrame(updategame);
}
function updateplayer(){

    if(!player.onGround){
        player.vy+=player.gravity;
        player.y+=player.vy;

        if(player.y>=ground.y-player.height){
            player.y = ground.y - player.height;
            player.onGround = true;
            player.vy=0;
    
        }

        playerelement.style.top = player.y + 'px';
    }
    if(player.leaping){
        console.log("player leaping");
        if(player.vx == 0){
            player.leaping = false;
        }   
        else if (player.vx<0){

            player.vx+=player.friction;

        }
        else if (player.vx>0){
            player.vx-=player.friction;

        }

        player.x+=player.vx;
        console.log("after application"+player.vx);


    }
    playerelement.style.left = player.x + 'px';
}

function jump(){
    if(player.onGround){
        player.vy = player.jumpstrength;
        player.onGround = false;
    }
}


function updateEnemy() {
    // Calculate direction towards the player
    let direction = player.x - enemy.x;
    direction = direction / Math.abs(direction); // Normalize direction to either -1 or 1

    // Move enemy towards player
    enemy.x += direction * enemy.vx;
    enemyElement.style.left = enemy.x + 'px';
}


function horizpress(){
    if(player.leapleft){
        player.vx=-(player.leapstrength);
        player.leapleft=false;
    }
    else if(player.leapright){
        player.vx=player.leapstrength;
        player.leapright=false;
    }
    player.leaping=true; //holds when vx is greater than 0

}

function checkKeyPress(){
    document.addEventListener('keydown', function(event) {
        switch (event.key) {
            case 'ArrowLeft': // Move left
                player.leapleft=true;
                horizpress();
                break;
            case 'ArrowRight': // Move right
                player.leapright=true;
                horizpress();
                break;
            case 'ArrowUp':
                console.log("arrowkey pressed");
                jump();
                break;
        }
        playerelement.style.left = player.x + 'px';
    });

}

function checkCollision() {
    console.log(`Player - x: ${player.x}, y: ${player.y}, width: ${player.width}, height: ${player.height}`);
    console.log(`Enemy - x: ${enemy.x}, y: ${enemy.y}`);
    
    if (Math.abs(player.x + player.width) >=  enemy.x && player.x < player.width) {
        console.log("Collision Detected!");
        alert("Game Over!"); // Display message
        window.cancelAnimationFrame(requestId); // Stop the game loop
    }
}