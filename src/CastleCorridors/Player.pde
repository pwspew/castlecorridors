// Player.pde — revised (handles GIF play/pause when standing still)
class Player {
  float x, y;
  int size = 10;
  float speed = 3.2;
  int maxHealth = 100;
  int health = maxHealth;
  int score = 0;
  boolean left, right, up, down;
  int attackCooldown = 0;
  int damage = 10;
  float basespeed = 3.2;

  // GIFs
  Gif servingL, servingR;
  Gif serving;     // the main one , all other gifs will be funneled into this one
  Gif idleLeft, idleRight;
  String leftguy  = "ServantLeftWalking.gif";
  String rightguy = "ServantRightWalking.gif";

  // movement detection
  float prevX, prevY;
  float moveThreshold = 0.4; // small dead zone to avoid flickering (i hate flickering)
  boolean facingLeft = false;

  Player(PApplet parent, float x_, float y_) {
    x = x_;
    y = y_;


    servingL = new Gif(parent, leftguy);
    servingR = new Gif(parent, rightguy);
    idleLeft = new Gif(parent, "ServantL.gif");
    idleRight = new Gif(parent, "ServantR.gif");

    servingL.loop();
    servingR.loop();

    // default to right-facing sprite but pause it (idle)
    serving = idleLeft;
    serving.pause();

    // init previous position for movement detection
    prevX = x;
    prevY = y;
  }

  void reset(float nx, float ny) {
    x = nx;
    y = ny;
    health = maxHealth;
    score = 0;
    left = right = up = down = false;
    // reset animation state
    serving = idleLeft;
    serving.pause();
    prevX = x;
    prevY = y;
  }

  void update() {
    // compute input direction
    float dx = 0;
    float dy = 0;

    if (left) {
      dx -= 1;
    }
    if (right) {
      dx += 1;
    }
    if (up) {
      dy -= 1;
    }
    if (down) {
      dy += 1;
    }

    // movement magnitude
    boolean isMoving = (abs(dx) > 0 || abs(dy) > 0);


    if (dx < 0) facingLeft = true;
    else if (dx > 0) facingLeft = false;


    Gif want = facingLeft ? servingL : servingR;

    // if moving: normalize and try to move; also ensure walking animation plays
    if (isMoving) {
      // pick chosen sprite, play it, pause the other
      if (serving != want) {
        // switch to the correct sprite reference
        serving.pause();    // pause previously shown (keeps its current frame)
        serving = want;
      }
      serving.play(); // ensure the chosen sprite is playing

      // movement physics (normalize so diagonal not faster)
      float len = dist(0, 0, dx, dy);
      dx /= len;
      dy /= len;
      float nx = x + dx * speed;
      float ny = y + dy * speed;

      // collision with dungeon tiles — try full move, otherwise axis sliding
      if (!collidesWithMap(nx, ny, size)) {
        x = nx;
        y = ny;
      } else {
        if (!collidesWithMap(nx, y, size)) {
          x = nx;
        } else if (!collidesWithMap(x, ny, size)) {
          y = ny;
        }
      }
    } else {
      serving = idleRight;
      serving.pause();
      // optionally pause the other as well (not required but keeps both in same state)
      if (serving == servingL) {
        servingR.pause();
      } else {
        servingL.pause();
      }
    }

    // update current room index after movement
    int idx = getRoomIndexAt(x, y);
    if (idx != -1 && idx != currentRoomIndex) {
      currentRoomIndex = idx;
      println("Entered room " + currentRoomIndex);
    }

    // keep inside world bounds (adjust if you want camera padding)
    x = constrain(x, size/2, width - size/2);
    y = constrain(y, size/2, height - size/2);

    // cooldown
    if (attackCooldown > 0) attackCooldown--;

    // save prev pos (optional — used if you want velocity-based checks later)
    prevX = x;
    prevY = y;
  }

  void display() {
    noStroke();
    fill(80, 200, 250);

    // draw GIF centered on (x,y)
    imageMode(CENTER);
    image(serving, x, y, size*4, size*4);
    imageMode(CORNER);

    if (attackCooldown > 0 && attackCooldown > 18) {
      fill(255, 150, 0, 80);
      ellipse(x, y, 80, 80);
    }
  }

  void displayHUD() {
    fill(255);
    textSize(32);

    text("pH level: " + health, 110, 28);
    text("Points recieved: " + score, 135, 58);
    text(survivalCounter/60, width/2, 58);
  }

  void attack() {
    if (attackCooldown == 0) {
      attackCooldown = 25;
      float range = 40;
      for (int i = enemies.size()-1; i >= 0; i--) {
        Enemy e = enemies.get(i);
        if (dist(x, y, e.x, e.y) < range + e.size/2 && e.health <= damage) {
          e.isDead = true;
          score += 10;
        } else if (e.health > damage && dist(x, y, e.x, e.y) < range + e.size/2) {
          e.knockbackFrom(x, y, 6);
          e.health -= damage;
        }
      }
      if (dist(x, y, king.x, king.y) < range + king.size/2) {
        king.knockbackFrom(x, y, 6);
      }
    }
  }

  void takeDamage(int n) {
    health -= n;
    float ang = atan2(y - king.y, x - king.x);
    x += cos(ang) * 6;
    y += sin(ang) * 6;
    // ensure not stuck in wall
    if (collidesWithMap(x, y, size)) {
      x = constrain(x, tileSize*1.5, width - tileSize*1.5);
      y = constrain(y, tileSize*1.5, height - tileSize*1.5);
    }
  }
}
