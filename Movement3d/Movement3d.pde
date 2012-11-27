/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
import intel.pcsdk.*;
private static int mode=PXCUPipeline.PXCU_PIPELINE_GESTURE;


//comment this out if running Processing 2
import processing.opengl.*;
//----------------------------------------


boolean hand1Open, hand2Open = false;
PVector camPos, camRot;
PVector hand1Point, hand2Point, phand1Point, phand2Point;
PVector grabPoint1, grabPoint2;
PVector lasthand1, lasthand2;

int openThreshhold = 15;
PImage display;

int hand1FingerCount, hand2FingerCount = 0;
float movementAmt = 5000;


void setup() {
  size(1000, 700, OPENGL);

  if (!PXCUPipeline.Init(mode)) {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }

  if ((mode&PXCUPipeline.PXCU_PIPELINE_GESTURE)!=0) {
    int[] lm_size=PXCUPipeline.QueryDepthMapSize();//QueryLabelMapSize();
    if (lm_size!=null) {
      print("LabelMapSize("+lm_size[0]+","+lm_size[1]+")\n");
      display=createImage(lm_size[0], lm_size[1], RGB);
    }

    int[] uv_size=PXCUPipeline.QueryUVMapSize();
    if (uv_size!=null) print("UVMapSize("+uv_size[0]+","+uv_size[1]+")\n");
  }
  camPos = new PVector(0, 0, 0);
  camRot = new PVector(0, 0, 0);
  hand1Point = new PVector(0, 0, 0);
  hand2Point = new PVector(0, 0, 0);
  phand1Point = new PVector(0, 0, 0);
  phand2Point = new PVector(0, 0, 0);
  lasthand1 =  new PVector(0.0,0.0,0.0);
  lasthand2 =  new PVector(0.0,0.0,0.0);
      
}

