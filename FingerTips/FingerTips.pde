/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
import intel.pcsdk.*;


private static int mode=PXCUPipeline.PXCU_PIPELINE_GESTURE;
boolean fingerTracking = true;
PImage display;
PXCUPipeline session;

void setup() {
  size(640, 480);
  session = new PXCUPipeline(this);
  if (!session.Init(mode)) {
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
}

void draw() { 
  background(0);

  if (PXCUPipeline.AcquireFrame(true)) {
    PXCUPipeline.QueryLabelMapAsImage(display);

    image(display, 0, 0, 640, 480);

      //FINGER TRACKING
    if (fingerTracking) { 

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
  

    PXCUPipeline.ReleaseFrame();
  }
}


void exit()
{
  PXCUPipeline.Close(); 
  super.exit();
}
