//Red Panda is a physiotherapy application created using the processing language and the OpenNI libraries for the Microsoft Kinect.
//This project was created with the aim of providing therapist with a tool for engaging with and monitoring the progress of their patients.
//Contributors: Emer Mooney and David Way (3rd year students at IADT)
//Supervisors: Joachim Pietsch and Andrew Errity

//program imports
import processing.opengl.*;  //alternative renderer

import controlP5.*;                 //UI element library
import SimpleOpenNI.*;        //OpenNI and NITE wrapper for processing, allows use of kinect data
import gifAnimation.*;           //gif loading/display library             

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.text.SimpleDateFormat; 

import org.apache.http.HttpResponse;                                        //apache libraries used when 
import org.apache.http.NameValuePair;                                     //making Http requests to the database
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.client.HttpClient;

import java.lang.reflect.Array;
import java.lang.reflect.GenericArrayType;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.TypeVariable;

import java.text.DateFormat;                //java data, format and shape libraries
import java.util.Date;                             //used by the JFreeCharts library to render charts
import java.awt.Color;
import java.awt.Font;
import java.awt.Paint;
import java.math.BigDecimal;
import java.awt.Shape;
import java.awt.geom.Rectangle2D;
import java.awt.geom.Ellipse2D;

import org.gicentre.utils.stat.*;                                    // For old chart classes
import java.io.UnsupportedEncodingException;     
import java.io.File;

import javax.xml.parsers.*;                                //libraries used for the XML file loader
import javax.xml.transform.*;                             //parser, and writer used in exercise two
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;
import org.xml.sax.*;
import org.w3c.dom.*;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

//declare kinect using SImppleOpenNi library
SimpleOpenNI kinect;

//declare UI objects for the cp5 library
ControlP5 cp5;
Group g1;
Group g2;
// declare login text fields
Textfield userNameTextField;
Textfield passwordTextField;
//login stored user name and password
String loginUserName = "";
String loginPassword = "";
//create screen
ErrorScreen errorScreen  = new ErrorScreen(this);
LoginScreen loginScreen  = new LoginScreen(this);
XMLExerciseClassOptimised xmlExercise = new XMLExerciseClassOptimised(this);
//declare variables for main program objects
User user;
Message message;

//integer for swithching scenes/rooms
int currentScene;
//user tracking variables
boolean loading = false;
Gif loadingIcon;
PImage leftHandIcon;
PImage rightHandIcon;
PVector leftHand = new PVector();
PVector rightHand = new PVector();
PVector convertedLeftJoint = new PVector();
PVector convertedRightJoint = new PVector();
PImage backgroundImage;
PImage backgroundImage2;

//variables for removing screens on next frame
boolean deleteErrorScreen = false;
boolean deleteLoginScreen = false;
boolean deleteMenuScreen = false;
boolean deleteProfileScreen = false;
boolean deleteProgramsScreen = false;
boolean deleteProgressScreen = false;
boolean deleteExerciseScreenOne = false;
boolean deleteExerciseScreenTwo = false;
boolean deleteExerciseScreenThree = false;
boolean deleteCommentsScreen = false;

//variable for automatic programme
boolean currentExerciseComplete = false;

//declare variable used to store the users prescibed exercises
ArrayList<Exercise> e = new ArrayList<Exercise>();

void setup() {
        //basic sketch setup functions, sets size, framerate, text mode and renderer
        size(1200, 600, P3D);
        frameRate(30);
        //textMode(SHAPE); 
        textAlign(CENTER, CENTER);
        //hand tracking image loading
        rightHandIcon = loadImage("images/righthand.png");
        leftHandIcon = loadImage("images/lefthand.png");
        loadingIcon = new Gif(this, "images/loading.gif");
        //animation = Gif.getPImages(this, "images/loading.gif");
        //load background image
        backgroundImage = loadImage("images/background1.png");
        backgroundImage2 = loadImage("images/background2.png");
        //creat main object for UI elements created using the ControlP5 library
        cp5 = new ControlP5(this);
        cp5.setFont(createFont("", 10));//memory leak semi-fix
        //load screen assets
        errorScreen.loadImages();
        loginScreen.loadImages();        
        xmlExercise.loadImages();


        currentScene = -1; //go to login scene
        //initialise the kinect using SimpleOpenNI library 
        kinect = new SimpleOpenNI(this);
        //enable depthMap generation
        kinect.enableDepth();
        // enable skeleton generation for all joints
        kinect.enableUser();
}

