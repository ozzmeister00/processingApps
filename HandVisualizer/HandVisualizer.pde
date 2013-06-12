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
int[] depth_size = new int[2];
int[] ir_size = new int[2];
int[] lm_size = new int[2];
int[] rgb_size = new int[2];
ArrayList<PVector> mHandsPos = new ArrayList<PVector>();
ArrayList<PVector> mSectionsPos = new ArrayList<PVector>();
ArrayList<PVector> mFingersPos = new ArrayList<PVector>();

private static PImage display, rgbImage, depthImage, irImage;

PXCUPipeline session;
PXCMGesture.GeoNode mNode;

int[] mHands = {PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY,
                                      PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY};
                                      
                                     
int[] mSections = {PXCMGesture.GeoNode.LABEL_HAND_FINGERTIP,
                                          PXCMGesture.GeoNode.LABEL_HAND_UPPER,
                                          PXCMGesture.GeoNode.LABEL_HAND_MIDDLE,                                      
                                          PXCMGesture.GeoNode.LABEL_HAND_LOWER};

int[] mFingers = {PXCMGesture.GeoNode.LABEL_FINGER_THUMB,
                                          PXCMGesture.GeoNode.LABEL_FINGER_INDEX,
                                          PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE,                                      
                                          PXCMGesture.GeoNode.LABEL_FINGER_RING,
                                          PXCMGesture.GeoNode.LABEL_FINGER_PINKY};
void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);

  if (!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.COLOR_VGA|PXCUPipeline.DEPTH_QVGA))
  {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }

  if(session.QueryDepthMapSize(lm_size))
    display=createImage(lm_size[0], lm_size[1], RGB);

  if(session.QueryRGBSize(rgb_size))
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);

  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }

  if(session.QueryIRMapSize(ir_size))
  {
    irMap = new short[ir_size[0] * ir_size[1]];
    irImage=createImage(ir_size[0], ir_size[1], ALPHA);
  }
  
  mNode = new PXCMGesture.GeoNode();  
}

void draw()
{ 
  background(0);

  if(session.AcquireFrame(false))
  {
    mHandsPos.clear();
    mSectionsPos.clear();
    mFingersPos.clear();
    
    session.QueryLabelMapAsImage(display);
    session.QueryRGB(rgbImage); 

    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    if(session.QueryDepthMap(depthMap))
    {
      depthImage.loadPixels();
      for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
      {
        depthImage.pixels[i] = color(map(depthMap[i], 0, 4000, 0, 255));
      }
      depthImage.updatePixels();
    }

    //REMAPPING THE IR IMAGE TO A PIMAGE
    if(session.QueryIRMap(irMap))
    {
      irImage.loadPixels();
      for (int i = 0; i < ir_size[0]*ir_size[1]; i++)
      {
        irImage.pixels[i] = color(map(irMap[i], 0, 4000, 0, 255));
      }
      irImage.updatePixels();
    }
    
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_MASK_DETAILS, mNode))
      mHandsPos.add(new PVector(mNode.positionImage.x, mNode.positionImage.y));

    if (handTracking)
    {
      for(int i=0;i<mHands.length;++i)
      {
        for(int j=0;j<mSections.length;++j)
        {
          if(session.QueryGeoNode(mHands[i]|mSections[j], mNode))
            mSectionsPos.add(new PVector(mNode.positionImage.x, mNode.positionImage.y));
        }
      }
    }

    if (fingerTracking)
    {
      for(int i=0;i<mHands.length;++i)
      {
        for(int j=0;j<mFingers.length;++j)
        {
          if(session.QueryGeoNode(mHands[i]|mFingers[j], mNode))
            mFingersPos.add(new PVector(mNode.positionImage.x, mNode.positionImage.y));
        }
      }
    }

    session.ReleaseFrame();
  }
  
  image(display, 0,0);
  image(rgbImage, 320, 0, 320, 240);
  image(depthImage, 0, 240, 320, 240);
  image(irImage, 320, 240, 320, 240);
  
  pushStyle();
  for(int i=0;i<mHandsPos.size();++i)
  {
    PVector p = (PVector)mHandsPos.get(i);
    fill(255,0,0);
    ellipse(p.x,p.y,15,15);
  }
  popStyle();
  
  pushStyle();
  for(int i=0;i<mSectionsPos.size();++i)
  {
    PVector p = (PVector)mSectionsPos.get(i);
    noFill();
    stroke(255,0,0);
    strokeWeight(3);
    ellipse(p.x,p.y,15,15);
  }
  popStyle();

  pushStyle();
  for(int i=0;i<mFingersPos.size();++i)
  {
    PVector p = (PVector)mFingersPos.get(i);
    fill(255,100,25);
    ellipse(p.x,p.y,5,5);
  }
  popStyle();  
}
