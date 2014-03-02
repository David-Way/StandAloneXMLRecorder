//this class is used for displaying and recording an exercising using xml data
//the program can load the prescibed movement comprised of the pre recorded joint 
//position data of 3 selected joints
class XMLExerciseClassOptimised {        
        //declare variables to store screen main objects
        StandAloneXMLRecorder parent;
        SimpleOpenNI context;
        User user;
        Exercise e;
        //declare array to store the joints to be tracked 
        int [] jointID;
        int userID;
        //create structure for storing target positions for the exercise
        ArrayList<ArrayList<PVector>> framesGroup = new ArrayList<ArrayList<PVector>>(3);
        ArrayList<PVector> framesOne;
        ArrayList<PVector> framesTwo;
        ArrayList<PVector> framesThree;

        //declare arrayst to store the button images
        private PImage[] menuBack = new PImage[3];
        private PImage[] logout = new PImage[3];
        private PImage[] cancel = new PImage[3];
        private Button []buttons;
        private RadioButton[] rbArray;
        private Group exerciseGroup2;
        Group radioButton;
        private Textfield[] textfields;


        long startTime = 0;
        //declare the message objects needed
        Message message;
        Message directionMessage;
        Message continueMessage;
        //default values for exercise
        String exerciseName;
        float c = (float)0.0;
        float offByDistance = (float)0.0;
        int currentFrame = 0;
        int numberOfFrames = 0;
        int numberOfReps = 5;
        int currentRep = 0;
        //boolean state flags
        boolean paused = false;
        boolean recording = false;
        boolean exerciseStarted = false;
        boolean exerciseComplete = false;
        Gif target;
        //default font values
        final int FONT_30 = 30;
        final int FONT_24 = 24;
        //set colours for user avatar
        color userColourRed = color(255, 0, 0);
        color userColourGreen = color(0, 255, 0);
        color userColourBlue = color(0, 0, 255);
        color userColourGrey = color(155, 155, 155);
        color userColourWhite = color(255, 255, 255);
        color currentUserColour = userColourWhite;
        //declare and initiliase variables used by the automatic programme advancement function
        boolean finishedTimerStarted = false;
        long finishStartTime = 0;
        PFont font = createFont("courier", 24);

        PVector messagePosition = new PVector(10, 100);
        IntVector userList;

        //XMLExerciseClassOptimised constructor, takes a reference to the Redpanda class
        XMLExerciseClassOptimised(StandAloneXMLRecorder parent) {
                this.parent = parent;
                this.jointID = new int[3]; //initialise array t hat holds the selected joints
        }

