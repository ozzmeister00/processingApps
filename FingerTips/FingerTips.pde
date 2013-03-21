/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
//Updated to Beta3
import intel.pcsdk.*;


boolean fingerTracking = true;
PImage display;
PXCUPipeline session;

void setup() {
  size(640, 480);
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.GESTURE)) {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }

  //int[] lm_size=session.QueryDepthMapSize(); //old code
   int[] lm_size= new int[2];
   session.QueryDepthMapSize(lm_size);
  if (lm_size!=null)
  {
    print("LabelMapSize("+lm_size[0]+","+lm_size[1]+")\n");
    display=createImage(lm_size[0], lm_size[1], RGB);


    //int[] uv_size=session.QueryUVMapSize();/old code
    int[] uv_size=new int[2];
    session.QueryUVMapSize(uv_size);
    if (uv_size!=null) print("UVMapSize("+uv_size[0]+","+uv_size[1]+")\n");
  }
}

void draw() { 
  background(0);

  if (session.AcquireFrame(true)) {
    session.QueryLabelMapAsImage(display);

    image(display, 0, 0, 640, 480);

      //FINGER TRACKING
    if (fingerTracking) { 
 

      //Hand 1, first hand detected, left or right specific
      PXCMGesture.GeoNode hand1Thumb=new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB, hand1Thumb);
      PXCMGesture.GeoNode hand1Index = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX, hand1Index);
      PXCMGesture.GeoNode hand1Middle = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE, hand1Middle);
      PXCMGesture.GeoNode hand1Ring = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING, hand1Ring);
      PXCMGesture.GeoNode hand1Pinky = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY, hand1Pinky);

      //Hand 2, second hand detected
      PXCMGesture.GeoNode hand2Thumb = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB, hand2Thumb);
      PXCMGesture.GeoNode hand2Index = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX, hand2Index);
      PXCMGesture.GeoNode hand2Middle = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE, hand2Middle);
      PXCMGesture.GeoNode hand2Ring = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING, hand2Ring);
      PXCMGesture.GeoNode hand2Pinky = new PXCMGesture.GeoNode();
      session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY, hand2Pinky);



      //Scale tracked points
    pushMatrix();
    scale(2); //make everything twice as large
   
      //Drawing the fingertips on screen
      fill(255,0,0);
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
      
      popMatrix();
    }
  

    session.ReleaseFrame();
  }
}
