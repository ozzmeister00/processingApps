/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
import intel.pcsdk.*;

private static PImage display, rgbImage, depthImage, irImage, uvImage;


private static int mode=PXCUPipeline.PXCU_PIPELINE_COLOR_VGA;//PXCU_PIPELINE_GESTURE

boolean fingerTracking = true;
boolean handTracking = false;

short[] depthMap;
int[] depth_size;

short[] irMap;
int[] ir_size;

float[] uvMap;
int[] uv_size;

void blah() //example in bitwise operations
{
  int mybits = 0;

  // to set a bit

  mybits = mybits | 0x0800;

  //to clear a bit
  mybits = mybits & (~0x0800);//flips every bit

  // to check a bit
  if ((mybits & 0x0800) != 0)
  {
  }
}

void setup() {
  size(1280, 480);
  mode=PXCUPipeline.PXCU_PIPELINE_GESTURE; //
  if (!PXCUPipeline.Init(mode)) {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }

  //if ((mode&PXCUPipeline.PXCU_PIPELINE_GESTURE)!=0) {
  int[] lm_size=PXCUPipeline.QueryDepthMapSize();//QueryLabelMapSize();
  if (lm_size!=null) {
    print("LabelMapSize("+lm_size[0]+","+lm_size[1]+")\n");
    display=createImage(lm_size[0], lm_size[1], RGB);
    //rgbImage=createImage(lm_size[0], lm_size[1], RGB);
  }

  int[] uv_size=PXCUPipeline.QueryUVMapSize();
  if (uv_size!=null) print("UVMapSize("+uv_size[0]+","+uv_size[1]+")\n");
  //} 



  mode=PXCUPipeline.PXCU_PIPELINE_COLOR_VGA; //PXCU_PIPELINE_GESTURE;
  PXCUPipeline.Init(mode);

  int[] rgb_size=PXCUPipeline.QueryRGBSize();
  println("querying RGBSize");
  if (rgb_size!=null) {
    print("RGBSize("+rgb_size[0]+","+rgb_size[1]+")\n");
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);//rgb_size[0], rgb_size[1], RGB);
  }


  mode=PXCUPipeline.PXCU_PIPELINE_DEPTH_VGA; //PXCU_PIPELINE_GESTURE;

  PXCUPipeline.Init(mode);

  depth_size=PXCUPipeline.QueryDepthMapSize();
  println("querying DepthSize");
  if (depth_size!=null) {
    print("DepthSize("+depth_size[0]+","+depth_size[1]+")\n");

    depthMap = new short[depth_size[0] * depth_size[1]];
    //  PXCUPipeline.QueryDepthMap(depthMap);
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);//rgb_size[0], rgb_size[1], RGB);
  }
  
  
  //GRAB IR CAMERA IMAGE
  mode=PXCUPipeline.PXCU_PIPELINE_CAPTURE; //PXCU_PIPELINE_GESTURE;

  PXCUPipeline.Init(mode);

  ir_size=PXCUPipeline.QueryIRMapSize();
  println("querying IRSize");
  if (ir_size!=null) {
    print("IR Size("+ir_size[0]+","+ir_size[1]+")\n");

    irMap = new short[ir_size[0] * ir_size[1]];
    //  PXCUPipeline.QueryDepthMap(depthMap);
    irImage=createImage(ir_size[0], ir_size[1], ALPHA);//rgb_size[0], rgb_size[1], RGB);
  }
  
    //GRAB UV MAP 
    
  mode=PXCUPipeline.PXCU_PIPELINE_DEPTH_VGA; //PXCU_PIPELINE_GESTURE;

  PXCUPipeline.Init(mode);

  uv_size=PXCUPipeline.QueryUVMapSize();
  println("querying UVSize");
  if (uv_size!=null) {
    print("UV Size("+uv_size[0]+","+uv_size[1]+")\n");

    uvMap = new float[uv_size[0] * uv_size[1]*4];
    
    uvImage=createImage(uv_size[0], uv_size[1], ARGB);//rgb_size[0], rgb_size[1], RGB);
  }
  
  
  
}

