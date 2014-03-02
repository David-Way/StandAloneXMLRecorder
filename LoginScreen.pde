//this class is used to display a login form for the patient to access the program through
class LoginScreen {

  //declare variables to be used
  private StandAloneXMLRecorder context;
  //array to store login buttons images
  private PImage[] login_images = new PImage[3];
  //to store images used
  private PImage loginBackgroundImage;
  private PImage logoImage;
  //variables to hold the Gp5 UI elements
  private Textfield[] textfields;
  private Button[] buttons;
  private Group loginGroup;
  PFont Font1;

  // constructor takes reference to the main class, sets it to context. Use
  // "context" instead of "this" when drawing
  public LoginScreen(StandAloneXMLRecorder c) {
    this.context = c;
  }

  //function called to load the assets for this screen
  public void loadImages() {
    // load images for login button
    this.login_images[0] = loadImage("images/NewUI/login_button_a.jpg");
    this.login_images[1] = loadImage("images/NewUI/login_button_b.jpg");
    this.login_images[2] = loadImage("images/NewUI/login_button_a.jpg");

    // load background image, loading icon & logo
    this.loginBackgroundImage = loadImage("images/background1.png");
    this.logoImage = loadImage("images/logo.png");
  }

  public void create() {
    //configure the Cp5 object
    cp5.setAutoDraw(false);

    // draw background image
    image(loginBackgroundImage, 0, 0, 1200, 600);
    Font1 = createFont("Arial Bold", 30);
    // insert version number top left of screen
    textSize(14);
    textFont(Font1);
    fill(color(211, 217, 203));
    text("version 1.01", 45 + 1, 10 + 1);
    fill(255);
    text("version 1.01", 45, 10);

    //draw the logo image around the text boxes
    image(logoImage, 430, 165, 334, 376);

    // set and draw title text with drop shadow,  not used
    String title = "Red Panda";
    String subTitle = "XML Recorder";
    textSize(38);
    fill(color(211, 217, 203));
    text(title, (width / 2) + 2, 100 + 2);
    fill(127, 174, 172);
    text(title, width / 2, 100);
    // draw subtitle text with drop shadow
    textSize(28);
    fill(color(211, 217, 203));
    text(subTitle, (width / 2) + 2, 138 + 2);
    fill(127, 174, 172);
    text(subTitle, width / 2, 138);

    PFont font = createFont("courier", 24);
    loginGroup = cp5.addGroup("loginGroup")
      .setPosition(0, 0)
        .hideBar()
          ;

    //iinitialise UI element arrays, used to make removing them easier
    textfields = new Textfield[2];
    buttons = new Button[1];

    //create a text field for the username, set its group, format it and make it visible
    textfields[0] = cp5.addTextfield("userName")
      .setLabelVisible(true)
        .setCaptionLabel("USERNAME")
          .setColorCaptionLabel(color(127, 174, 172))
            .setColor(color(255, 255, 255))
              .setColorActive(color(127, 174, 172))
                .setColorBackground(color(127, 174, 172))
                  .setColorForeground(color(211, 217, 203))
                    // .setImage(userNameImage)
                    .setPosition(width / 2 - 109, 294).setSize(218, 48)
                      .setFont(font)
                        // .setFocus(selectedTextField[0])
                        // .keepFocus(selectedTextField[0])
                        .setText("therapist")
                          //.setAutoClear(false)
                          .setGroup(loginGroup).setId(1);

    //create a textfield for password, set its group, format it  and make it visible
    //setPasswordMode is not compatible with the version of Cp5 we had to use
    textfields[1] = cp5.addTextfield("password")
      .setLabelVisible(true)
        .setCaptionLabel("PASSWORD")
          .setColorCaptionLabel(color(127, 174, 172))
            .setColor(color(255, 255, 255))
              .setColorActive(color(127, 174, 172))
                .setColorBackground(color(127, 174, 172))
                  .setColorForeground(color(211, 217, 203))
                    // .setImages(passwordImage, passwordImage, passwordImage)
                    .setPosition(width / 2 - 109, 359)
                      .setSize(218, 48)
                        .setFont(font)
                          // .setPasswordMode(true)
                          // .setFocus(selectedTextField[1])
                          // .keepFocus(selectedTextField[1])
                          .setText("therapist")
                            .setGroup(loginGroup)
                              .setId(2);

    //create a login button, set its group format it and set its normal, hover and click images.
    buttons[0] = cp5.addButton("log in").setColorBackground(color(8, 187, 209))
      .setPosition(width / 2 - 110, 424).setImages(login_images)
        .updateSize().setGroup(loginGroup).setId(3);
  }

  //this function is called in the RedPanda draw loop to draw the UI elements added to the Cp5 object 
  void drawUI() {               
    cp5.draw();
  }

  //function used to display a given error mesage
  public void displayError(String s) {
    fill(51, 196, 242);
    textSize(20);
    text(s, width / 2 - 109, 525, 218, 48);  // Text wraps within text box
  }

  public void drawFade() {
    //draws white box with alpha over error message area
    noStroke();
    fill(255, 3);
    rect( width / 2 - 109, 525, 218, 48);
  }

  //function called to remove UI elemts from the screen
  void destroy() {
    //loops through all the textfield elements and removes them
    for ( int i = 0 ; i < textfields.length; i++ ) {
      textfields[i].remove();
      textfields[i] = null;
    }
    //loops through all the button elements and removes them
    for ( int i = 0 ; i < buttons.length ; i++ ) {
      buttons[i].remove();
      buttons[i] = null;
    }
    //removes the group set for this screen from the Cp5 object
    cp5.getGroup("loginGroup").remove();
  }
}