        //create function takes reference to the kinect, the user object, the three joints to be tracked and the exercise to execute
        void create(SimpleOpenNI tempContext, User user, int tempJointIDOne, int tempJointIDTwo, int tempJointIDThree, Exercise ex) {
                target = new Gif(parent, "images/target.gif"); //load the taget gif
                textFont(font);
                //initilise required variables 
                this.context = tempContext; 
                this.user = user;
                userList = new IntVector();
                this.jointID[0] = tempJointIDOne; //store the chosen joint parameters
                this.jointID[1] = tempJointIDTwo;
                this.jointID[2] = tempJointIDThree;
                //create arrays to store each joints point data for each frame
                this.framesOne = new ArrayList<PVector>(); 
                this.framesTwo = new ArrayList<PVector>();
                this.framesThree = new ArrayList<PVector>();
                //framesCenter = new ArrayList<PVector>();
                this.framesGroup.add(framesOne); //add these arrays to a group array
                this.framesGroup.add(framesTwo);
                this.framesGroup.add(framesThree);
                //set exercise info
                this.e = ex;
                this.exerciseName = e.getName();
                this.numberOfReps = e.getRepetitions();

                //create UI elements
                cp5.setAutoDraw(false);

                //create UI elements group for this scene
                exerciseGroup2 = cp5.addGroup("exerciseGroup2")
                        .setPosition(0, 0)
                                .hideBar()
                                        ;

                //create an array for the buttons to make them easier to remove
                buttons = new Button[2];

                //create a menu back button, set the size and image
                buttons[0] = cp5.addButton("menuBackExercises2")
                        .setPosition(10, 10)
                                .setImages(menuBack)
                                        .updateSize()
                                                .setGroup(exerciseGroup2)
                                                        ;

                //create a logout button, set the size and image
                buttons[1] = cp5.addButton("logoutExercise2")
                        .setPosition(978, 10)
                                .setImages(logout)
                                        .updateSize()
                                                .setGroup(exerciseGroup2)
                                                        ;

                textfields = new Textfield[1];
                //create a text field for the username, set its group, format it and make it visible
                textfields[0] = cp5.addTextfield("input")
                        .setLabelVisible(true)
                                .setCaptionLabel("File Name")
                                        .setColorCaptionLabel(color(127, 174, 172))
                                                .setColor(color(255, 255, 255))
                                                        .setColorActive(color(127, 174, 172))
                                                                .setColorBackground(color(127, 174, 172))
                                                                        .setColorForeground(color(211, 217, 203))
                                                                                // .setImage(userNameImage)
                                                                                .setPosition(979, 95).setSize(209, 48)
                                                                                        .setFont(font)
                                                                                                // .setFocus(selectedTextField[0])
                                                                                                // .keepFocus(selectedTextField[0])
                                                                                                .setText("default")
                                                                                                        //.setAutoClear(false)
                                                                                                        .setGroup(exerciseGroup2).setId(1);

                rbArray = new RadioButton[1];
                rbArray[0] = cp5.addRadioButton("radioButton")
                        .setPosition(10, 550)
                                .setSize(40, 40)
                                        .setColorForeground(color(68, 142, 174))
                                                .setColorActive(color(68, 142, 174))
                                                        .setColorLabel(color(68, 142, 174))
                                                                .setItemsPerRow(4)
                                                                        .setSpacingColumn(16)
                                                                                .addItem("1", 1)
                                                                                        .addItem("2", 2)
                                                                                                .addItem("3", 3)
                                                                                                        .addItem("4", 4)
                                                                                                                ;
                //r.activate(1);


                //create message UI elements
                message = new Message(209, 400, messagePosition, "Hi " + user.getFirst_name() + ",\nWelcome to the XML Exeercise Recorder \n" + "Total Frames: " + framesGroup.get(0).size() + "\nCurrent Frame: " + currentFrame + "\nRecording: " + recording + "\n\nRadio Buttons select limb to record: \nLimb 1: Left Arm\nLimb 2: Right Arm\nLimb 3: Left Leg\nLimb 4: Right Leg");
                message.create("mgroup", "lname");
                //startTime  = System.currentTimeMillis();

                //initiliase the needed UI message objects, set positions, content and size
                directionMessage = new Message(209, 350, new PVector(979, 170), "Buttons:\nCTRL+ \nS: save exercise \nL: load exercise \nR: toggle recording \n\nEnter the filename in the textfield above.", 24);
                directionMessage.create("c", "d");

                continueMessage = new Message(10, 10, new PVector(0, 0), "", FONT_24);
                continueMessage.create("s", "q");

                //set exercise 
                exerciseComplete = false;
                currentFrame = 0;
                numberOfFrames = 0;
                paused = false;
                recording = false;
                exerciseComplete = false;
                readXML("default");
        }

