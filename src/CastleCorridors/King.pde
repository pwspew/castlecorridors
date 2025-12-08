
// ellie jacobsen made this class
// ollie and ethan polished it
class King {
  float x, y;
  float size = 86;
  float speed = 1.6;
  float vx = 0, vy = 0;
  PImage theking = loadImage("king.png");
  Gif therealking;
  King(PApplet parent, float sx, float sy) {
    x = sx;
    y = sy;
    therealking = new Gif(parent, "kingtailwave.gif");
    therealking.play();
  }

  void setPos(float sx, float sy) {
    x = sx;
    y = sy;
  }

  void updateTowards(float tx, float ty) {
    float angle = atan2(ty - y, tx - x);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;

    float nx = x + vx;
    float ny = y + vy;

    if (!collidesWithMap(nx, ny, size)) {
      x = nx;
      y = ny;
    } else {
      boolean moved = false;
      for (float a = -PI/2; a <= PI/2; a += PI/6) {
        float alt = angle + a;
        nx = x + cos(alt) * speed;
        ny = y + sin(alt) * speed;
        if (!collidesWithMap(nx, ny, size)) {
          x = nx;
          y = ny;
          moved = true;
          break;
        }
      }
      if (!moved) {
        float r = random(1);
        if (r < 0.3) {
          float alt = angle + random(-PI, PI);
          nx = x + cos(alt) * speed * 0.5;
          ny = y + sin(alt) * speed * 0.5;
          if (!collidesWithMap(nx, ny, size)) {
            x = nx;
            y = ny;
          }
        }
      }
    }

    x = constrain(x, size/2, width - size/2);
    y = constrain(y, size/2, height - size/2);
  }
//ollie made the knockback
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
    noStroke();
    fill(220, 50, 50);
    //ellipse(x, y, size, size);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("evil lion of doom", x, y - size/2 - 10);
    imageMode(CENTER);
    image(therealking, x, y, size, size);
  }
}
