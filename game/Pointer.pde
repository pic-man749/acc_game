// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// Showing how to use applyForce() with box2d

// Fixed Attractor (this is redundant with Mover)

class Pointer {
  
  // We need to keep track of a Body and a radius
  Body body;
  float r;
  boolean life_flag = true;
  int pp[] = new int[2];

  Pointer(float r_, float x, float y, int pp1, int pp2) {
    r = r_;
    pp[0] = pp1;
    pp[1] = pp2;
    // Define a body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    // Set its position
    bd.position = box2d.coordPixelsToWorld(x,y);
    body = box2d.world.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    
    body.createFixture(cs,1);
    body.setUserData(this);
  }

  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(a);
    fill(0, 0, 255);
    stroke(0);
    strokeWeight(1);
    ellipse(0,0,r*2,r*2);
    popMatrix();
  }
  
  void delete() {
    box2d.destroyBody(body);
  }
  
  boolean is_alive(){
    return life_flag;
  }
  
  int[] getPP(){
    return pp;
  }
  
  // 衝突時
  void change() {
    life_flag = false;
  }
}