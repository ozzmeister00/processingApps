/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
import intel.pcsdk.*; //import the Intel Perceptual Computing SDK

short[] depthMap;
short[] irMap;
int[] depth_size;
int[] ir_size;
PImage labelImage, rgbImage, depthImage, irImage;
PXCUPipeline session;
void setup() {
  size(640, 480);
  session = new PXCUPipeline(this);
  if(!session.Init(session.GESTURE|session.COLOR_VGA|session.DEPTH_QVGA))
    exit();

  //SETUP LABEL IMAGE
  int[] lm_size=session.QueryDepthMapSize();
  if (lm_size!=null) {
    print("LabelMapSize("+lm_size[0]+","+lm_size[1]+")\n");
    labelImage=createImage(lm_size[0], lm_size[1], RGB);
  }

  //SETUP RGB IMAGE
  int[] rgb_size=session.QueryRGBSize();
  println("querying RGBSize");
  if (rgb_size!=null) {
    print("RGBSize("+rgb_size[0]+","+rgb_size[1]+")\n");
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);
  }

  //SETUP DEPTH MAP
  depth_size=session.QueryDepthMapSize();
  println("querying DepthSize");
  if (depth_size!=null) {
    print("DepthSize("+depth_size[0]+","+depth_size[1]+")\n");

    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }

  //SETUP IR IMAGE
  ir_size=session.QueryIRMapSize();
  println("querying IRSize");
  if (ir_size!=null) {
    print("IR Size("+ir_size[0]+","+ir_size[1]+")\n");
    irMap = new short[ir_size[0] * ir_size[1]];
    irImage=createImage(ir_size[0], ir_size[1], ALPHA);
  }
}

void draw() { 
  background(0);

  if (session.AcquireFrame(true)) { //if this is set to false it flashes

    session.QueryLabelMapAsImage(labelImage);
    image(labelImage, 0, 0);

    session.QueryRGB(rgbImage);
    image(rgbImage, 320, 0, 320, 240);


    float remapMouseX = map(mouseX, 0, width, 255, 8192);
    float remapMouseY = map(mouseY, 0, height, 255, 8192);

    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    session.QueryDepthMap(depthMap);
    depthImage.loadPixels();
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++) {
      depthImage.pixels[i] = color(map(depthMap[i], 0, remapMouseX, 0, 255));
    }
    depthImage.updatePixels();
    image(depthImage, 0, 240, 320, 240);



    //REMAPPING THE IR IMAGE TO A PIMAGE
    session.QueryIRMap(irMap);
    irImage.loadPixels();
    for (int i = 0; i < ir_size[0]*ir_size[1]; i++) {
      irImage.pixels[i] = color(map(irMap[i], 0, remapMouseY, 0, 255));
    }
    irImage.updatePixels();
    image(irImage, 320, 240, 320, 240);

    session.ReleaseFrame();//VERY IMPORTANT TO RELEASE THE FRAME
  }
}


void exit()
{
  session.Close(); 
  super.exit();
}

