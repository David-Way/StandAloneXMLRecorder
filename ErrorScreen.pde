//this screen is used to notify the user when the kinect isnt connected
class ErrorScreen {
  //Store the vaiables for the kinect and the image
  private StandAloneXMLRecorder context;
  private PImage kinectImage;

  public ErrorScreen(StandAloneXMLRecorder c) {
    this.context = c;
  }

  //load the error image
  public void loadImages() {
    this.kinectImage = loadImage("images/kinect.png");
  }

  public void destroy() {
  }

  public void drawUI() {
    background(255); //set the background to white
    println(dataPath(""));
    println(sketchPath("xml-exercises")); 
    image(kinectImage, width/2 - 330, height/2 - 128); //draw the error image
    textSize(32); //draw the error message to the screen
    text("Camera Not Connected!", width/2, height/2 + 100);
    text("Please Connect Camera and Restart Application", width/2, height/2 + 140); 
    fill(0, 102, 153);
  }
}

