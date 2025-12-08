// Ollie G , Ellie Jacobsen , Ethan Shafran, Madeline Hendrickson
// power of friendship!!!!
// the date right now is Nov 24
import gifAnimation.*;
float camX = 0, camY = 0;
int currentRoomIndex = -1;      //room finder
boolean roomClampMode = false;   //false makes it not follow no more
float cameraPadding = 200;
PImage kingstart;
float zoom = 4;
PFont everytext;
//the grid
int tileSize = 10;
int cols, rows;
boolean[][] walkable; // true = floor false = wall

int titlescreen = 0;
int playscreen  = 1;
int youdied  = 2;
int youwin = 3;
int state = titlescreen;

// player
Player player;

// king (hes evil)
King king;

// enemies and items
ArrayList<Enemy> enemies;
ArrayList<Item> items;

// bsp (thanks rogue for figuring it tree)
ArrayList<Room> rooms;

// button and spawns
Button startBtn, restartBtn, settingsBtn, menuBtn;
int spawnTimer = 0;
int spawnInterval = 50; // frames x 3
int itemTimer;
int survivalTimer = 60 * 60;
int survivalCounter = 0;


void setup() {
  fullScreen();
  rectMode(CORNER);
  textAlign(CENTER, CENTER);
  cols = width / tileSize;
  rows = height / tileSize;
  walkable = new boolean[cols][rows];
  kingstart = loadImage("king.png");
  everytext = createFont("AlteHaasGroteskBold.ttf", 32);
  Gif bee = new Gif(this, "bee1left.gif");
  bee.play();
  textFont(everytext, 50);
  player = new Player(this, width/2, height/2);
  king = new King(this, 60, 60);
  enemies = new ArrayList<Enemy>();
  items = new ArrayList<Item>();
  rooms = new ArrayList<Room>();

  startBtn = new Button("start", width/2 - 120, height/2 + 60, 240, 50);
  restartBtn = new Button("run it once more", width/2 - 120, height/2 + 80, 240, 50);
  frameRate(60);

  // generates before anything very important
  generateDungeon();
}

int getRoomIndexAt(float px, float py) {
  float pad = tileSize * 0.9;
  for (int i = 0; i < rooms.size(); i++) {
    Room r = rooms.get(i);
    float rx = r.x * tileSize;
    float ry = r.y * tileSize;
    float rw = r.w * tileSize;
    float rh = r.h * tileSize;
    if (px >= rx - pad && px < rx + rw + pad && py >= ry - pad && py < ry + rh + pad) return i;
  }
  return -1;
}

boolean collidesWithMap(float cx, float cy, float sizePX) {
  float left = cx - sizePX/2;
  float top = cy - sizePX/2;
  float right = cx + sizePX/2;
  float bottom = cy + sizePX/2;
  int x0 = floor(left / tileSize);
  int y0 = floor(top / tileSize);
  int x1 = floor(right / tileSize);
  int y1 = floor(bottom / tileSize);
  for (int i = x0; i <= x1; i++) {
    for (int j = y0; j <= y1; j++) {
      if (i < 0 || i >= cols || j < 0 || j >= rows) return true;
      if (!walkable[i][j]) return true;
    }
  }
  return false;
}

void draw() {
  background(0, 10, 0);
  if (state == titlescreen) {
    titleScreen();
  } else if (state == playscreen) {
    runGame();
  } else if (state == youdied) {
    deathScreen();
  } else if (state == youwin) {
    youwinScreen();
  }
}

void updateCamera() {
  // compute the zoom-aware viewport size
  float viewW = width  / zoom;
  float viewH = height / zoom;

  if (roomClampMode && currentRoomIndex >= 0 && currentRoomIndex < rooms.size()) {
    Room r = rooms.get(currentRoomIndex);
    float roomLeft   = r.x * tileSize;
    float roomTop    = r.y * tileSize;
    float roomRight  = roomLeft + r.w * tileSize;
    float roomBottom = roomTop  + r.h * tileSize;

    // center camera on player but clamp to room (with optional padding)
    float targetCamX = player.x - viewW/2;
    float targetCamY = player.y - viewH/2;

    float minCamX = roomLeft - cameraPadding;
    float minCamY = roomTop  - cameraPadding;
    float maxCamX = roomRight  - viewW + cameraPadding;
    float maxCamY = roomBottom - viewH + cameraPadding;

    if (minCamX > maxCamX) {
      minCamX = (roomLeft + roomRight)/2 - viewW/2;
      maxCamX = minCamX;
    }
    if (minCamY > maxCamY) {
      minCamY = (roomTop + roomBottom)/2 - viewH/2;
      maxCamY = minCamY;
    }

    camX = constrain(targetCamX, minCamX, maxCamX);
    camY = constrain(targetCamY, minCamY, maxCamY);
  } else {
    float mapW = cols * tileSize;
    float mapH = rows * tileSize;
    camX = constrain(player.x - viewW/2, 0, max(0, mapW - viewW));
    camY = constrain(player.y - viewH/2, 0, max(0, mapH - viewH));
  }
}


