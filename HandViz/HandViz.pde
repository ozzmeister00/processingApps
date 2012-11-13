/*******************************************************************************
INTEL CORPORATION PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with Intel Corporation and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2012 Intel Corporation. All Rights Reserved.
******************************************************************************/

//comment this out if running Processing 2
import processing.opengl.*;
//----------------------------------------

import intel.pcsdk.*;

boolean trackHand = true;
int sWidth = 640;
int sHeight = 480;
int radiusMin = 24;
int radiusMax = 70;
int xStep = 32;
int yStep = 32;
float screenDist = dist(0,0,sWidth/12,sHeight/12);
color percBlue = color(2,114,162);
color percOrange = color(242,143,24);
ArrayList<PVector> tracked = new ArrayList();
PImage labelMap;

void setup()
{
  PXCUPipeline.Init(PXCUPipeline.PXCU_PIPELINE_GESTURE|PXCUPipeline.PXCU_PIPELINE_GESTURE);
  int[] labelMapSize = PXCUPipeline.QueryLabelMapSize();
  labelMap = createImage(labelMapSize[0],labelMapSize[1],RGB);
  tracked.add(new PVector(-10,-10,1));

  size(sWidth,sHeight,OPENGL); //use opengl so we can z-order the ellipses
  noStroke();
  background(0);
}

void draw()
{
  background(0);
  if(!PXCUPipeline.AcquireFrame(true))
    return;
  if(!trackHand)
    tracked.set(0,new PVector(mouseX,mouseY,1));
  else
  {
    if(PXCUPipeline.QueryLabelMapAsImage(labelMap))
    {
      //little hack to mirror the label map
      pushMatrix();
      translate(640,0);
      scale(-2,2);
      image(labelMap,0,0);
      popMatrix();
    }
    PXCMGesture.GeoNode hand = PXCUPipeline.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY);
    if(hand!=null)
    {
      tracked.set(0,new PVector(width-hand.positionImage.x*2,hand.positionImage.y*2,hand.openness*0.01));
      //println(hand.positionWorld.z);
    }
  }

  for(int y=0;y<height+yStep-1;y+=yStep)
  {
    for(int x=0;x<width+xStep-1;x+=xStep)
    {
      PVector pos = (PVector)tracked.get(0);
      float posDist = dist(pos.x,pos.y,x,y);
      float distRatio = constrain((1-posDist/screenDist),0,1);

      float ellipseRadius=lerp(radiusMin,radiusMax,distRatio);
      if(distRatio>0)
      {
        ellipseRadius=lerp(radiusMin,radiusMax,pos.z);
      }
      float fillAlpha = lerp(128,255,distRatio);
      color fillColor = lerpColor(percBlue,percOrange,distRatio);
      fill(fillColor,fillAlpha);
      
      //using the hand distance ratio as z depth means
      //largest ellipse will always be on top
      pushMatrix();
      translate(x,y,distRatio); 
      ellipse(0,0,ellipseRadius,ellipseRadius);
      popMatrix();
    }    
  }
  
  PXCUPipeline.ReleaseFrame();
}

void stop()
{
  super.stop();
  PXCUPipeline.Close();
}