        void drawUI(boolean drawHUD) {
                pushMatrix();
                //update kinect information
                context.update();
                //message.drawUI();
                directionMessage.drawUI();
                //println(currentRep);

                if (drawHUD) { //if the parameter passed into the function is true then draw the debug HUD
                        drawHeadsUpDisplay();
                }

                //set the lights an stroke for the scene
                lights();
                noStroke();
                //this centers the kinect 640x480 view window on the 1200x600 processing sketch area
                //the data needs to be rotated on its x axis to invert the y values, the kinect uses negative y values for up
                translate(width/2, height/2, 0);
                rotateX(radians(180));
                // text("Left Arm        Left Leg        Right Arm        Right Leg", 10, 525);
                //get the users vivible to the kinect
                context.getUsers(userList);

                //if the there is a visible user ad the exercise isnt complete
                if (userList.size() > 0 && !exerciseComplete) {
                        //get the id of the first user
                        int userId = userList.get(0);
                        setUser(userId);
                        //if the kinect is tracking the users skeleton
                        if ( context.isTrackingSkeleton(userId)) {
                                //check to see if the exercis is has been started
                                if (!exerciseStarted) {
                                        startTime  = System.currentTimeMillis(); //get the current time, the start time
                                        exerciseStarted = true;
                                }
                                drawSkeleton(userId); //draw the user
                                // if we're recording tell the recorder to capture this frame
                                if (recording) { //if recordng 
                                        setUserColour(userColourRed); //change the avatar colour to red
                                        if (numberOfFrames%30 == 0) { //record every 30th frame, every 1 second
                                                recordFrame();
                                        }
                                        //increment the current frame number
                                        numberOfFrames++;
                                } 
                                else {
                                        //the user should be grey
                                        setUserColour(userColourWhite);
                                        //display user directions
                                        directionMessage.destroy();
                                        directionMessage = new Message(209, 350, new PVector(979, 170), "Buttons: \nCTRL + \nS: save exercise \nL: load exercise \nR: toggle recording \n\nEnter the filename in the textfield above.", 24);
                                        directionMessage.create("e", "f");

                                        drawExerciseSkeleton(userId); //draw the user avatar

                                        //if user is close to points
                                        if (checkUserCompliance(userId)) {
                                                nextFrame(); //advance to the next target position
                                        }
                                }
                                message.destroy();
                                message = new Message(209, 400, messagePosition, "Hi " + user.getFirst_name() + ",\nWelcome to the XML Exeercise Recorder \n" + "Total Frames: " + framesGroup.get(0).size() + "\nCurrent Frame: " + currentFrame + "\nRecording: " + recording + "\n\nRadio Buttons select limb to record: \nLimb 1: Left Arm\nLimb 2: Right Arm\nLimb 3: Left Leg\nLimb 4: Right Leg");
                                message.create("mgroup", "lname");
                        }
                }
                popMatrix();
        }

        //this functon returns true if the users 2nd two joints are within a distance of 200
        boolean checkUserCompliance(int userId) {
                //set result variable to be returned
                boolean result = false;

                if (framesGroup.get(0).size() > 1) {
                        //get the posisitons of the targets, adjusted to the users current ancor point
                        //for example if the first join is the shoulder all other target points are calculated in relation to it
                        //this allows the the targets to move with the user so they can complete the exercise in any position
                        ArrayList<PVector> exercisePointsForCurrentFrame = getAdjustedPositions(new PVector(0, 0, 0));

                        PVector c1 = new PVector();
                        PVector c2 = new PVector();
                        PVector c3 = new PVector();

                        //get the posisiton of the tracked joint visible to the kinect
                        context.getJointPositionSkeleton(userId, jointID[2], c1);
                        context.getJointPositionSkeleton(userId, jointID[1], c2);
                        context.getJointPositionSkeleton(userId, jointID[0], c3);

                        //get the two other target joints, joint 0 is the anchor joint
                        PVector p1 = exercisePointsForCurrentFrame.get(2);
                        PVector p2 = exercisePointsForCurrentFrame.get(1);
                        //PVector p3 = exercisePointsForCurrentFrame.get(0);

                        //alternative compliance measurement
                        //flatten the ponts to ignore z axis, recreate the real position of the target points
                        //by adding the vectors to the posistion of the current anchor point
                        PVector added1 = PVector.add(p1, c3);
                        PVector added2 =  PVector.add(p2, c3);
                        PVector flat1 = new PVector(added1.x, added1.y);
                        PVector flat2 = new PVector(added2.x, added2.y);
                        PVector flatA = new PVector(c1.x, c1.y);
                        PVector flatB = new PVector(c2.x, c2.y);

                        //if the distance between the points is less than 200 or the x and y
                        if ((flatA.dist(flat1) < 200  && flatB.dist(flat2) < 200)) { 
                                result = true; //if the user is close to both these points set the result to true
                        }
                }
                return result;
        }