void titleScreen() {
  fill(255);
  imageMode(CENTER);
  image(kingstart, width/2, height/2 - 300, 420, 420);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("Castle Corridors", width/2, height/2 - 80);
  textSize(18);
  text("its either be in this dungeon or get attacked by 10,000 bees", width/2, height/2 - 30);
  textSize(22);
    text("survive for 60 seconds !!!!!!! ", width/2, height/2 + 10);
  dungeonPreview();
  startBtn.display();
}
// ethan made this screen
void deathScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  text("you lost", width/2, height/2 - 40);
  textSize(20);

  textSize(20);
  text("Score: " + player.score + "    Health: " + player.health, width/2, height/2+30);
  restartBtn.display();
}

void youwinScreen() {
  fill(60, 120, 120);
  textAlign(CENTER, CENTER);
  textSize(48);
  text("you win!!!!", width/2, height/2 - 40);
  textSize(20);

  textSize(20);
  text("Score: " + player.score + "    Health: " + player.health, width/2, height/2+30);
  restartBtn.display();
}

void itemEffect(Item it) {
  if (it.itype == 0) {
    player.health += 20;
    fill(100);
  } else if (it.itype == 1) {
    player.speed *= 1.2;
    itemTimer = 300;
    if (itemTimer <= 0) {
      player.speed = player.basespeed;
    }
  } else if (it.itype == 2) {
    //player.damage += 10;
  }
}
void runGame() {
  // update




  player.update();
  updateCamera();
  //king.updateTowards(player.x, player.y);

  for (int i = enemies.size()-1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    e.typeSpawn();
    if (e.isDead) {
      enemies.remove(i);
      continue;
    }
    if (enemies.size() >10) {
      enemies.remove(1);
    }
    if (dist(e.x, e.y, player.x, player.y) < (e.size/2 + player.size/2)) {
      player.takeDamage(1);
    }
  }
  for (int i = items.size()-1; i >= 0; i--) {
    Item it = items.get(i);


    if (dist(it.x, it.y, player.x, player.y) < (it.size/2 + player.size/2)) {

      itemEffect(it);

      items.remove(i);
    }
    if (itemTimer < 5000 && dist(it.x, it.y, player.x, player.y) < (it.size/2 + player.size/2)) {
      itemEffect(it);
    }
  }
  itemTimer --;
  if (itemTimer <= 0) {
    player.speed = player.basespeed;
  }
  spawnTimer++;
  if (spawnTimer > spawnInterval) {
    spawnTimer = 0;
    if (rooms.size() > 0 && random(1) < 0.7) {
      Room r = rooms.get(int(random(rooms.size())));
      PVector p = r.randomPoint();
      enemies.add(new Enemy(this, p.x, p.y));
    }
    if (rooms.size() > 0 && random(1) < 0.4) {
      Room r = rooms.get(int(random(rooms.size())));
      PVector p = r.randomPoint();
      items.add(new Item(this, p.x, p.y));
    }
  }


  //// draw world using camera
  pushMatrix();
  scale(zoom);
  translate(-camX, -camY);

  // draw dungeon (walls)
  drawDungeon();

  // draw stuff in world coordinates
  for (Enemy e : enemies) e.display();
  for (Item it : items) it.display();
  king.display();
  player.display();

  popMatrix();

  //
  player.displayHUD();

  if (state==playscreen) {
    survivalCounter++;

    if (survivalCounter >= survivalTimer) {
      state = youwin;
    }
  }
  //
  if (dist(king.x, king.y, player.x, player.y) < king.size/2 + player.size/2) {
    state = youdied;
  }
  if (player.health <= 0) {
    state = youdied;
  }
}


// input
void keyPressed() {
  if (state == playscreen) {
    if (key == 'a' || key == 'A') {
      player.left = true;
    }
    if (key == 'd' || key == 'D') {
      player.right = true;
    }
    if (key == 'w' || key == 'W') {
      player.up = true;
    }
    if (key == 's' || key == 'S') {
      player.down = true;
    }
    if (key == ' ') {
      player.attack();
    }
  } else if (state == titlescreen) {
    if (keyCode == ENTER || keyCode == RETURN) startGame();
  } else if (state == youdied) {
    if (keyCode == ENTER || keyCode == RETURN) resetGame();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') {
    player.left = false;
  }
  if (key == 'd' || key == 'D') {
    player.right = false;
  }
  if (key == 'w' || key == 'W') {
    player.up = false;
  }
  if (key == 's' || key == 'S') {
    player.down = false;
  }
}

void mousePressed() {
  if (state == titlescreen) {
    if (startBtn.clicked()) {
      startGame();
    }
  } else if (state == youdied || state == youwin) {
    if (restartBtn.clicked()) {
    
      resetGame();
     
      
    }

    
  }
}

void startGame() {
  state = playscreen;
  generateDungeon(); // generate fresh dungeon each run
  // place player in first room's center
  if (rooms.size() > 0) {
    PVector start = rooms.get(0).center();
    player.reset(start.x, start.y);
    king.setPos(rooms.get(max(0, rooms.size()-1)).center().x, rooms.get(max(0, rooms.size()-1)).center().y); // king in last room
  } else {
    player.reset(width/2, height/2);
    updateCamera();
    king.setPos(60, 60);
  }
  currentRoomIndex = getRoomIndexAt(player.x, player.y);
  if (currentRoomIndex == -1 && rooms.size() > 0) currentRoomIndex = 0;
  enemies.clear();
  items.clear();
  spawnTimer = 0;
  itemTimer = 0;
  survivalCounter = 0;
}

void resetGame() {
  startGame();
}
