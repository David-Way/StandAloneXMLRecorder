//Class to draw limbs of user
public class Limb2 {
  //Set color, points and scale variables
  color col = color(128, 128, 128);
  PVector point1, point2, midPoint, polar;
  float scaleFactorY, scaleFactorZ;

  //Constructor takes in two pvectors for start and end point fo limb
  //and scale factors. factor of 1.0 will give a circle, 0.3 will be closer to limb and the colour
  public Limb2(PVector p1, PVector p2, float _scaleFactorY, float _scaleFactorZ, color _col ) {
    point1 = p1;
    point2 = p2;
    scaleFactorY = _scaleFactorY;
    scaleFactorZ = _scaleFactorZ;
    //Calculates the midpoint between point 1 and point 2 x, y and z values
    midPoint = new PVector( (point1.x+point2.x)/2.f, (point1.y+point2.y)/2.f, (point1.z+point2.z)/2.f );
    //Vecotr is the direction away from midpoint to point2
    PVector vector = new PVector();
    vector.set(point2);
    vector.sub(midPoint);
    polar = cartesianToPolar( vector );
    col = _col;
  }

  public float draw() {
    //Save style and rotation matrix
    pushStyle();
    pushMatrix();
    noStroke();
    //fill only
    fill(col);
    //Move origin to centre of sphere
    translate(midPoint.x, midPoint.y, midPoint.z);
    //Rotate so x axis points along polar coordinate vector
    rotateY( polar.y );
    rotateZ( polar.z );
    //Squash sphere by scale factors
    scale(1, scaleFactorY, scaleFactorZ);
    //draw shpere according to radius of polar coordinates
    sphere(polar.x);
    //restore style and rotation matrix
    popMatrix();
    popStyle();
    //return radius for use in joint drawing
    return polar.x;
  }

  //converts from cartesian (x,y,z component) to polar (radius, rotation, z rotation) coordinates.
  PVector cartesianToPolar(PVector v) {
    PVector res = new PVector();
    res.x = v.mag();
    if (res.x > 0) {
      res.y = -atan2(v.z, v.x);
      res.z = asin(v.y / res.x);
    } 
    else {
      res.y = 0;
      res.z = 0;
    }
    return res;
  }
}