        //getters and setters for user id and user colour
        void setUserColour(color c) {
                currentUserColour = c;
        }

        void setUser(int tempUserID) { 
                userID = tempUserID;
        }

        PVector getPosition(int joint) {
                return framesGroup.get(joint).get(currentFrame);
        }

        //this function returns the raw relational recorded position data for each joint through all frames
        ArrayList<PVector> getPositions() {
                ArrayList<PVector> p = new ArrayList<PVector>();
                for (int i = 0; i < 3; i++) {                        
                        p.add(framesGroup.get(i).get(currentFrame));
                }
                return p;
        }

        ArrayList<PVector> getAdjustedPositions(PVector anchorJoint) {                
                //pushMatrix();
                //scale(0.8f);
                ArrayList<PVector> p = new ArrayList<PVector>();
                for (int i = 0; i < 3; i++) {
                        PVector temp = framesGroup.get(i).get(currentFrame);
                        if (i == 0) {
                                //temp = anchorJoint; 
                                temp.z  = anchorJoint.z;
                        }
                        p.add(temp);
                }
                //popMatrix();
                return p;
        }

        void drawExerciseSkeleton(int userId) {

                pushStyle();
                pushMatrix();

                PVector anchorJoint = new PVector();
                context.getJointPositionSkeleton(userId, jointID[0], anchorJoint);

                ArrayList<PVector> exercisePointsForCurrentFrame = getAdjustedPositions(anchorJoint);

                scale(0.8f);
                PVector p1 = new PVector();
                PVector p2 = new PVector();
                PVector p3 = new PVector();
                // left arm
                //context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, p3);
                //context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, p2);
                p1 = exercisePointsForCurrentFrame.get(2);
                p2 = exercisePointsForCurrentFrame.get(1);
                p3 = exercisePointsForCurrentFrame.get(0);

                //translate(p3.x, p3.y, p3.z);
                translate(anchorJoint.x, anchorJoint.y, anchorJoint.z);
                //sphere(40);
                target.play();
                //image(target, -75, -75, 275, 275);


                pushMatrix();
                translate(p1.x, p1.y, p1.z);

                //sphere(50);
                image(target, -125, -125, 250, 250);
                popMatrix();

                pushMatrix();
                translate(p2.x, p2.y, p2.z);

                //sphere(50);
                image(target, -125, -125, 250, 250);
                popMatrix();


                /*pushMatrix();                
                 //translate(p3.x, p3.y, p3.z);
                 //translate(anchorJoint.x, anchorJoint.y, anchorJoint.z);
                 println(anchorJoint.z);
                 Limb2 testLimb2 = new Limb2( anchorJoint, p2, 0.3f, 0.3f, userColourBlue);
                 testLimb2.draw();
                 
                 testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, userColourGreen);
                 testLimb2.draw();
                 popMatrix();*/

                popMatrix();
                popStyle();
        }     

