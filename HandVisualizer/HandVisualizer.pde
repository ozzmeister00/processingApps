/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
import intel.pcsdk.*;

boolean fingerTracking = true;
boolean handTracking = true;
short[] depthMap;
short[] irMap;
int[] depth_size;
int[] ir_size;
int[] uv_size;
float[] uvMap;
private static PImage display, rgbImage, depthImage, irImage, uvImage;
PXCUPipeline session;

void setup() {
  size(640, 480);
  session = new PXCUPipeline(this);

  if (!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.COLOR_VGA|PXCUPipeline.DEPTH_QVGA))
  {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }

  int[] lm_size=session.QueryDepthMapSize();//QueryLabelMapSize();
  if (lm_size!=null) {
    print("LabelMapSize("+lm_size[0]+","+lm_size[1]+")\n");
    display=createImage(lm_size[0], lm_size[1], RGB);
  }

  int[] uv_size=session.QueryUVMapSize();
  if (uv_size!=null) print("UVMapSize("+uv_size[0]+","+uv_size[1]+")\n");

  int[] rgb_size=session.QueryRGBSize();
  println("querying RGBSize");
  if (rgb_size!=null) {
    print("RGBSize("+rgb_size[0]+","+rgb_size[1]+")\n");
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);
  }

  depth_size=session.QueryDepthMapSize();
  println("querying DepthSize");
  if (depth_size!=null) {
    print("DepthSize("+depth_size[0]+","+depth_size[1]+")\n");

    depthMap = new short[depth_size[0] * depth_size[1]];

    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }

  ir_size=session.QueryIRMapSize();
  println("querying IRSize");
  if (ir_size!=null) {
    print("IR Size("+ir_size[0]+","+ir_size[1]+")\n");

    irMap = new short[ir_size[0] * ir_size[1]];
    irImage=createImage(ir_size[0], ir_size[1], ALPHA);
  }

  uv_size=session.QueryUVMapSize();
  println("querying UVSize");
  if (uv_size!=null) {
    print("UV Size("+uv_size[0]+","+uv_size[1]+")\n");

    uvMap = new float[uv_size[0] * uv_size[1]*4];

    uvImage=createImage(uv_size[0], uv_size[1], ARGB);
  }
}