void draw() { 
  background(0);

  if (PXCUPipeline.AcquireFrame(true)) { //if this is set to false it flashes
    float[] acc=new float[3];
    PXCUPipeline.QueryDeviceProperty(PXCMCapture.Device.PROPERTY_ACCELEROMETER_READING, acc);
    //print ("acc: "+acc[0]+","+acc[1]+","+acc[2]+"\n");   

    // if ((mode&PXCUPipeline.PXCU_PIPELINE_GESTURE)!=0) {
    if (PXCUPipeline.QueryLabelMapAsImage(display)) image(display, 0, 0);//, 640, 480);
    // } 
    // else {
    if (PXCUPipeline.QueryRGB(rgbImage)) image(rgbImage, 320, 0, 320, 240);


    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    PXCUPipeline.QueryDepthMap(depthMap);
    depthImage.loadPixels();
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++) {
      depthImage.pixels[i] = color(map(depthMap[i], 0, 4000, 0, 255));
    }
    depthImage.updatePixels();
    image(depthImage, 0, 240, 320, 240);
    

    //REMAPPING THE IR IMAGE TO A PIMAGE
    PXCUPipeline.QueryIRMap(irMap);
    irImage.loadPixels();
    for (int i = 0; i < ir_size[0]*ir_size[1]; i++) {
      irImage.pixels[i] = color(map(irMap[i], 0, 4000, 0, 255));
    }
    irImage.updatePixels();
    image(irImage, 320, 240, 320, 240);
    
    /*
    //REMAPPING THE UV IMAGE TO A PIMAGE
    PXCUPipeline.QueryUVMap(uvMap);
    
    uvImage.loadPixels();
    for (int i = 0; i < mouseX; i++) { //(uv_size[0]*uv_size[1])-1
      uvImage.pixels[i] = color(map(uvMap[i], 0, 4000, 0, 255));
    }
    uvImage.updatePixels();
    image(uvImage, 320, 240, 320, 240);
    
    println(mouseX + "  :  " + uvMap[mouseX]);
    */
    //  }
    //image(rgbImage, 320, 0);


    /*
    //maskDetails
     PXCMGesture.GeoNode hand1MaskDetails = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_MASK_DETAILS);//LABEL_HAND_UPPER);
     if (hand1MaskDetails!=null) {
     
     pushStyle();
     fill(255, 0, 0);
     ellipse(hand1MaskDetails.massCenterImage.x, hand1MaskDetails.massCenterImage.y, 15, 15);
     text("   maskDetails", hand1MaskDetails.massCenterImage.x, hand1MaskDetails.massCenterImage.y);
     popStyle();
     }
     */
    pushMatrix();
    //scale(2);

    if (handTracking) {
      //hand1Fingertip
      PXCMGesture.GeoNode hand1Fingertip = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_FINGERTIP);//LABEL_HAND_UPPER);
      if (hand1Fingertip!=null) {

        pushStyle();
        fill(255, 0, 0);
        ellipse(hand1Fingertip.positionImage.x, hand1Fingertip.positionImage.y, 15, 15);
        text("   fingertip 1", hand1Fingertip.positionImage.x, hand1Fingertip.positionImage.y);
        popStyle();
      }

      PXCMGesture.GeoNode hand2Fingertip = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_HAND_FINGERTIP);//LABEL_HAND_UPPER);
      if (hand2Fingertip!=null) {

        pushStyle();
        fill(255, 0, 0);
        ellipse(hand2Fingertip.positionImage.x, hand2Fingertip.positionImage.y, 15, 15);
        text("   fingertip 2", hand2Fingertip.positionImage.x, hand2Fingertip.positionImage.y);
        popStyle();
      }

      /*
    //hand1 HandUpper
       PXCMGesture.GeoNode hand1Upper = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_UPPER);//);
       if (hand1Upper!=null) {
       
       pushStyle();
       fill(255, 0, 0);
       ellipse(hand1Upper.positionImage.x, hand1Upper.positionImage.y, 15, 15);
       text("   upper", hand1Upper.positionImage.x, hand1Upper.positionImage.y);
       popStyle();
       }
       //hand1Middle
       PXCMGesture.GeoNode hand1HandMiddle = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_MIDDLE);//);
       if (hand1HandMiddle!=null) {
       
       pushStyle();
       fill(255, 0, 0);
       ellipse(hand1HandMiddle.positionImage.x, hand1HandMiddle.positionImage.y, 15, 15);
       text("   middle", hand1HandMiddle.positionImage.x, hand1HandMiddle.positionImage.y);
       popStyle();
       }
       */
    }



    if (fingerTracking) {

      //HAND1

      //FINGER TRACKING
      //hand1Thumb
      PXCMGesture.GeoNode hand1Thumb = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB);//);
      if (hand1Thumb!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Thumb.positionImage.x, hand1Thumb.positionImage.y, 5, 5);
        text("   thumb", hand1Thumb.positionImage.x, hand1Thumb.positionImage.y);
        popStyle();
      }

      //hand1Index
      PXCMGesture.GeoNode hand1Index = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX);//);
      if (hand1Index!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Index.positionImage.x, hand1Index.positionImage.y, 5, 5);
        text("   index", hand1Index.positionImage.x, hand1Index.positionImage.y);
        popStyle();
      }

      //hand1Middle
      PXCMGesture.GeoNode hand1Middle = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE);//);
      if (hand1Middle!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Middle.positionImage.x, hand1Middle.positionImage.y, 5, 5);
        text("   middle", hand1Middle.positionImage.x, hand1Middle.positionImage.y);
        popStyle();
      }

      //hand1Ring
      PXCMGesture.GeoNode hand1Ring = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING);//);
      if (hand1Ring!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand1Ring.positionImage.x, hand1Ring.positionImage.y, 5, 5);
        text("   ring", hand1Ring.positionImage.x, hand1Ring.positionImage.y);
        popStyle();
      }


      //hand1Pinky
      PXCMGesture.GeoNode hand1Pinky = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY);//);
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
      PXCMGesture.GeoNode hand2Thumb = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB);//);
      if (hand2Thumb!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Thumb.positionImage.x, hand2Thumb.positionImage.y, 5, 5);
        text("   thumb", hand2Thumb.positionImage.x, hand2Thumb.positionImage.y);
        popStyle();
      }

      //hand2Index
      PXCMGesture.GeoNode hand2Index = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX);//);
      if (hand2Index!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Index.positionImage.x, hand2Index.positionImage.y, 5, 5);
        text("   index", hand2Index.positionImage.x, hand2Index.positionImage.y);
        popStyle();
      }

      //hand2Middle
      PXCMGesture.GeoNode hand2Middle = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE);//);
      if (hand2Middle!=null) {

        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Middle.positionImage.x, hand2Middle.positionImage.y, 5, 5);
        text("   middle", hand2Middle.positionImage.x, hand2Middle.positionImage.y);
        popStyle();
      }

      //hand2Ring
      PXCMGesture.GeoNode hand2Ring = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING);//);
      if (hand2Ring!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Ring.positionImage.x, hand2Ring.positionImage.y, 5, 5);
        text("   ring", hand2Ring.positionImage.x, hand2Ring.positionImage.y);
        popStyle();
      }


      //hand2Pinky
      PXCMGesture.GeoNode hand2Pinky = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY);//);
      if (hand2Pinky!=null) {
        pushStyle();
        fill(255, 100, 25);
        ellipse(hand2Pinky.positionImage.x, hand2Pinky.positionImage.y, 5, 5);
        text("   pinky", hand2Pinky.positionImage.x, hand2Pinky.positionImage.y);
        popStyle();
      }
    }

    /*
      PXCMGesture.GeoNode ndata2 = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_HAND_UPPER);
     if (ndata2!=null){
     print("node: "+ndata2.positionImage+"\n");
     pushStyle();
     fill(0,0,255);
     ellipse(ndata2.positionImage.x, ndata2.positionImage.y, 25, 25);
     popStyle();
     }
     */
    PXCMGesture.Gesture gdata=PXCUPipeline.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY);
    if (gdata!=null) print("gesture "+gdata.label+"\n");

    int faces[]=PXCUPipeline.QueryFaceID();
    if (faces!=null) {
      long timeStamp=PXCUPipeline.QueryFaceTimeStamp();

      PXCMFaceAnalysis.Detection.Data ddata=PXCUPipeline.QueryFaceLocationData(faces[0]);
      if (ddata!=null) print("face: id="+ddata.fid+", "+ddata.rectangle+"\n");

      PXCMFaceAnalysis.Landmark.LandmarkData ldata=PXCUPipeline.QueryFaceLandmarkData(faces[0], PXCMFaceAnalysis.Landmark.LABEL_NOSE_TIP, 0);
      if (ldata!=null) print("landmark left-eye "+faces[0]+","+ldata.position+"\n");
    }
    PXCUPipeline.ReleaseFrame();
    popMatrix();
  }
}

