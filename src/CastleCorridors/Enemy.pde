// ethan and ollie partook in this class 
// duo
// noble and apostle 
// except apostle's very short
// and noble is not as chunky
class Enemy {
  float x, y;
  float size;
  float speed;
  boolean isDead = false;
  int health;
  int maxHealth;

  float tx, ty;            // wander target
  float prevX = 0;         // previous x for direction detection

  int damage;              // melee damage
  float sightRange;        // how far they notice player
  float attackRange;       // distance to attack
  int changeTimer = 0;
  int attackCooldown;
  int attackDelay;

  int etype;               // 0..3 variant

  // GIFs
  Gif beeLeft, beeRight;
  Gif bee;                 // current gif reference

  
  String leftFile  = "bee1left.gif";
  String rightFile = "bee1right.gif";

  Enemy(PApplet parent, float sx, float sy) {
    x = sx;
    y = sy;

    // pick a type 0..3 inclusive
    etype = int(random(0, 4));


    typeSpawn();


    pickTarget();

    prevX = x;

    beeLeft  = new Gif(parent, leftFile);
    beeRight = new Gif(parent, rightFile);
    beeLeft.loop();
    beeRight.loop();

    // default facing right
    bee = beeRight;
  }

  void typeSpawn() {
    // defaults
    size = 14;
    speed = 1.2;
    maxHealth = 20;
    damage = 6;
    sightRange = 160;
    attackRange = 18;
    attackDelay = 40;

    if (etype == 0) {         // basic
      size = 20; speed = 1.2; maxHealth = 20; sightRange = 140; attackRange = 18;
    } else if (etype == 1) {  // bigger
      size = 30; speed = 0.8;  maxHealth = 40; sightRange = 120; attackRange = 20;
    } else if (etype == 2) {  // faster
      size = 16; speed = 2.4;  maxHealth = 12; sightRange = 100; attackRange = 10;
    } else if (etype == 3) {  // thy boss !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    // foul tarnished, emboldened by the flame of ambition
      size = 60; speed = 0.5;  maxHealth = 200; sightRange = 200; attackRange = 60;
    }
    health = maxHealth;
  }

  void pickTarget() {
    int tries = 0;
    do {
      tx = random(20, width - 20);
      ty = random(20, height - 20);
      tries++;
    } while (collidesWithMap(tx, ty, max(2, size)) && tries < 10);
    changeTimer = int(random(40, 160));
  }

  void update() {
    if (changeTimer <= 0) pickTarget();
    changeTimer--;

    // compute movement toward current target
    float ang = atan2(ty - y, tx - x);
    float vx = cos(ang) * speed;
    float vy = sin(ang) * speed;

    float nx = x + vx;
    float ny = y + vy;

    if (!collidesWithMap(nx, ny, size)) {
      x = nx;
      y = ny;
    } else {
      pickTarget();
    }

    // random aggression toward player
    if (random(1) < 0.01) {
      tx = player.x + random(-100, 100);
      ty = player.y + random(-100, 100);
    }

    // determine left/right based on movement since last frame (avoid tiny jitter)
    float dx = x - prevX;
    float threshold = 0.4;
    if (dx > threshold) {
      bee = beeRight;
    } else if (dx < -threshold) {
      bee = beeLeft;
    }
    prevX = x;

    // health/death handling
    if (health <= 0 && !isDead) {
      die();
    }
  }
 void knockbackFrom(float fromX, float fromY, float strength) {
    float ang = atan2(y - fromY, x - fromX);
    float nx = x + cos(ang) * strength * 6;
    float ny = y + sin(ang) * strength * 6;
    if (!collidesWithMap(nx, ny, size)) {
      x = nx;
      y = ny;
    }
  }
  void display() {
    if (isDead) return;
    imageMode(CENTER);
    image(bee, x, y, size, size);
    imageMode(CORNER);
  }

  void takeDamage(int n) {
    health -= n;
  }

  void die() {
    isDead = true;
    // drop chance
  }
}
