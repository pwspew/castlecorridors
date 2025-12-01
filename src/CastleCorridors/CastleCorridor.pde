// Ollie G , Ellie Jacobsen , Ethan Shafran, Madeline Hendrickson
// power of friendship!!!! 
// the date right now is Nov 24
float camX = 0, camY = 0;        
int currentRoomIndex = -1;      //room finder
boolean roomClampMode = true;   //false makes it not follow no more
float cameraPadding = 100;       
PImage kingstart;

//the grid
int tileSize = 10;
int cols, rows;
boolean[][] walkable; // true = floor false = wall

int titlescreen = 0;
int playscreen  = 1;
int youdied  = 2;
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
int spawnInterval = 180; // frames x 3

void setup() {
  fullScreen();
  rectMode(CORNER);
  textAlign(CENTER, CENTER);
  cols = width / tileSize;
  rows = height / tileSize;
  walkable = new boolean[cols][rows];
  kingstart = loadImage("king.png");

  player = new Player(width/2, height/2);
  king = new King(60, 60);
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
  }
}

void updateCamera() {
  if (roomClampMode && currentRoomIndex >= 0 && currentRoomIndex < rooms.size()) {
    Room r = rooms.get(currentRoomIndex);
    float roomLeft = r.x * tileSize;
    float roomTop  = r.y * tileSize;
    float roomRight = roomLeft + r.w * tileSize;
    float roomBottom = roomTop + r.h * tileSize;

    // center camera on player but clamp to room (with optional padding)
    float targetCamX = player.x - width/2.0;
    float targetCamY = player.y - height/2.0;
    float minCamX = roomLeft - cameraPadding;
    float minCamY = roomTop - cameraPadding;
    float maxCamX = roomRight - width + cameraPadding;
    float maxCamY = roomBottom - height + cameraPadding;

    // if room is smaller than screen, center the camera on the room
    if (minCamX > maxCamX) {
      minCamX = (roomLeft + roomRight)/2 - width/2;
      maxCamX = minCamX;
    }
    if (minCamY > maxCamY) {
      minCamY = (roomTop + roomBottom)/2 - height/2;
      maxCamY = minCamY;
    }

    camX = constrain(targetCamX, minCamX, maxCamX);
    camY = constrain(targetCamY, minCamY, maxCamY);
  } else {
    // free camera centered on player but within full map bounds
    float mapW = cols * tileSize;
    float mapH = rows * tileSize;
    camX = constrain(player.x - width/2.0, 0, max(0, mapW - width));
    camY = constrain(player.y - height/2.0, 0, max(0, mapH - height));
  }
}


void titleScreen() {
  fill(255);
  imageMode(CENTER);
  image(kingstart, width/2, height/2 - 300, 420, 420);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("ESCALATION7", width/2, height/2 - 80);
  textSize(18);
  text("its either be in this dungeon or get attacked by 10,000 bees", width/2, height/2 - 30);
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
  text("(theres not really a way to win yet though)", width/2, height/2 - 10);
  textSize(20);
  text("Score: " + player.score + "    Health: " + player.health, width/2, height/2+30);
  restartBtn.display();
}

void runGame() {
  // update
  player.update();         
  updateCamera();           
  //king.updateTowards(player.x, player.y);

  for (int i = enemies.size()-1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    if (e.isDead) {
      enemies.remove(i);
      continue;
    }
    if (dist(e.x, e.y, player.x, player.y) < (e.size/2 + player.size/2)) {
      player.takeDamage(1);
    }
  }

  for (int i = items.size()-1; i >= 0; i--) {
    Item it = items.get(i);
    if (dist(it.x, it.y, player.x, player.y) < (it.size/2 + player.size/2)) {
      player.score += it.value;
      player.health = min(player.maxHealth, player.health + 10);
      items.remove(i);
    }
  }

  // spawn stuff
  spawnTimer++;
  if (spawnTimer > spawnInterval) {
    spawnTimer = 0;
    if (rooms.size() > 0 && random(1) < 0.7) {
      Room r = rooms.get(int(random(rooms.size())));
      PVector p = r.randomPoint();
      enemies.add(new Enemy(p.x, p.y));
    }
    if (rooms.size() > 0 && random(1) < 0.4) {
      Room r = rooms.get(int(random(rooms.size())));
      PVector p = r.randomPoint();
      items.add(new Item(p.x, p.y));
    }
  }

  // draw world using camera
  pushMatrix();
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
    if (key == 'a' || key == 'A') player.left = true;
    if (key == 'd' || key == 'D') player.right = true;
    if (key == 'w' || key == 'W') player.up = true;
    if (key == 's' || key == 'S') player.down = true;
    if (key == ' ') player.attack();
  } else if (state == titlescreen) {
    if (keyCode == ENTER || keyCode == RETURN) startGame();
  } else if (state == youdied) {
    if (keyCode == ENTER || keyCode == RETURN) resetGame();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A') player.left = false;
  if (key == 'd' || key == 'D') player.right = false;
  if (key == 'w' || key == 'W') player.up = false;
  if (key == 's' || key == 'S') player.down = false;
}

void mousePressed() {
  if (state == titlescreen) {
    if (startBtn.clicked()) startGame();
  } else if (state == youdied) {
    if (restartBtn.clicked()) resetGame();
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
}

void resetGame() {
  startGame();
}


