/*******************************************************************************
INTEL CORPORATION PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with Intel Corporation and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2012 Intel Corporation. All Rights Reserved.

Parts of this code released under the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or any later version.
******************************************************************************/

import processing.opengl.*;
import codeanticode.glgraphics.*;
import diewald_fluid.Fluid2D;
import diewald_fluid.Fluid2D_CPU;
import diewald_fluid.Fluid2D_GPU;

import intel.pcsdk.*;

PXCUPipeline session;
PImage bkg;
boolean curtain = false;
boolean drawLabel = true;
int fX = 320;
int fY = 240;
int cS = 2;
int _w = fX*cS;
int _h = fY*cS;
short[] depth;

Fluid2D fluid;

int[] tipLabels = {PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING,
                  PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY};
ArrayList<PVector> positions = new ArrayList();
ArrayList<PVector> oldPos = new ArrayList();
void setup()
{
  session = new PXCUPipeline(this);
  size(640, 480, GLConstants.GLGRAPHICS);
  noStroke();
  
  if (!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.DEPTH_QVGA))
  {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }
  fluid = createFluidSolver();
  int[] lm_size=session.QueryDepthMapSize();
  if (lm_size!=null)
  {
    bkg = createImage(lm_size[0], lm_size[1], RGB);
    depth = new short[lm_size[0]*lm_size[1]];
  }
  int labels = tipLabels.length;
  for(int i=0;i<labels;i++)
  {
    positions.add(new PVector(-1,-1));
    oldPos.add(new PVector(-1,-1));    
  }
}

void draw()
{ 
  background(0);
  if (session.AcquireFrame(true))
  {
    session.QueryDepthMap(depth);
    if(depth!=null)
    {
      bkg.loadPixels();
      for(int p=0;p<depth.length;p++)
      {
        int t = 255-(int)(constrain(map(depth[p],0,1000,0,255),0,255));
        bkg.pixels[p] = color(t,t,t);
      }
      bkg.updatePixels();
    }
    for(int i=0;i<tipLabels.length;i++)
    {
      PXCMGesture.GeoNode node = session.QueryGeoNode(tipLabels[i]);
      if(node!=null)
      {
        positions.set(i,new PVector(node.positionImage.x,node.positionImage.y,node.positionWorld.y));
        if(keyPressed)
          println(node.positionWorld.y);
      }
      else
      {
        positions.set(i,new PVector(-1,-1));
      }
    }

    if(curtain)
    {/*
      for(int fl=0;fl<width-1+64;fl+=64)
      {
        setDens(fluid,fl,480,4,4,.87,.29,.1);
        setVel(fluid,fl,480,4,4,0,-.25);        
      }
      setDens(fluid,320,480,1,1,.87,.29,.1);
      setVel(fluid,320,480,1,1,0,-.25);        
      
      bkg.beginDraw();
      bkg.background(0);
      for(int p=0;p<positions.size();p++)
      {
        PVector ft = (PVector)positions.get(p);
        PVector pft = (PVector)oldPos.get(p);
        if(ft.x>=0&&ft.y>=0)
        {
          bkg.pushStyle();
          bkg.fill(148,184,34);
          bkg.ellipse(320-ft.x,ft.y,10,10);
          bkg.popStyle();
          
          float dx = (320-ft.x)-pft.x;
          float dy = ft.y-pft.y;
          setVel(fluid,(int)ft.x*2,(int)(width-ft.y*2),4,4,dx*0.01,dy*0.01-.25);
        }
        oldPos.set(p,ft);
      }
      bkg.endDraw();*/
    }
    else
    {
      for(int p=0;p<positions.size();p++)
      {
        PVector ft = (PVector)positions.get(p);        
        if(ft.x>=0&&ft.y>=0)
        {
          float r = map(ft.x,0,320,0,.25);
          float b = map(ft.y,0,240,0,.25);
          if(ft.z<0.2)
            setDens(fluid,(int)ft.x*2,(int)ft.y*2,16,16,r,.125,b);
          setVel(fluid,(int)ft.x*2,(int)ft.y*2,4,4,0,-.75);
        }
      }
    }
    fluid.setTextureBackground(bkg);      
    fluid.update();
    image(fluid.getDensityMap(),0,0,640,480);
    session.ReleaseFrame();
  }
}

void stop()
{
  super.stop();
  session.Close();
}
void setDens(Fluid2D fluid2d, int x, int y, int sizex, int sizey, float r, float g, float b)
{
  for (int y1 = 0; y1 < sizey; y1++)
  {
    for (int x1 = 0; x1 < sizex; x1++)
    {
      int xpos = (int)(x/(float)cS) + x1 - sizex/2;
      int ypos = (int)(y/(float)cS) + y1 - sizey/2;
      fluid2d.addDensity(0, xpos, ypos, r);
      fluid2d.addDensity(1, xpos, ypos, g);
      fluid2d.addDensity(2, xpos, ypos, b);
    }
  }
}

void setVel(Fluid2D fluid2d, int x, int y, int sizex, int sizey, float velx, float vely)
{
  for (int y1 = 0; y1 < sizey; y1++)
  {
    for (int x1 = 0; x1 < sizex; x1++)
    {
      int xpos = (int)((x/(float)cS)) + x1 - sizex/2;
      int ypos = (int)((y/(float)cS)) + y1 - sizey/2;
      fluid2d.addVelocity(xpos, ypos, velx, vely);
    }
  }
}

Fluid2D createFluidSolver()
{
  Fluid2D fluid_tmp = new Fluid2D_GPU(this, fX, fY); // initialize de solver

  fluid_tmp.setParam_Timestep  ( 0.10f );
  fluid_tmp.setParam_Iterations( 16 );
  fluid_tmp.setParam_IterationsDiffuse(1);
  fluid_tmp.setParam_Viscosity ( 0.000001f );
  fluid_tmp.setParam_Diffusion ( 0.00000001f );
  fluid_tmp.setParam_Vorticity ( 1.0f );
  fluid_tmp.processDensityMap  ( true );
  fluid_tmp.processDiffusion   ( true );
  fluid_tmp.processViscosity   ( true );
  fluid_tmp.processVorticity   ( true );
  fluid_tmp.processDensityMap  ( true );
  fluid_tmp.setObjectsColor    (1, 1, 1, 1); 
  return fluid_tmp;
}


