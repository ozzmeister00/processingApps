
/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
//Updated to work with Beta 3, Beta 2 no longer works with this code -Rojas

import intel.pcsdk.*; //import the Intel Perceptual Computing SDK

short[] depthMap;
short[] irMap;

int[] depth_size = new int[2];
int[] ir_size = new int[2];
int[] lm_size = new int[2];
int[] rgb_size = new int[2];
  
PImage labelImage, rgbImage, depthImage, irImage;
PXCUPipeline session;

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.COLOR_VGA|PXCUPipeline.DEPTH_QVGA))
    exit();

  //SETUP LABEL IMAGE
  if(session.QueryDepthMapSize(lm_size))
    labelImage=createImage(lm_size[0], lm_size[1], RGB);

  //SETUP RGB IMAGE
  if(session.QueryRGBSize(rgb_size))
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);

  //SETUP DEPTH MAP
  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }

  //SETUP IR IMAGE
  if(session.QueryIRMapSize(ir_size))
  {
    irMap = new short[ir_size[0] * ir_size[1]];
    irImage=createImage(ir_size[0], ir_size[1], ALPHA);
  }
}

void draw()
{ 
  background(0);

  if (session.AcquireFrame(false))
  {
    session.QueryLabelMapAsImage(labelImage);
    session.QueryRGB(rgbImage);

    float remapMouseX = map(mouseX, 0, width, 255, 8192);
    float remapMouseY = map(mouseY, 0, height, 255, 8192);

    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    session.QueryDepthMap(depthMap);
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
    {
      depthImage.pixels[i] = color(map(depthMap[i], 0, remapMouseX, 0, 255));
    }
    depthImage.updatePixels();

    //REMAPPING THE IR IMAGE TO A PIMAGE
    session.QueryIRMap(irMap);
    for (int i = 0; i < ir_size[0]*ir_size[1]; i++) {
      irImage.pixels[i] = color(map(irMap[i], 0, remapMouseY, 0, 255));
    }
    irImage.updatePixels();
    session.ReleaseFrame();//VERY IMPORTANT TO RELEASE THE FRAME
  }
  
  image(labelImage, 0, 0);
  image(rgbImage, 320, 0, 320, 240);
  image(depthImage, 0, 240, 320, 240);
  image(irImage, 320, 240, 320, 240);
}


void exit()
{
  session.Close(); 
  super.exit();
}

