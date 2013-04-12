/*******************************************************************************
INTEL CORPORATION PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with Intel Corporation and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2012 Intel Corporation. All Rights Reserved.
******************************************************************************/

//comment this out if running Processing 2
//import processing.opengl.*;
//----------------------------------------

import intel.pcsdk.*;

boolean trackHand = true;
boolean released = false;
int radiusMin = 24;
int radiusMax = 70;
int xStep = 32;
int yStep = 32;
float screenDist; 
color percBlue = color(2,114,162);
color percOrange = color(242,143,24);
ArrayList<PVector> tracked = new ArrayList<PVector>();
PImage labelMap;

PXCUPipeline session;

void setup()
{
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.GESTURE);
  int[] labelMapSize = new int[2];
  session.QueryLabelMapSize(labelMapSize);
  labelMap = createImage(labelMapSize[0],labelMapSize[1],RGB);
  tracked.add(new PVector(-10,-10,1));

  size(640, 480, P3D); //use opengl so we can z-order the ellipses
  screenDist = dist(0,0,width/12,height/12);
  noStroke();
  background(0);
}

void draw()
{
  released = false;
  background(0);
  if(!trackHand)
    tracked.set(0,new PVector(mouseX,mouseY,1));
  else
  {
    if(session.AcquireFrame(true))
    {
      if(session.QueryLabelMapAsImage(labelMap))
      {
        //little hack to mirror the label map
        pushMatrix();
        translate(640,0);
        scale(-2,2);
        image(labelMap,0,0);
        popMatrix();
      }
          
      PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
      {
        tracked.set(0,new PVector(width-hand.positionImage.x*2,hand.positionImage.y*2,hand.openness*0.01));
        println(hand.positionWorld.z);
      }
      session.ReleaseFrame(); //must do tracking before frame is released
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
      ellipse(0,0,ellipseRadius*2,ellipseRadius*2);
      popMatrix();
    }    
  }
}

