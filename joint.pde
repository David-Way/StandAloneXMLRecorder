//this class is used to draw a sphere at a given point of a certain radius
public class Joint {

  //declare variables for the object
  color col = color(255, 255, 255); //set the color to white
  PVector point1; //to store posistion
  float radius; //to store the spheres radius

    //joint constructor takes posititon and radius as parameters
  public Joint(PVector p1, float _r) {
    point1 = p1;
    radius = _r;
  }

  //this function is used to draw the sphere
  public void draw() {
    pushStyle(); // pushes the current style matrix onto the matrix stack, saving it
    pushMatrix(); // pushes the current transformation matrix onto the matrix stack, saving it
    noStroke(); //remove line stroke
    fill(col); //set fill colour
    translate(point1.x, point1.y, point1.z); //move to the given position
    scale(0.3f); //set the scale
    sphere(radius); //draw the sphere
    popMatrix(); //pops the current transformation matrix off the matrix stack. restoring the application to the previous transformation state
    popStyle(); //pops the current style matrix off the matrix stack. restoring the application to the previous style state
  }
}

