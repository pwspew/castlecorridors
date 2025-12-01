// Ethan made this class
// ollie made the pseudo-timer
class Enemy {
  float x, y;
  float size = 10;
  float speed = 1.2;
  boolean isDead = false;
  float tx, ty;
  int changeTimer = 0;

  Enemy(float sx, float sy) {
    x = sx;
    y = sy;
    pickTarget();
  }

  void pickTarget() {
    int tries = 0;
    do {
      tx = random(20, width - 20);
      ty = random(20, height - 20);
      tries++;
    } while (collidesWithMap(tx, ty, size) && tries < 10);
    changeTimer = int(random(40, 160));
  }

  void update() {
    if (changeTimer <= 0) pickTarget();
    changeTimer--;
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

    if (random(1) < 0.01) {
      tx = player.x + random(-100, 100);
      ty = player.y + random(-100, 100);
    }
  }

  void display() {
    noStroke();
    fill(200, 180, 50);
    ellipse(x, y, size, size);
  }
}