//This function is called repeatedly by the application
void draw() {

        //this switch statement is used to change the programs state
        //each screen is a different state that has its own scene number
        switch (currentScene) {

        case -1: //error screen
                if (kinect.isInit() == false) { //if the kinect cannot be initilised
                        //print console error
                        println("Can't init SimpleOpenNI, maybe the camera is not connected!");
                        //go to the error screen
                        errorScreen.drawUI();
                } 
                else { //if the kinect can be initialised
                        currentScene = 0; //set the current scene to 0, the login screen
                        deleteErrorScreen = true; //set the error screen to be deleted in the next draw loop
                        loginScreen.create(); //create the login screen
                }
                break;

        case 0: //login screen
                checkForScreensToDelete(); //checks for screens to be deleted
                loginScreen.drawFade(); //fades out error messages   
                loginScreen.drawUI(); //draws the UI for this scene
                break;

        case 7://xml exercise 2
                checkForScreensToDelete(); //checks for screens to be deleted
                background(backgroundImage2); //draws the faded background image for this scene
                xmlExercise.drawUI(false); //draws the UI for this scene, parameter true to draw debug HUD                
                break;
        }
}


//////////////////////////////////////////////////////////////////////
///BUTTONS PRESSED ACTIONS///////////////////////////////////////////
//This function is listenning for control events made by clicks inside the program
public void controlEvent(ControlEvent theEvent) {
        //tells you what controller was called
        //println(">/>"+ theEvent.getController().getName());       
        if (theEvent.isGroup()) {
                //println(cp5.getGroup("radioButton").getArrayValue()); 
                if (cp5.getGroup("radioButton").getArrayValue()[0] == 1) {
                        xmlExercise.setLimbOne();
                } else if (cp5.getGroup("radioButton").getArrayValue()[1] == 1) {
                        xmlExercise.setLimbTwo();
                } else if (cp5.getGroup("radioButton").getArrayValue()[2] == 1) {
                        xmlExercise.setLimbThree();
                } else if (cp5.getGroup("radioButton").getArrayValue()[3] == 1) {
                        xmlExercise.setLimbFour();
                }        
        }
        //login process
        else if (theEvent.getController().getName().equals("log in")) { //f the button was the log in button
                println("Logging in..");
                //get the values from the username and password fields
                loginUserName = cp5.get(Textfield.class, "userName").getText();
                loginPassword = cp5.get(Textfield.class, "password").getText();
                //create a new user connection object and try log in with the given details
                UserDAO userDAO = new UserDAO();
                user = userDAO.logIn(loginUserName, loginPassword);
                if (user.getUser_id() != -1 && currentScene == 0) { //if the user is logged in and theyre still in the loggin screen
                        println("Success!");                        
                        //delete the login screen on the next draw loop
                        deleteLoginScreen = true;                       
                        //create  the menu screen and pass the last completed record in to be displayed
                        xmlExercise.create(kinect, user, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND, new Exercise());
                        currentScene = 7;
                } 
                else { //user is not logged in
                        loginScreen.displayError("Incorrect login details"); //do not log in, display error message
                }
        }

        //if the menu back button is pressed from the other screens
        else if (theEvent.getController().getName().equals("menuBackProgrammes") || theEvent.getController().getName().equals("menuBackExercises") || theEvent.getController().getName().equals("menuBackExercise3")  || theEvent.getController().getName().equals("menuBackExercises2") || theEvent.getController().getName().equals("menuBackProgress") || theEvent.getController().getName().equals("menuBackComments") || theEvent.getController().getName().equals("cancelProgramme1") || theEvent.getController().getName().equals("cancelProgramme2") || theEvent.getController().getName().equals("cancelProgramme3") ) {
                menuBack(); //call this function
        }

        //if the logout button is pressed from the other screens
        else if (theEvent.getController().getName().equals("logout") || theEvent.getController().getName().equals("logoutPrograms") || theEvent.getController().getName().equals("logoutProgress") || theEvent.getController().getName().equals("logoutComments") || theEvent.getController().getName().equals("logoutExercise") || theEvent.getController().getName().equals("logoutExercise2") || theEvent.getController().getName().equals("logoutExercise3") ) {
                makeLogout(); //call this function
        }
}


