
/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
//Beta 3

import intel.pcsdk.*; //import the Intel Perceptual Computing SDK

int[] depth_size;
short[] depthMap;
PImage depthImage;
PXCUPipeline session;

void setup() {
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(session.DEPTH_QVGA);

  //SETUP DEPTH MAP
  depth_size = new int[2];
  session.QueryDepthMapSize(depth_size);
  if (depth_size!=null) {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }
}

void draw() { 
  if (session.AcquireFrame(true)) { //if this is set to false it flashes

    float remapMouseX = map(mouseX, 0, width, 255, 8192);
    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    session.QueryDepthMap(depthMap);
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++) {
      depthImage.pixels[i] = color(map(depthMap[i], 0, remapMouseX, 0, 255));
    }
    depthImage.updatePixels();
    image(depthImage, 0, 0, 640, 480);
  }
  session.ReleaseFrame();//VERY IMPORTANT TO RELEASE THE FRAME
}