void draw() { 
  background(0);

  if (session.AcquireFrame(true)) { //if this is set to false it flashes
    float[] acc=new float[3];
    session.QueryDeviceProperty(PXCMCapture.Device.PROPERTY_ACCELEROMETER_READING, acc);

    if (session.QueryLabelMapAsImage(display)) image(display, 0, 0);
    if (session.QueryRGB(rgbImage)) image(rgbImage, 320, 0, 320, 240);


    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    session.QueryDepthMap(depthMap);
    depthImage.loadPixels();
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++) {
      depthImage.pixels[i] = color(map(depthMap[i], 0, 4000, 0, 255));
    }
    depthImage.updatePixels();
    image(depthImage, 0, 240, 320, 240);


    //REMAPPING THE IR IMAGE TO A PIMAGE
    session.QueryIRMap(irMap);
    irImage.loadPixels();
    for (int i = 0; i < ir_size[0]*ir_size[1]; i++) {
      irImage.pixels[i] = color(map(irMap[i], 0, 4000, 0, 255));
    }
    irImage.updatePixels();
    image(irImage, 320, 240, 320, 240);


    //maskDetails
    PXCMGesture.GeoNode hand1MaskDetails = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_MASK_DETAILS);
    if (hand1MaskDetails!=null) {

      pushStyle();
      fill(255, 0, 0);
      ellipse(hand1MaskDetails.massCenterImage.x, hand1MaskDetails.massCenterImage.y, 15, 15);
      text("   maskDetails", hand1MaskDetails.massCenterImage.x, hand1MaskDetails.massCenterImage.y);
      popStyle();
    }

    pushMatrix();

    if (handTracking) {
      //hand1Fingertip
      PXCMGesture.GeoNode hand1Fingertip = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_FINGERTIP);
      if (hand1Fingertip!=null) {

        pushStyle();
        fill(255, 0, 0);
        ellipse(hand1Fingertip.positionImage.x, hand1Fingertip.positionImage.y, 15, 15);
        text("   fingertip 1", hand1Fingertip.positionImage.x, hand1Fingertip.positionImage.y);
        popStyle();
      }

      PXCMGesture.GeoNode hand2Fingertip = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_HAND_FINGERTIP);
      if (hand2Fingertip!=null) {

        pushStyle();
        fill(255, 0, 0);
        ellipse(hand2Fingertip.positionImage.x, hand2Fingertip.positionImage.y, 15, 15);
        text("   fingertip 2", hand2Fingertip.positionImage.x, hand2Fingertip.positionImage.y);
        popStyle();
      }


      //hand1 HandUpper
      PXCMGesture.GeoNode hand1Upper = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_UPPER);
      if (hand1Upper!=null) {

        pushStyle();
        fill(255, 0, 0);
        ellipse(hand1Upper.positionImage.x, hand1Upper.positionImage.y, 15, 15);
        text("   upper", hand1Upper.positionImage.x, hand1Upper.positionImage.y);
        popStyle();
      }
      //hand1Middle
      PXCMGesture.GeoNode hand1HandMiddle = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_MIDDLE);
      if (hand1HandMiddle!=null) {

        pushStyle();
        fill(255, 0, 0);
        ellipse(hand1HandMiddle.positionImage.x, hand1HandMiddle.positionImage.y, 15, 15);
        text("   middle", hand1HandMiddle.positionImage.x, hand1HandMiddle.positionImage.y);
        popStyle();
      }
    }



    if (fingerTracking) {

      //HAND1

      //FINGER TRACKING
      //hand1Thumb
      PXCMGesture.GeoNode hand1Thumb = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB);
      if (hand1Thumb!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Thumb.positionImage.x, hand1Thumb.positionImage.y, 5, 5);
        text("   thumb", hand1Thumb.positionImage.x, hand1Thumb.positionImage.y);
        popStyle();
      }

      //hand1Index
      PXCMGesture.GeoNode hand1Index = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX);
      if (hand1Index!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Index.positionImage.x, hand1Index.positionImage.y, 5, 5);
        text("   index", hand1Index.positionImage.x, hand1Index.positionImage.y);
        popStyle();
      }

      //hand1Middle
      PXCMGesture.GeoNode hand1Middle = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE);
      if (hand1Middle!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Middle.positionImage.x, hand1Middle.positionImage.y, 5, 5);
        text("   middle", hand1Middle.positionImage.x, hand1Middle.positionImage.y);
        popStyle();
      }

      //hand1Ring
      PXCMGesture.GeoNode hand1Ring = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING);
      if (hand1Ring!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Ring.positionImage.x, hand1Ring.positionImage.y, 5, 5);
        text("   ring", hand1Ring.positionImage.x, hand1Ring.positionImage.y);
        popStyle();
      }


      //hand1Pinky
      PXCMGesture.GeoNode hand1Pinky = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY);
      if (hand1Pinky!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Pinky.positionImage.x, hand1Pinky.positionImage.y, 5, 5);
        text("   pinky", hand1Pinky.positionImage.x, hand1Pinky.positionImage.y);
        popStyle();
      }

      //Hand2


      //FINGER TRACKING
      //hand2Thumb
      PXCMGesture.GeoNode hand2Thumb = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB);
      if (hand2Thumb!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Thumb.positionImage.x, hand2Thumb.positionImage.y, 5, 5);
        text("   thumb", hand2Thumb.positionImage.x, hand2Thumb.positionImage.y);
        popStyle();
      }

      //hand2Index
      PXCMGesture.GeoNode hand2Index = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX);
      if (hand2Index!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Index.positionImage.x, hand2Index.positionImage.y, 5, 5);
        text("   index", hand2Index.positionImage.x, hand2Index.positionImage.y);
        popStyle();
      }

      //hand2Middle
      PXCMGesture.GeoNode hand2Middle = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE);
      if (hand2Middle!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Middle.positionImage.x, hand2Middle.positionImage.y, 5, 5);
        text("   middle", hand2Middle.positionImage.x, hand2Middle.positionImage.y);
        popStyle();
      }

      //hand2Ring
      PXCMGesture.GeoNode hand2Ring = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING);
      if (hand2Ring!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Ring.positionImage.x, hand2Ring.positionImage.y, 5, 5);
        text("   ring", hand2Ring.positionImage.x, hand2Ring.positionImage.y);
        popStyle();
      }


      //hand2Pinky
      PXCMGesture.GeoNode hand2Pinky = session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY);
      if (hand2Pinky!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Pinky.positionImage.x, hand2Pinky.positionImage.y, 5, 5);
        text("   pinky", hand2Pinky.positionImage.x, hand2Pinky.positionImage.y);
        popStyle();
      }
    }

    PXCMGesture.Gesture gdata=session.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY);
    if (gdata!=null) print("gesture "+gdata.label+"\n");

    int faces[]=session.QueryFaceID();
    if (faces!=null) {
      long timeStamp=session.QueryFaceTimeStamp();

      PXCMFaceAnalysis.Detection.Data ddata=session.QueryFaceLocationData(faces[0]);
      if (ddata!=null) print("face: id="+ddata.fid+", "+ddata.rectangle+"\n");

      PXCMFaceAnalysis.Landmark.LandmarkData ldata=session.QueryFaceLandmarkData(faces[0], PXCMFaceAnalysis.Landmark.LABEL_NOSE_TIP, 0);
      if (ldata!=null) print("landmark left-eye "+faces[0]+","+ldata.position+"\n");
    }
    session.ReleaseFrame();
    popMatrix();
  }
}