boolean[] keys = new boolean[526];
boolean checkKey(int k)
{
        if (keys.length >= k) {
                return keys[k];
        }
        return false;
}

//keboard pressed listener
void keyPressed() {
        keys[keyCode] = true;
        if (checkKey(CONTROL) && checkKey(KeyEvent.VK_R)) { //when the R key is pressed
                if (currentScene == 7) { //if during exercise 2
                        xmlExercise.toggleRecording(); //change the recording state, on/off
                }
        } 
        else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_S)) { //when the S key is pressed
                if (currentScene == 7) { //if during exercise 2
                        xmlExercise.savePressed(); //save the recorded XML exercise
                }
        } 
        else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_L)) { //when the L key is pressed
                if (currentScene == 7) { //if during exercise 2
                        xmlExercise.loadPressed(); //load the XML exercise
                }
        }
}

void keyReleased()
{ 
  keys[keyCode] = false; 
}


//////////////////////////////////////////////////////////////////////////
//BUTTON FUNCTIONS
//called when UI elements are clicked 
void makeExerciseTwo() {
        deleteProgramsScreen = true; //set the programme screen to delete on next loop
        //load second exercise data
        xmlExercise = new XMLExerciseClassOptimised(this);
        xmlExercise.loadImages();
        //create xmlExercise object and pass in the user, the exercise and the joints to be tracked
        xmlExercise.create(kinect, user, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND, new Exercise());
        xmlExercise.readXML(e.get(1).getName());
        currentScene = 7; //set the current scene to 7, move to exercise one state in draw switch case
}

void menuBack() {
        //depending on where you go back from from delete the relavant screen
        if (currentScene == 2) { //programmes screen
                deleteProgramsScreen = true; //set if for delete on next loop
        }
        else if (currentScene == 4) { //progress screen
                deleteProgressScreen = true; //set if for delete on next loop
        }
        else if (currentScene == 5) { //comments screen
                deleteCommentsScreen = true; //set if for delete on next loop
        }
        else if (currentScene == 6) { //exercise screen
                deleteExerciseScreenOne = true; //set if for delete on next loop
        } 
        else if (currentScene == 7) { //exercise screen
                deleteExerciseScreenTwo = true; //set if for delete on next loop
        } 
        else if (currentScene == 8) { //exercise screen
                deleteExerciseScreenThree = true; //set if for delete on next loop
        }  
        currentScene = 0; 
        //create the menu screen object to be displayed
        loginScreen.create();
        deleteLoginScreen = false;
}

void makeLogout() {
        //depending on where you log out from delete the relavant screen
        if (currentScene == 1) { //menu  screen
                deleteMenuScreen = true;
        } 
        else if (currentScene == 2) { //programmes screen
                deleteProgramsScreen = true;
        } 
        else if (currentScene == 3) { //profile screen
                //deleteProfileScreen = true;
                deleteMenuScreen = true;
        } 
        else if (currentScene == 4) { //progress screen
                deleteProgressScreen = true;
        }  
        else if (currentScene == 5) { //comments screen
                deleteCommentsScreen = true;
        }  
        else if (currentScene == 6) { //exercise screen
                deleteExerciseScreenOne = true;
        }
        else if (currentScene == 7) { //exercise screen
                deleteExerciseScreenTwo = true;
        } 
        else if (currentScene == 8) { //exercise screen
                deleteExerciseScreenThree = true;
        } 
        //draw the login screen again
        currentScene = 0;
        //background(backgroundImage);
        loginScreen.create();
        deleteLoginScreen = false;
        //loginScreen.drawUI();
}