        // draw the skeleton with the selected joints
        void drawSkeleton(int userId) {
                pushMatrix();
                //println("Skeleton");
                //rotateX(radians(-180));
                //translate(-320,-240, 0);
                scale(0.8f);

                PVector p1 = new PVector();
                PVector p2 = new PVector();
                float radius;

                //println("left arm");
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, p1);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, p2);
                Limb2 testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                Joint joint = new Joint(p1, radius);
                joint.draw();
                joint = new Joint(p2, radius);
                joint.draw();

                p1.set(p2);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p2, radius);
                joint.draw();

                //println("right arm");
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, p1);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p1, radius);
                joint.draw();
                joint = new Joint(p2, radius);
                joint.draw();
                p1.set(p2);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p2, radius);
                joint.draw();

                //println("left leg");
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, p1);
                joint = new Joint(p1, radius);
                joint.draw();
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p2, radius);
                joint.draw();
                p1.set(p2);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p2, radius);
                joint.draw();


                //println("right leg");
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, p1);
                joint = new Joint(p1, radius);
                joint.draw();
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p2, radius);
                joint.draw();
                p1.set(p2);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, p2);
                testLimb2 = new Limb2(p1, p2, 0.3f, 0.3f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p2, radius);
                joint.draw();

                //println("torso");
                PVector p3 = new PVector();
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, p1);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, p2);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, p3);
                // fiddle with offset here
                testLimb2 = new Limb2(p1, new PVector((p2.x+p3.x)/2.f, (p2.y+p3.y)/2.f, (p2.z+p3.z)/2.f), 0.7f, 0.7f, currentUserColour);
                testLimb2.draw();

                //println("head");
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, p1);
                kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, p2);
                //p1.add(0,100,0);
                p2.add(0, 100, 0);
                testLimb2 = new Limb2(p1, p2, 0.7f, 0.5f, currentUserColour);
                radius = testLimb2.draw();
                joint = new Joint(p1, radius);
                joint.draw();
                popMatrix();
        }


        void recordFrame() {
                //record the positions of the 3 chosen joints
                //first joint will be anchor point
                PVector positionAnchor = new PVector(); 
                //PVector positionPoint = new PVector(); 
                // PVector storedTorso = new PVector();

                //record the anchor joint position
                context.getJointPositionSkeleton(userID, jointID[0], positionAnchor);
                framesGroup.get(0).add(positionAnchor);

                for (int i = 1; i < 3; i++) { //loop through each joint 
                        PVector positionPoint = new PVector();           
                        context.getJointPositionSkeleton(userID, jointID[i], positionPoint); //get the posistion of the anchor point                      
                        PVector differenceVector = PVector.sub( positionPoint, positionAnchor); //get the vector difference between it and each joint
                        framesGroup.get(i).add(differenceVector); //save the vvector difference as the value for this joint on the current frame
                }
        }

        //this function is called on every frame that the user is close enough to the targets
        void nextFrame() { 
                //if the exercise isnt paused
                if (!paused) {
                        currentFrame++; //incremement the current fframe number
                        if (currentFrame == framesGroup.get(0).size()) { //if the current frame is equall to the total number of frames
                                currentFrame = 0; //loop back to the start of the exercise
                                currentRep++; //increase the number of completed repetitions
                        }
                }
        }

        void drawHeadsUpDisplay() { //used for debugiing
                pushMatrix();
                // create hud with frame info
                fill(0);
                text("totalFrames: " + framesGroup.get(0).size(), 5, 10);
                text("recording: " + recording, 5, 24);
                text("currentFrame: " + currentFrame, 5, 38 );
                popMatrix();
        }

        void loadImages() {
                //load images  for buttons
                this.menuBack[0]  = loadImage("images/NewUI/menu.jpg");        //normal
                this.menuBack[1]  = loadImage("images/NewUI/menuOver.jpg");//hover
                this.menuBack[2]  = loadImage("images/NewUI/menu.jpg");        //click
                this.logout[0] = loadImage("images/NewUI/logout.jpg");
                this.logout[1] = loadImage("images/NewUI/logoutOver.jpg");
                this.logout[2] = loadImage("images/NewUI/logout.jpg");
                this.cancel[0] = loadImage("images/NewUI/cancel.jpg");
                this.cancel[1] = loadImage("images/NewUI/cancelOver.jpg");
                this.cancel[2] = loadImage("images/NewUI/cancel.jpg");
        }

        void toggleRecording() { //change the programs recording state
                recording = !recording;
                if (recording) {
                        currentFrame = 0;
                        numberOfFrames = 0;
                        framesGroup = new ArrayList<ArrayList<PVector>>(3);
                        //create arrays to store each joints point data for each frame
                        this.framesOne = new ArrayList<PVector>(); 
                        this.framesTwo = new ArrayList<PVector>();
                        this.framesThree = new ArrayList<PVector>();
                        //framesCenter = new ArrayList<PVector>();
                        this.framesGroup.add(framesOne); //add these arrays to a group array
                        this.framesGroup.add(framesTwo);
                        this.framesGroup.add(framesThree);
                }
                System.out.println("recording state: " + recording);
        }

        void setLimbOne() {                 
                this.jointID[0] = SimpleOpenNI.SKEL_LEFT_SHOULDER; //store the chosen joint parameters
                this.jointID[1] = SimpleOpenNI.SKEL_LEFT_ELBOW;
                this.jointID[2] = SimpleOpenNI.SKEL_LEFT_HAND;
        }

        void setLimbTwo() {                 
                this.jointID[0] = SimpleOpenNI.SKEL_RIGHT_SHOULDER; //store the chosen joint parameters
                this.jointID[1] = SimpleOpenNI.SKEL_RIGHT_ELBOW;
                this.jointID[2] = SimpleOpenNI.SKEL_RIGHT_HAND;
        }

        void setLimbThree() {                 
                this.jointID[0] = SimpleOpenNI.SKEL_LEFT_HIP; //store the chosen joint parameters
                this.jointID[1] = SimpleOpenNI.SKEL_LEFT_KNEE;
                this.jointID[2] = SimpleOpenNI.SKEL_LEFT_FOOT;
        }

        void setLimbFour() {                 
                this.jointID[0] = SimpleOpenNI.SKEL_RIGHT_HIP; //store the chosen joint parameters
                this.jointID[1] = SimpleOpenNI.SKEL_RIGHT_KNEE;
                this.jointID[2] = SimpleOpenNI.SKEL_RIGHT_FOOT;
        }

        void loadPressed() { //load default exercise
                String name = cp5.get(Textfield.class, "input").getText();
                readXML(name);
        }

        void savePressed() { //save the recorded exercise
                String name = cp5.get(Textfield.class, "input").getText();
                writeXML(name); //using this name
        }

        void readXML(String fileName) { //reads the xml docment of the given name
                currentFrame = 0;
                paused = true;
                framesGroup = null; //reset the current exercise data if ther is any
                //reuild the data structure for storing joint/frame info
                framesGroup = new ArrayList<ArrayList<PVector>>(3);
                framesOne = new ArrayList<PVector>();
                framesTwo = new ArrayList<PVector>();
                framesThree = new ArrayList<PVector>();

                framesGroup.add(framesOne);
                framesGroup.add(framesTwo);
                framesGroup.add(framesThree);

                //create the path that the file is to be read from using the given file name
                //String pathName = "C:\\Users\\David\\Documents\\Processing\\movementRecorderClass\\" + "xml-exercises\\" + fileName + ".xml";
                String pathName = sketchPath("xml-exercises") + "\\" + fileName  + ".xml";


                Document dom;
                // Make an  instance of the DocumentBuilderFactory
                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                try {
                        // use the factory to take an instance of the document builder
                        DocumentBuilder db = dbf.newDocumentBuilder();
                        // parse using the builder to get the DOM mapping of the XML file
                        dom = db.parse(pathName);
                        dom.getDocumentElement().normalize();
                        //get the joints nodes
                        NodeList joints = dom.getElementsByTagName("joint");

                        System.out.println("Root element :"  
                                + dom.getDocumentElement().getNodeName());

                        ////loop through each of the joint nodes
                        for (int i = 0; i < joints.getLength(); i++) {
                                Node joint = joints.item(i);
                                NodeList frames = joint.getChildNodes();
                                //loop through the frame nodes in each joint
                                for (int j = 0; j < frames.getLength(); j++) {
                                        Node frameNode = frames.item(j);
                                        Element frame = (Element) frameNode; 
                                        //retirve the data for x, y and z positions from each frame 
                                        framesGroup.get(i).add(new PVector(Integer.parseInt(frame.getAttribute("xpos").toString()), Integer.parseInt(frame.getAttribute("ypos")), Integer.parseInt(frame.getAttribute("zpos"))));
                                }
                        }

                        Element doc = dom.getDocumentElement();

                        currentFrame = 0; //reset the current frame to start the exercise from the begining
                        paused = false;
                        System.out.println(fileName + " loaded.");
                }
                catch (Exception e) {
                        e.printStackTrace();
                }
        }

        //this function is used to write out the recorded point data to an xml file
        public void writeXML(String fileName) { //writes xml file of given name
                try {
                        //create a path for the the exercise to be saved to 
                        //String pathName =  "C:\\Users\\David\\Documents\\Processing\\movementRecorderClass\\" + "xml-exercises\\" + fileName;
                        String pathName = sketchPath("xml-exercises") + "\\" + fileName + ".xml";
                        //create a new document object using the document builder object
                        DocumentBuilderFactory documentFactory = DocumentBuilderFactory
                                .newInstance();
                        DocumentBuilder documentBuilder = documentFactory
                                .newDocumentBuilder();

                        // define root elements for the document
                        Document document = documentBuilder.newDocument();
                        Element rootElement = document.createElement("exercise");
                        document.appendChild(rootElement); //add the root element to the ocument

                                //loop through the data for each joint
                        for (int j = 0; j < 3; j++) {
                                //create a joint element
                                Element joint = document.createElement("joint");
                                rootElement.appendChild(joint); //add it to the root element
                                //give the joint element an atribute, joint number and se its value
                                Attr jointNumber = document.createAttribute("jointnumber");
                                jointNumber.setValue(Integer.toString(j));
                                joint.setAttributeNode(jointNumber);

                                //for each joint loop through the data for each recorded frame
                                for (int i = 0; i < framesGroup.get(j).size(); i++) {
                                        //create a frame object and add it to its joint
                                        Element f = document.createElement("frame");
                                        joint.appendChild(f);

                                        //add the x,y and z attributes to joint object
                                        Attr xposition = document.createAttribute("xpos");
                                        xposition.setValue(Integer.toString((int)Math.round(framesGroup.get(j).get(i).x)));
                                        f.setAttributeNode(xposition);

                                        Attr yposition = document.createAttribute("ypos");
                                        yposition.setValue(Integer.toString((int)Math.round(framesGroup.get(j).get(i).y)));
                                        f.setAttributeNode(yposition);

                                        Attr zposition = document.createAttribute("zpos");
                                        zposition.setValue(Integer.toString((int)Math.round(framesGroup.get(j).get(i).z)));
                                        f.setAttributeNode(zposition);
                                }
                        }

                        // creating and write to xml file using the created values
                        TransformerFactory transformerFactory = TransformerFactory
                                .newInstance();
                        Transformer transformer = transformerFactory.newTransformer();
                        DOMSource domSource = new DOMSource(document);
                        StreamResult streamResult = new StreamResult(new File(pathName));

                        transformer.transform(domSource, streamResult);

                        //reset the current frame so the exercise starts from the begining
                        currentFrame = 0;

                        System.out.println(fileName + " saved to specified path!");
                } 
                catch (ParserConfigurationException pce) {
                        pce.printStackTrace();
                } 
                catch (TransformerException tfe) {  
                        tfe.printStackTrace();
                }
        }

        //this function is used to remove the UI elemts for this screen
        void destroy() {                
                for ( int i = 0 ; i < buttons.length ; i++ ) { //loop through the buttons
                        buttons[i].remove(); //remove them
                        buttons[i] = null;
                }

                cp5.getGroup("exerciseGroup2").remove(); //remove the Cp5 groupd
                cp5.getGroup("radioButton").remove(); //remove the Cp5 groupd
                message.destroy(); //destroy the message display objects                
                directionMessage.destroy();
                continueMessage.destroy();
                //System.gc();
        }
}

