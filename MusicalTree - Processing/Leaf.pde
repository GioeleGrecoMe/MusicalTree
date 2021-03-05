
class Leaf {
  PVector pos;
  boolean reached = false;

  Leaf(float x,float y,float z) {
    
    pos = new PVector(round(x),round(y),round(z));
  }

  void reached() {
    reached = true;
  }

  void show() {
    pushMatrix();
    stroke(255);
    point(pos.x,pos.y,pos.z);
    popMatrix();
  }
}