void draw() { 
  background(0);

println(openThreshhold);
  if (PXCUPipeline.AcquireFrame(true)) {
    PXCUPipeline.QueryLabelMapAsImage(display);



    //FINGER TRACKING

    //Hand 1, first hand detected, left or right specific
    PXCMGesture.GeoNode hand1Thumb = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB);
    PXCMGesture.GeoNode hand1Index = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX);
    PXCMGesture.GeoNode hand1Middle = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE);
    PXCMGesture.GeoNode hand1Ring = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING);
    PXCMGesture.GeoNode hand1Pinky = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY);

    //Hand 2, second hand detected
    PXCMGesture.GeoNode hand2Thumb = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB);
    PXCMGesture.GeoNode hand2Index = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX);
    PXCMGesture.GeoNode hand2Middle = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE);
    PXCMGesture.GeoNode hand2Ring = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING);
    PXCMGesture.GeoNode hand2Pinky = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY);

    // Hand openness
    PXCMGesture.GeoNode hand1 = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY);
    PXCMGesture.GeoNode hand2 = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY);


    //Finger counting
    hand1FingerCount = 0;
    hand2FingerCount = 0;
    if (hand1Thumb != null) hand1FingerCount++; 
    if (hand1Index != null) hand1FingerCount++; 
    if (hand1Middle != null) hand1FingerCount++; 
    if (hand1Ring != null) hand1FingerCount++; 
    if (hand1Pinky != null) hand1FingerCount++; 

    if (hand2Thumb != null) hand2FingerCount++; 
    if (hand2Index != null) hand2FingerCount++; 
    if (hand2Middle != null) hand2FingerCount++; 
    if (hand2Ring != null) hand2FingerCount++; 
    if (hand2Pinky != null) hand2FingerCount++; 


    //Scale tracked points
    pushMatrix();
    camera();
    fill(255, 0, 0, 100);
    PVector range = new PVector(0.2, 0.15, 0.1);
    
    //Checking Hand1 to see if it's open and on screen
    if (hand1 != null) {
      if (hand1.openness > openThreshhold || hand1Open) {
        fill(0, 255, 50, 200);
      } 
      else {
        fill(255, 50, 50, 200);
      }
      
      ellipse(map(hand1.positionWorld.x, range.x, -range.x, 0, width), map(hand1.positionWorld.z, range.y, -range.y, 0, height), map(hand1.positionWorld.y, -range.z, range.z, 1, 50), map(hand1.positionWorld.y, -range.z, range.z, 1, 50));
     
     
      if (hand1.openness > openThreshhold) {
        hand1Open = true;
      } 
      else {
        hand1Open = false;
      }
      
      
    if(hand1.positionWorld.x > range.x || hand1.positionWorld.x < -range.x ) hand1Open = true;

    }
    else {
      hand1Open = true;
    }
    
    
    
    
    //Checking Hand2 to see if it's open and on screen
    if (hand2!= null) {  
      //Check to see if hand is open or not, color cursor accordingly
      if (hand2.openness > openThreshhold) {
        fill(0, 255, 50, 200);
      } 
      else {
        fill(255, 50, 50, 200);
      }
      ellipse(map(hand2.positionWorld.x, range.x, -range.x, 0, width), map(hand2.positionWorld.z, range.y, -range.y, 0, height), map(hand2.positionWorld.y, -range.z, range.z, 1, 50), map(hand2.positionWorld.y, -range.z, range.z, 1, 50));
     
      if (hand2.openness > openThreshhold) {
        hand2Open = true;
      } 
      else {
        hand2Open = false;
      }

      if(hand2.positionWorld.x > range.x || hand2.positionWorld.x < -range.x) hand2Open = true;
  
  }
    else {
      hand2Open = true;
    }

    //Double checking to see if the hands are open
    if (hand1FingerCount > 1) hand1Open= true;
    if (hand2FingerCount > 1) hand2Open= true;
    
      



    //Hand1 Tracking
    if (hand1 != null) {
      hand1Point = new PVector(hand1.positionWorld.x*movementAmt, hand1.positionWorld.z*movementAmt, hand1.positionWorld.y*-movementAmt);
    }

    if (!hand1Open && grabPoint1 ==null && hand2Open) {
      grabPoint1 = hand1Point;
    }
    if (!hand1Open && hand2Open) { //if (!hand1Open ) {
      camPos.x += (hand1.positionWorld.x*movementAmt)-grabPoint1.x;
      camPos.y += (hand1.positionWorld.z*movementAmt)-grabPoint1.y;
      camPos.z += (hand1.positionWorld.y*-movementAmt)-grabPoint1.z;

      grabPoint1 =  hand1Point;
    }
    if (hand1Open) {
      grabPoint1 = null;
    }
    
    //Hand2 Tracking
        if (hand2 != null) {
      hand2Point = new PVector(hand2.positionWorld.x*movementAmt, hand2.positionWorld.z*movementAmt, hand2.positionWorld.y*-movementAmt);
    }

    if (!hand2Open && grabPoint2 ==null && hand1Open) {
      grabPoint2 = hand2Point;
    }
    if (!hand2Open && hand1Open) {
      camPos.x += (hand2.positionWorld.x*movementAmt)-grabPoint2.x;
      camPos.y += (hand2.positionWorld.z*movementAmt)-grabPoint2.y;
      camPos.z += (hand2.positionWorld.y*-movementAmt)-grabPoint2.z;

      grabPoint2 =  hand2Point;
    }
    if (hand2Open) {
      grabPoint2 = null;
    }
    





