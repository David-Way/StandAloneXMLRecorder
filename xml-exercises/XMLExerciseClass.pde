import java.util.ArrayList;
import java.io.File;
import processing.opengl.*;
import SimpleOpenNI.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;
import org.xml.sax.*;
import org.w3c.dom.*;

import java.util.ArrayList;

import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;        

import javax.xml.transform.stream.*;
import org.xml.sax.*;
import org.w3c.dom.*;

import java.io.File;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

class XMLExerciseClass {

        SimpleOpenNI context;
        int [] jointID;
        int userID;
        ArrayList<ArrayList<PVector>> framesGroup = new ArrayList<ArrayList<PVector>>(4);
        ArrayList<PVector> framesOne;
        ArrayList<PVector> framesTwo;
        ArrayList<PVector> framesThree;
        ArrayList<PVector> framesCenter;
        float c = 0.0;
        float offByDistance = 0.0;
        int currentFrame = 0;
        int numberofFrames = 0;
        boolean paused = false;
        boolean recording = false;

        XMLExerciseClass(SimpleOpenNI tempContext, int tempJointIDOne, int tempJointIDTwo, int tempJointIDThree) {
                //initilise required variables 
                jointID = new int[3]; //holds the selected joints 
                context = tempContext; 
                jointID[0] = tempJointIDOne; //store the chosen joint parameters
                jointID[1] = tempJointIDTwo;
                jointID[2] = tempJointIDThree;
                framesOne = new ArrayList<PVector>(); //create arrays to store each joints point data for each frame
                framesTwo = new ArrayList<PVector>();
                framesThree = new ArrayList<PVector>();
                framesCenter = new ArrayList<PVector>();
                framesGroup.add(framesOne); //add these arrays to a group array
                framesGroup.add(framesTwo);
                framesGroup.add(framesThree);
                framesGroup.add(framesCenter);
        }

        void drawUI(boolean drawHUD) {
                kinect.update();

                if (drawHUD) {
                        drawHeadsUpDisplay();
                }
                pushMatrix();
                lights(); 
                noStroke();

                translate(width/2, height/2, 0);
                rotateX(radians(180));
                // rotateY(radians(180));

                IntVector userList = new IntVector();

                kinect.getUsers(userList);

                if (userList.size() > 0) {
                        int userId = userList.get(0);
                        setUser(userId);
                        if ( kinect.isTrackingSkeleton(userId)) {

                                //draw screen
                                /*pushMatrix();
                                 fill(123, 123, 123, 55);
                                 translate(0, 0, 0);
                                 rect(0, 0, 640, 480);
                                 popMatrix();*/

                                PVector currentPosition = new PVector();
                                kinect.getJointPositionSkeleton(userId, 
                                SimpleOpenNI.SKEL_LEFT_HAND, 
                                currentPosition);

                                PVector currentCenter = new PVector();
                                kinect.getJointPositionSkeleton(userId, 
                                SimpleOpenNI.SKEL_TORSO, 
                                currentCenter);
                                // display the sphere for the current limb position
                                pushMatrix();

                                fill(255, 0, 0);
                                translate(currentCenter.x, currentCenter.y, currentCenter.z);
                                sphere(20); 

                                popMatrix();

                                // if we're recording tell the recorder to capture this frame
                                if (recording) { 
                                        recordFrame();
                                } 
                                else { 
                                        // if we're playing access the recorded joint position
                                        //ArrayList<PVector> recordedPositions = getPositions();
                                        ArrayList<PVector> recordedPositions = getAdjustedPositions(currentCenter);

                                        // display the recorded joint position
                                        noStroke();

                                        for (int k = 0; k < 4; k++) {
                                                pushMatrix();
                                                noFill();
                                                stroke(c, 255-c, 0); 
                                                strokeWeight(4);
                                                //translate(0,0,0);
                                                if (k != 4) {
                                                        translate(recordedPositions.get(k).x, recordedPositions.get(k).y, recordedPositions.get(k).z);
                                                } 
                                                else {
                                                        translate(recordedPositions.get(k).x, recordedPositions.get(k).y, currentPosition.z);
                                                }

                                                //translate(recordedPositions.get(3).x + recordedPositions.get(k).x, recordedPositions.get(3).y + recordedPositions.get(k).y, recordedPositions.get(3).z + recordedPositions.get(k).z);
                                                //translate(recordedPositions.get(k).x, recordedPositions.get(k).y, recordedPositions.get(k).z);
                                                //sphere(80);
                                                translate(-25, -25, 0);
                                                ellipse(0, 0, 50, 50);

                                                popMatrix();
                                        }

                                        // draw a line between the current position and the recorded one
                                        // set its color based on the distance between the two
                                        stroke(c, 255-c, 0); 
                                        strokeWeight(20);
                                        line(currentPosition.x, currentPosition.y, 
                                        currentPosition.z, recordedPositions.get(0).x, 
                                        recordedPositions.get(0).y, recordedPositions.get(0).z);
                                        // calculate the vector between the current and recorded positions
                                        // with vector subtraction
                                        currentPosition.sub(recordedPositions.get(0));

                                        drawSkeleton(userId, currentPosition); 
                                        // store the magnitude of that vector as
                                        // the off-by distance for display
                                        offByDistance = currentPosition.mag(); 


                                        // tell the recorder to load up the next frame if close
                                        if (offByDistance < 200) {
                                                nextFrame();
                                        }
                                }
                        }
                }

                popMatrix();
        }

