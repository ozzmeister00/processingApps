/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/

import intel.pcsdk.*;
import blobDetection.*;
//import processing.opengl.*;

boolean drawLabel = false;
int[] lm = new int[2];
PImage labelMap;
BlobDetection blobDetector;
PXCUPipeline session;
void setup()
{
  size(640,480,OPENGL);
  session = new PXCUPipeline(this);
  
  if(!session.Init(PXCUPipeline.GESTURE))
    exit();
  lm = session.QueryLabelMapSize();
  labelMap = createImage(lm[0],lm[1],RGB);
  noFill();
  blobDetector = new BlobDetection(lm[0], lm[1]);  
  blobDetector.setPosDiscrimination(false);
  blobDetector.setThreshold(0.1);
  background(16);
}

void draw()
{
  if(!session.AcquireFrame(true))
    return;
  pushStyle();
  fill(0,16);
  rect(0,0,width,height);
  popStyle();
  if(session.QueryLabelMapAsImage(labelMap))
  {
    pushMatrix();
    scale(2);
    if(drawLabel)
      image(labelMap,0,0);
    blobDetector.computeBlobs(labelMap.pixels);
    Blob current;
    EdgeVertex e0,e1;
    for(int b=0;b<blobDetector.getBlobNb();b++)
    {
      current=blobDetector.getBlob(b);
      if(current!=null)
      {
        for(int e=0;e<current.getEdgeNb();e++)
        {
          e0=current.getEdgeVertexA(e);
          e1=current.getEdgeVertexB(e);          
          if(e0!=null&&e1!=null)
          {
            strokeWeight(2);
            stroke(0,255,0);
            line(e0.x*lm[0],e0.y*lm[1],e1.x*lm[0],e1.y*lm[1]);
          }
        }
      }
    }
    popMatrix();
  }
  session.ReleaseFrame();
}

void keyPressed()
{
  if(key=='l')
    drawLabel=!drawLabel;
}