//Both Hand Rotation Tracking
        if (hand1 != null && hand2 !=null) {
      hand1Point = new PVector(hand1.positionWorld.x*movementAmt, hand1.positionWorld.z*movementAmt, hand1.positionWorld.y*-movementAmt);
      hand2Point = new PVector(hand2.positionWorld.x*movementAmt, hand2.positionWorld.z*movementAmt, hand2.positionWorld.y*-movementAmt);
 
    }

    if (!hand2Open && grabPoint2 ==null && !hand1Open && grabPoint1 ==null) {
      grabPoint1 = hand1Point;
      grabPoint2 = hand2Point;
    }
    
    if (!hand2Open && !hand1Open && hand1 != null && hand2 !=null) {


      //change rotation of camera
    //  float whatever = (hand1.positionWorld.x*movementAmt);
   //   println((hand1.positionWorld.x*movementAmt)-grabPoint1.x);
      /*
      lasthand1.x += (hand1.positionWorld.x*movementAmt)-grabPoint1.x;
      lasthand1.y += (hand1.positionWorld.z*movementAmt)-grabPoint1.y;
      lasthand1.z += (hand1.positionWorld.y*-movementAmt)-grabPoint1.z;
      
      lasthand2.x += (hand2.positionWorld.x*movementAmt)-grabPoint2.x;
      lasthand2.y += (hand2.positionWorld.z*movementAmt)-grabPoint2.y;
      lasthand2.z += (hand2.positionWorld.y*-movementAmt)-grabPoint2.z;
      */
       //     camRot.x = mouseX;
     // camRot.y += ((hand2.positionWorld.z*movementAmt)-grabPoint2.z)-((hand1.positionWorld.z*movementAmt)-grabPoint1.z);
      //camRot.z += ((hand2.positionWorld.y*movementAmt)-grabPoint2.y)-((hand1.positionWorld.y*movementAmt)-grabPoint1.y);


      grabPoint1 =  hand1Point;
      grabPoint2 =  hand2Point;
    }
    if (hand1Open && hand2Open) {
      grabPoint1 = null;
      grabPoint2 = null;
    }


    /*
      //Drawing the fingertips on screen
     fill(255, 0, 0);
     if (hand1Thumb!=null) {
     ellipse(hand1Thumb.positionImage.x, hand1Thumb.positionImage.y, 5, 5);
     text("   thumb", hand1Thumb.positionImage.x, hand1Thumb.positionImage.y);
     }
     
     if (hand1Index!=null) {
     ellipse(hand1Index.positionImage.x, hand1Index.positionImage.y, 5, 5);
     text("   index", hand1Index.positionImage.x, hand1Index.positionImage.y);
     }
     
     if (hand1Middle!=null) {
     ellipse(hand1Middle.positionImage.x, hand1Middle.positionImage.y, 5, 5);
     text("   middle", hand1Middle.positionImage.x, hand1Middle.positionImage.y);
     }
     
     if (hand1Ring!=null) {
     ellipse(hand1Ring.positionImage.x, hand1Ring.positionImage.y, 5, 5);
     text("   ring", hand1Ring.positionImage.x, hand1Ring.positionImage.y);
     }
     
     if (hand1Pinky!=null) {
     ellipse(hand1Pinky.positionImage.x, hand1Pinky.positionImage.y, 5, 5);
     text("   pinky", hand1Pinky.positionImage.x, hand1Pinky.positionImage.y);
     }
     
     //Hand2
     if (hand2Thumb!=null) {
     ellipse(hand2Thumb.positionImage.x, hand2Thumb.positionImage.y, 5, 5);
     text("   thumb", hand2Thumb.positionImage.x, hand2Thumb.positionImage.y);
     }
     
     if (hand2Index!=null) {
     ellipse(hand2Index.positionImage.x, hand2Index.positionImage.y, 5, 5);
     text("   index", hand2Index.positionImage.x, hand2Index.positionImage.y);
     }
     
     if (hand2Middle!=null) {
     ellipse(hand2Middle.positionImage.x, hand2Middle.positionImage.y, 5, 5);
     text("   middle", hand2Middle.positionImage.x, hand2Middle.positionImage.y);
     }
     
     if (hand2Ring!=null) {
     ellipse(hand2Ring.positionImage.x, hand2Ring.positionImage.y, 5, 5);
     text("   ring", hand2Ring.positionImage.x, hand2Ring.positionImage.y);
     }
     
     if (hand2Pinky!=null) {
     ellipse(hand2Pinky.positionImage.x, hand2Pinky.positionImage.y, 5, 5);
     text("   pinky", hand2Pinky.positionImage.x, hand2Pinky.positionImage.y);
     }
     */
    popMatrix();




    PXCUPipeline.ReleaseFrame();
  }
  pushMatrix();
  beginCamera();
  camera();
  translate(camPos.x, camPos.y, camPos.z);
  rotate(degrees(camRot.x));
  endCamera();

int boxSpacing = 300;

  for (int x =0;x< 10;x++) {
    for (int y =0;y< 10;y++) {
      for (int z =0;z< 10;z++) {
        fill(x*25, y*25, 255-(z*25), 200);
        pushMatrix();
        translate(x*boxSpacing, y*boxSpacing, z*-boxSpacing);
        box(45);
        popMatrix();
      }
    }
  }


  popMatrix();
  
      pushMatrix();
    camera();
    image(display, 0, 0, 160, 120);
    popMatrix();
}

void exit()
{
  PXCUPipeline.Close(); 
  super.exit();
}

