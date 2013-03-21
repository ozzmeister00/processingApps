/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
//Updated for Beta3
import processing.core.*;
import intel.pcsdk.*;


PXCUPipeline perc;
private static int mode=PXCUPipeline.GESTURE;

PImage depthImg;
PImage mapImg;
int depthW=320, depthH=240;
short[] depthData;

Hand rightHand, leftHand;

// for the object
float objX, objY;
float objZoom = 1.0;
float objRot = 0.0;
float rotX=0.0, rotY=0.0;  // what's the center point of rotation?


void setup() {
  size(1200, 800, P2D);

  perc = new PXCUPipeline(this);
  if (!perc.Init(PXCUPipeline.GESTURE)) {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }

  int[] depth_size= new int[2];
    perc.QueryDepthMapSize(depth_size);
  if (depth_size!=null) {
    depthW = depth_size[0];
    depthH = depth_size[1];
    depthData = new short[depthW*depthH];
  }

  // for the depth image...
  depthImg=createImage(depthW, depthH, RGB);

  mapImg = loadImage("map3.jpg");

  // create our pre-built graphics elements
  resetScene();

  rightHand = new Hand(perc);
  leftHand = new Hand(perc);
}


void resetScene()
{
  objX = width/2.0;
  objY = height/2.0;
  objZoom = 1.0;
  objRot = 0.0;
}


void keyPressed() {
  if (key == 'r')
    resetScene();
}


void draw() { 
  background(40);

  // get hand position
  if (perc.AcquireFrame(true)) {
    readHandPos();
    perc.ReleaseFrame();
  }

  // draw the objects on the screen
  drawObjects();

  // draw the hands
  rightHand.display();
  leftHand.display();

  drawDebugFeedback();
}


void readHandPos()
{
  
  rightHand.updateHand(PXCMGesture.GeoNode.LABEL_BODY_HAND_RIGHT);
  leftHand.updateHand(PXCMGesture.GeoNode.LABEL_BODY_HAND_LEFT);
}


void drawObjects()
{

  // zoom and rotate
  if (rightHand.visible && rightHand.isClosed() && leftHand.visible && leftHand.isClosed())
  {
    // find the vectors for the previous two hand positions and the current two hand positions
    PVector currDist = PVector.sub(rightHand.screenCoords, leftHand.screenCoords);
    PVector prevDist = PVector.sub(rightHand.prevScreenCoords, leftHand.prevScreenCoords);

    // now calculate the zoom based on the change in the distance between the two hands
    objZoom = objZoom * map(currDist.mag()-prevDist.mag(), -60, 60, 0.9, 1.1); // increments...
    objZoom = constrain(objZoom, 0.1, 5.0);  // just so that we don't go crazy with zoom and invert the object by accident

    // calculate rotation amount as the angle between the previous and current vectors between the two hands
    float currRot = PVector.angleBetween(currDist, prevDist);
    if (currDist.heading2D() < prevDist.heading2D()) // reverse the rotation because angleBetween only returns absolute angle values
      currRot *= -1;
    objRot += currRot;

    // always rotate around the centerpoint between two hands... this will appear most natural
    rotX = min(rightHand.screenCoords.x, leftHand.screenCoords.x) + abs(rightHand.screenCoords.x - leftHand.screenCoords.x)/2;
    rotY = min(rightHand.screenCoords.y, leftHand.screenCoords.y) + abs(rightHand.screenCoords.y - leftHand.screenCoords.y)/2;
  }

  // drag/pan
  else if (rightHand.visible && rightHand.isClosed())
  {
    float dx = rightHand.screenCoords.x - rightHand.prevScreenCoords.x;
    float dy = rightHand.screenCoords.y - rightHand.prevScreenCoords.y;
    float c = cos(-objRot)/objZoom, s = sin(-objRot)/objZoom;
    objX += dx*c - dy*s;
    objY += dx*s + dy*c;
  }

  else if (leftHand.visible && leftHand.isClosed())
  {
    float dx = leftHand.screenCoords.x - leftHand.prevScreenCoords.x;
    float dy = leftHand.screenCoords.y - leftHand.prevScreenCoords.y;
    float c = cos(-objRot)/objZoom, s = sin(-objRot)/objZoom;
    objX += dx*c - dy*s;
    objY += dx*s + dy*c;
  }

  // finally, draw our object (map) in the correct position/orientation
  imageMode(CENTER);

  pushMatrix();
  tint(255);

  // rotate the object around the centerpoint between the two hands
  translate(rotX, rotY);
  scale(objZoom);
  rotate(objRot);
  translate(-rotX, -rotY);	
  translate(objX, objY);

  image(mapImg, 0, 0);
  popMatrix();
  imageMode(CORNER);


  //draw the line connecting the two hands
  if (rightHand.visible && rightHand.isClosed() && leftHand.visible && leftHand.isClosed())
  {
    stroke(255);
    noFill();
    ellipse(rotX, rotY, 40, 40);

    // draw a line connecting the two hand locations
    stroke(200, 50, 50, 150);
    strokeWeight(3);
    line(rightHand.screenCoords.x, rightHand.screenCoords.y, leftHand.screenCoords.x, leftHand.screenCoords.y);
  }
}


void drawDebugFeedback()
{
  pushMatrix();

  // first draw the label map image
  perc.QueryLabelMapAsImage(depthImg);
  tint(255);
  translate(width, height-depthH);
  scale(-1, 1);   // mirror the image
  image(depthImg, 0, 0, depthW, depthH);

  // draw where the hands are
  noStroke();
  fill(255, 0, 0);
  if (rightHand.visible)
    ellipse(rightHand.depthCoords.x, rightHand.depthCoords.y, 5, 5);
  if (leftHand.visible)
    ellipse(leftHand.depthCoords.x, leftHand.depthCoords.y, 5, 5);

  popMatrix();
}

