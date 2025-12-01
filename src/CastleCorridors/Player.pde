//Madeline H made this class.
// she made the HUD, movement, and collision and Ollie implemented the room index

class Player {
  float x, y;
  int size = 10;
  float speed = 3.2;
  int maxHealth = 100;
  int health = maxHealth;
  int score = 0;
  boolean left, right, up, down;
  int attackCooldown = 0;

  Player(float x_, float y_) {
    x = x_;
    y = y_;
  }

  void reset(float nx, float ny) {
    x = nx;
    y = ny;
    health = maxHealth;
    score = 0;
    left = right = up = down = false;
  }

  void update() {
    float dx = 0;
    float dy = 0;
    if (left) dx -= 1;
    if (right) dx += 1;
    if (up) dy -= 1;
    if (down) dy += 1;
    if (dx!=0 || dy!=0) {
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
    }
    // update current room index after movement
    int idx = getRoomIndexAt(x, y);
    if (idx != -1 && idx != currentRoomIndex) {
      currentRoomIndex = idx;
      // optional: trigger on-enter-room stuff
      // println("Entered room " + currentRoomIndex);
    }

    x = constrain(x, size/2, width - size/2);
    y = constrain(y, size/2, height - size/2);
    if (attackCooldown > 0) attackCooldown--;
  }

  void display() {
    noStroke();
    fill(80, 200, 250);
    ellipse(x, y, size, size);
    if (attackCooldown > 0 && attackCooldown > 18) {
      fill(255, 150, 0, 80);
      ellipse(x, y, 80, 80);
    }
  }

  void displayHUD() {
    fill(255);
    textSize(16);
    text("Health: " + health, 40, 28);
    text("Score: " + score, 40, 48);
  }

  void attack() {
    if (attackCooldown == 0) {
      attackCooldown = 30;
      float range = 40;
      for (int i = enemies.size()-1; i >= 0; i--) {
        Enemy e = enemies.get(i);
        if (dist(x, y, e.x, e.y) < range + e.size/2) {
          e.isDead = true;
          score += 10;
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

