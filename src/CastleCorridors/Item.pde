// Ollie made this class (Im so cool and awesome) (I am carrying this team on my back)
class Item {
  float x, y;
  float size = 14;
  int value = 5;
  int itype = int(random(0, 2));
  Gif speedgif;


  Item(PApplet parent, float sx, float sy) {
    x = sx;
    y = sy;
    value = 5 + int(random(0, 6));
    itype = int(random(0, 2));

    speedgif = new Gif(parent, "speedpowerup.gif");
    speedgif.play();
  }



  void display() {
    noStroke();
    fill(100, 255, 120);
    rectMode(CENTER);
    // rect(x, y, size, size);
    rectMode(CORNER);
    imageMode(CENTER);
    image(speedgif, x, y, size*2, size*2);
  }
}