//this function checks to see if any screens have priviously set for deletion
void checkForScreensToDelete() {
        if (deleteErrorScreen == true) { //if a screen is to be deteled its destroy function is called, removing its UI elements
                errorScreen.destroy();
                deleteErrorScreen = false; //its delete variable is then set back to false
        } 
        else if (deleteLoginScreen == true) { //if a screen is to be deteled its destroy function is called, removing its UI elements
                loginScreen.destroy();
                deleteLoginScreen = false;
        } 

        else if (deleteExerciseScreenTwo == true) { //if a screen is to be deteled its destroy function is called, removing its UI elements
                xmlExercise.destroy(); 
                deleteExerciseScreenTwo = false;
        }
}


///////////////////////////////////////////////////////////////////////////
//HAND TRACKING///////////////////////////////////////////////////////////

void trackUser() {
        // update the cam
        //kinect.update();
        if (kinect.enableUser() == true) { //if the kinect can track the user
                kinect.update(); //update the current information from what the  camera is seeing

                IntVector userList = new IntVector();
                kinect.getUsers(userList); //get the user list from the data
                if (userList.size() > 0) { //if there is a user
                        int userId = userList.get(0); //get the first user

                        if (kinect.isTrackingSkeleton(userId)) { //if the kinect is tracking the first user
                                //get the points for the left and right hands
                                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
                                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
                                //draw the hand tracking icons at these posistions
                                drawLeftJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
                                drawRightJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
                        }
                }
        }
}

void trackUserNoHands() {
        // update the cam
        //kinect.update();
        if (kinect.enableUser() == true) { //if the kinect can track the user
                kinect.update(); //update the current information from what the  camera is seeing

                IntVector userList = new IntVector();
                kinect.getUsers(userList); //get the user list from the data
                if (userList.size() > 0) { //if there is a user
                        int userId = userList.get(0); //get the first user

                        if (kinect.isTrackingSkeleton(userId)) { //if the kinect is tracking the first user
                                //get the points for the left and right hands
                                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
                                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
                        }
                }
        }
}

//function for drawing the hand tracking icons
void drawLeftJoint(int userId, int jointID) {
        PVector leftJoint = new PVector(); 
        float confidence = kinect.getJointPositionSkeleton(userId, jointID, leftJoint); //get the position point confidence, not used
        kinect.convertRealWorldToProjective(leftJoint, convertedLeftJoint); //change the 3d perspective positioning of the joint into a flat plane
        if (loading == true) { //if loading is true
                loadingIcon.play(); //play the gif for loading icon at the tracked position
                image(loadingIcon, convertedLeftJoint.x-10, convertedLeftJoint.y-10, 20, 20);
        }
        else {
                //if not loading then pause the loading gif and draw the normal hand icon instead
                loadingIcon.pause();
                image(leftHandIcon, convertedLeftJoint.x-10, convertedLeftJoint.y-10, 20, 20);
        }
}

//function for drawing the hand tracking icons
void drawRightJoint(int userId, int jointID) {
        PVector rightJoint = new PVector();
        float confidence = kinect.getJointPositionSkeleton(userId, jointID, rightJoint); //get the position point confidence, not used
        kinect.convertRealWorldToProjective(rightJoint, convertedRightJoint); //change the 3d perspective positioning of the joint into a flat plane
        if (loading == true) { //if loading is true
                loadingIcon.play(); //play the gif for loading icon at the tracked position
                image(loadingIcon, convertedRightJoint.x-10, convertedRightJoint.y-10, 20, 20);
        }
        else {
                //if not loading then pause the loading gif and draw the normal hand icon instead
                loadingIcon.pause();
                image(rightHandIcon, convertedRightJoint.x-10, convertedRightJoint.y-10, 20, 20);
        }
}

//functions for changing the loading variable, used by the hand tracking
void loaderOn() {
        loading = true;
}

void loaderOff() {
        loading = false;
}

//////////////////////////////////////////////////////////////////////////
//USER TRACKING functions 
//events triggered by the kinect as it finds, looses and tracks users

void onNewUser(SimpleOpenNI curContext, int userId)
{
        println("onNewUser - userId: " + userId);
        println("\tstart tracking skeleton");

        curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
        println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
        //println("onVisibleUser - userId: " + userId);
}