        void drawHeadsUpDisplay() {
                pushMatrix();
                // create hud
                fill(255);
                text("totalFrames: " + framesGroup.get(0).size(), 5, 10);
                text("recording: " + recording, 5, 24);
                text("currentFrame: " + currentFrame, 5, 38 );

                // set text color as a gradient from red to green
                // based on distance between hands
                c = map(offByDistance, 0, 1000, 0, 255); 
                fill(c, 255-c, 0);
                text("joint 1 off by: " + offByDistance, 5, 52);
                popMatrix();
        }

        void setUser(int tempUserID) { 
                userID = tempUserID;
        }

        void setCurrentFrame(int newFrame) {
                currentFrame = newFrame;
        }
        void recordFrame() {
                //record the positions of the 3 chosen joints
                PVector position = new PVector(); 
                PVector storedTorso = new PVector();

                //record the torso joint position
                context.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, storedTorso);
                framesGroup.get(3).add(storedTorso);

                for (int i = 0; i < 3; i++) {                        
                        context.getJointPositionSkeleton(userID, jointID[i], position);
                        //position.sub(storedTorso);
                        storedTorso.sub(position);
                        framesGroup.get(i).add(position);
                        position = new PVector();
                }

                position = new PVector();
        }

        PVector getPosition(int joint) {
                return framesGroup.get(joint).get(currentFrame);
        }

        ArrayList<PVector> getPositions() {
                ArrayList<PVector> p = new ArrayList<PVector>();
                for (int i = 0; i < 4; i++) {                        
                        p.add(framesGroup.get(i).get(currentFrame));
                }
                return p;
        }

        ArrayList<PVector> getAdjustedPositions(PVector currentCenterPosition) {
                ArrayList<PVector> p = new ArrayList<PVector>();
                for (int i = 0; i < 4; i++) {
                        PVector temp = framesGroup.get(i).get(currentFrame);
                        if (i != 3) {
                                temp.z  = currentCenterPosition.z;
                        }
                        p.add(temp);
                }
                return p;
        }

        ArrayList<PVector> getAdjustedPositionsShoulder(PVector currentSholderPosition) {
                ArrayList<PVector> p = new ArrayList<PVector>();
                for (int i = 0; i < 4; i++) {
                        PVector temp = framesGroup.get(i).get(currentFrame);
                        if (i != 3) {
                                temp.z  = currentCenterPosition.z;
                        }
                        p.add(temp);
                }
                return p;
        }

        void nextFrame() { 
                if (!paused) {
                        currentFrame++;
                        if (currentFrame == framesGroup.get(0).size()) { 
                                currentFrame = 0;
                        }
                }
        }

        void readXML(String fname) {
                paused = true;
                framesGroup = null;
                framesGroup = new ArrayList<ArrayList<PVector>>(4);
                framesOne = new ArrayList<PVector>();
                framesTwo = new ArrayList<PVector>();
                framesThree = new ArrayList<PVector>();
                framesCenter = new ArrayList<PVector>();

                framesGroup.add(framesOne);
                framesGroup.add(framesTwo);
                framesGroup.add(framesThree);
                framesGroup.add(framesCenter);
                String pathName = "C:\\Users\\David\\Documents\\Processing\\movementRecorderXML3Joints\\" + "xml-exercises\\" + fname;


                Document dom;
                // Make an  instance of the DocumentBuilderFactory
                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                try {
                        // use the factory to take an instance of the document builder
                        DocumentBuilder db = dbf.newDocumentBuilder();
                        // parse using the builder to get the DOM mapping of the    
                        // XML file
                        dom = db.parse(pathName);
                        dom.getDocumentElement().normalize();
                        NodeList joints = dom.getElementsByTagName("joint");

                        System.out.println("Root element :"  
                                + dom.getDocumentElement().getNodeName());

                        for (int i = 0; i < joints.getLength(); i++) {

                                Node joint = joints.item(i);
                                NodeList frames = joint.getChildNodes();
                                for (int j = 0; j < frames.getLength(); j++) {
                                        Node frameNode = frames.item(j);
                                        Element frame = (Element) frameNode; 
                                        framesGroup.get(i).add(new PVector(Integer.parseInt(frame.getAttribute("xpos").toString()), Integer.parseInt(frame.getAttribute("ypos")), Integer.parseInt(frame.getAttribute("zpos"))));
                                }
                        }

                        Element doc = dom.getDocumentElement();

                        currentFrame = 0;
                        paused = false;
                }
                catch (Exception e) {
                        e.printStackTrace();
                }
        }


        public void writeXML(String fileName) {
                try {
                        String pathName =  "C:\\Users\\David\\Documents\\Processing\\movementRecorderXML3Joints\\" + "xml-exercises\\" + fileName;
                        DocumentBuilderFactory documentFactory = DocumentBuilderFactory
                                .newInstance();
                        DocumentBuilder documentBuilder = documentFactory
                                .newDocumentBuilder();

                        // define root elements
                        Document document = documentBuilder.newDocument();
                        Element rootElement = document.createElement("exercise");
                        document.appendChild(rootElement);

                        for (int j = 0; j < 4; j++) {
                                Element joint = document.createElement("joint");
                                rootElement.appendChild(joint);
                                Attr jointNumber = document.createAttribute("jointnumber");
                                jointNumber.setValue(Integer.toString(j));
                                joint.setAttributeNode(jointNumber);

                                for (int i = 0; i < framesGroup.get(j).size(); i++) {

                                        Element f = document.createElement("frame");
                                        joint.appendChild(f);

                                        // add attributes to school
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

                        // creating and writing to xml file
                        TransformerFactory transformerFactory = TransformerFactory
                                .newInstance();
                        Transformer transformer = transformerFactory.newTransformer();
                        DOMSource domSource = new DOMSource(document);
                        StreamResult streamResult = new StreamResult(new File(pathName));

                        transformer.transform(domSource, streamResult);


                        currentFrame = 0;

                        System.out.println("File saved to specified path!");
                } 
                catch (ParserConfigurationException pce) {
                        pce.printStackTrace();
                } 
                catch (TransformerException tfe) {  
                        tfe.printStackTrace();
                }
        }

        void toggleRecording() {
                recording = !recording;
                System.out.println("recording state: " + recording);
        }

        void loadPressed() {
                readXML("left-arm-three-joint.xml");
        }

        void savePressed() {
                writeXML("left-arm-three-joint.xml");
        }

        // draw the skeleton with the selected joints
        void drawSkeleton(int userId, PVector cC)
        {
                pushMatrix();


                //rotateX(radians(180));
                stroke(0, 0, 255);
                strokeWeight(3);
                // to get the 3d joint data
                PVector chest = new PVector();
                kinect.getJointPositionSkeleton(userId, 
                SimpleOpenNI.SKEL_TORSO, 
                chest);
                fill(222, 222, 0);
                // translate(chest.x, chest.y, chest.z);
                rotateX(radians(-180));
                text(chest.x + " " + chest.y + " " + chest.z);
                //translate(cC.x, cC.y, cC.z);
                translate(-320, -240, 0);

                //translate(0, 0, 0);
                //translate(-(width/2), -(height/2), 0);
                fill(133, 10);
                //rect(0, 0, 640, 480);

                kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

                kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

                kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

                kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

                kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

                kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
                kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);

                popMatrix();
        }
}

