// Ollie made this class thank you BSP and the very old game Rogue. 
// https://en.wikipedia.org/wiki/Binary_space_partitioning
// chatgpt also partook in this class thanks GPT 
// this is really hard to wrap my head around
class Leaf {
  int x, y, w, h;
  Leaf left, right;
  Room room;
  Leaf(int x_, int y_, int w_, int h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }
  boolean split(int minSize) {
    if (left != null || right != null) {
      return false;
    }
    boolean splitH = random(1) > 0.5;
    if (w > h && w / h >= 1.25) {
      splitH = false;
    } else if (h > w && h / w >= 1.25) {
      splitH = true;
    }

    int max = (splitH ? h : w) - minSize;
    if (max <= minSize) {
      return false;
    }
    int splitPos = int(random(minSize, max));

    if (splitH) {
      left = new Leaf(x, y, w, splitPos);
      right = new Leaf(x, y + splitPos, w, h - splitPos);
    } else {
      left = new Leaf(x, y, splitPos, h);
      right = new Leaf(x + splitPos, y, w - splitPos, h);
    }
    return true;
  }

  void createRooms(int padding) {
    if (left != null || right != null) {
      if (left != null) left.createRooms(padding);
      if (right != null) right.createRooms(padding);

      // if both daughters have rooms, optionally connect them later
    } else {
      // make a room inside this leaf
      int rw = int(random(max(3, w/2), max(3, w - padding)));
      int rh = int(random(max(3, h/2), max(3, h - padding)));
      int rx = x + int(random(1, max(1, w - rw - 1)));
      int ry = y + int(random(1, max(1, h - rh - 1)));
      room = new Room(rx, ry, rw, rh);
      rooms.add(room);
    }
  }

  void collectLeaves(ArrayList<Leaf> tree) {
    if (left == null && right == null) {
      tree.add(this);
    } else {
      if (left != null) left.collectLeaves(tree);
      if (right != null) right.collectLeaves(tree);
    }
  }
}
