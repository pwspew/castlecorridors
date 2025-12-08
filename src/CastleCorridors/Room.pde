//Ollie made this class it's called room but it should be rooms but kapptie doesnt like plural in the class names
class Room {
  int x, y, w, h; // the tiles hahaha
  Room(int x_, int y_, int w_, int h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }
// center room for tracking purposes an d camera clamping.
  PVector center() {
    return new PVector((x + w/2) * tileSize, (y + h/2) * tileSize);
  }
  PVector randomPoint() {
    int rx = int(random(x+1, x + w - 1));
    int ry = int(random(y+1, y + h - 1));
    return new PVector(rx * tileSize + tileSize/2, ry * tileSize + tileSize/2);
  }

  void carve() {
    for (int i = x; i < x + w; i++) {
      for (int j = y; j < y + h; j++) {
        if (i >= 0 && i < cols && j >= 0 && j < rows) walkable[i][j] = true;
      }
    }
  }
}

void generateDungeon() {
  // reset walkable => walls everywhere
  for (int i = 0; i < cols; i++) for (int j = 0; j < rows; j++) walkable[i][j] = false;
  rooms.clear();

  // create root leaf in tile coords
  Leaf root = new Leaf(1, 1, cols - 2, rows - 2);
  ArrayList<Leaf> list = new ArrayList<Leaf>();
  list.add(root);

  // split      these numbers on the next line below are changeable and they chage the amount of rooms and stuff like that
  int minLeaf = max(9, int(min(cols, rows) * 0.30)); 
  boolean didSplit = true;
  int attempts = 0;
  while (didSplit && attempts < 200) {
    didSplit = false;
    ArrayList<Leaf> copy = new ArrayList<Leaf>(list);
    for (Leaf l : copy) {
      if (l.left == null && l.right == null) {
        if (l.w > minLeaf || l.h > minLeaf) {
          if (l.split(minLeaf)) {
            list.add(l.left);
            list.add(l.right);
            didSplit = true;
          }
        }
      }
    }
    attempts++;
  }

  // create rooms  V this can be changed
  root.createRooms(4);

  // carve rooms
  for (Room r : rooms) r.carve();

  // connect rooms in sequence via center
  if (rooms.size() > 1) {
    // sort rooms by x to have nicer connections
    // sort rooms by x to have nicer connections (simple selection sort — safe in Processing)
    for (int i = 0; i < rooms.size() - 1; i++) {
      int minIdx = i;
      for (int j = i + 1; j < rooms.size(); j++) {
        if (rooms.get(j).x < rooms.get(minIdx).x) {
          minIdx = j;
        }
      }
      if (minIdx != i) {
        Room tmp = rooms.get(i);
        rooms.set(i, rooms.get(minIdx));
        rooms.set(minIdx, tmp);
      }
    }
    // connect rooms in sorted order
    for (int i = 0; i < rooms.size() - 1; i++) {
      PVector c1 = rooms.get(i).center();
      PVector c2 = rooms.get(i + 1).center();
      carveCorridor(int(c1.x / tileSize), int(c1.y / tileSize), int(c2.x / tileSize), int(c2.y / tileSize));
    }
  }

  // Surround map edges with walls (already walls by default), so nothing extra needed.

  // After carving, spawn a few items/enemies inside rooms
  enemies.clear();
  items.clear();
  for (int i = 0; i < 4; i++) {
    if (rooms.size()>0) {
      Room r = rooms.get(int(random(rooms.size())));
      PVector p = r.randomPoint();
      enemies.add(new Enemy(this, p.x, p.y));
    }
  }
  for (int i = 0; i < 3; i++) {
    if (rooms.size()>0) {
      Room r = rooms.get(int(random(rooms.size())));
      PVector p = r.randomPoint();
      items.add(new Item(this, p.x, p.y));
    }
  }
}

// carve an L-shaped corridor (tile coords)
// carve an L-shaped corridor (tile coords) with thickness >1
void carveCorridor(int x1, int y1, int x2, int y2) {
  int thickness = 2; // 2 tiles wide corridor (set to 3 for thicker)
  int cx = x1;
  int cy = y1;



  // horizontal first
  while (cx != x2) {
    for (int tx = cx - (thickness-1)/2; tx <= cx + thickness/2; tx++) {
      for (int ty = cy - (thickness-1)/2; ty <= cy + thickness/2; ty++) {
        if (tx >= 0 && tx < cols && ty >= 0 && ty < rows) walkable[tx][ty] = true;
      }
    }
    cx += (x2 > cx) ? 1 : -1;
  }
  // vertical to target
  while (cy != y2) {
    for (int tx = cx - (thickness-1)/2; tx <= cx + thickness/2; tx++) {
      for (int ty = cy - (thickness-1)/2; ty <= cy + thickness/2; ty++) {
        if (tx >= 0 && tx < cols && ty >= 0 && ty < rows) walkable[tx][ty] = true;
      }
    }
    cy += (y2 > cy) ? 1 : -1;
  }
  // final tile
  for (int tx = cx - (thickness-1)/2; tx <= cx + thickness/2; tx++) {
    for (int ty = cy - (thickness-1)/2; ty <= cy + thickness/2; ty++) {
      if (tx >= 0 && tx < cols && ty >= 0 && ty < rows) walkable[tx][ty] = true;
    }
  }
}

// draw walls and floors
void drawDungeon() {
  // draw tiles
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (!walkable[i][j]) {
        fill(0, 10, 0);
        rect(i * tileSize, j * tileSize, tileSize, tileSize);
      } else {
        fill(20, 20, 30);
        rect(i * tileSize, j * tileSize, tileSize, tileSize);
      }
    }
  }
  // room treelines (optional)
  noFill();
  for (Room r : rooms) {
    rect(r.x * tileSize, r.y * tileSize, r.w * tileSize, r.h * tileSize);
  }
  noStroke();
}

// small preview used on title
void dungeonPreview() {
  push();
  translate(width/2+280 , height/2+250);
  scale(0.2);
  drawDungeon();
  pop();
}
