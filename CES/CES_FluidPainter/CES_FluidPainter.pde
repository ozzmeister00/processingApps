//import processing.opengl.*; //uncomment if using Processing 1.5.1
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
int oldXMin, oldXMax, oldYMin, oldYMax;
short[] depth;
float[] fColor = {1,1,1};
Fluid2D fluid;

int[] tipLabels = {PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY,
                    PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY};
int[] lm_size;
PVector[] positions = new PVector[2];
PVector[] oldPos = new PVector[2];
color[] PALETTE = { color(255,0,0),
                    color(255,128,0),
                    color(255,255,0),
                    color(0,255,0),
                    color(0,0,255),
                    color(128,0,255),
                    color(255,0,255),
                    color(0,0,0)};
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
  lm_size= new int[2];
  session.QueryDepthMapSize(lm_size);
  if (lm_size!=null)
  {
    bkg = createImage(lm_size[0], lm_size[1], RGB);
    depth = new short[lm_size[0]*lm_size[1]];
  }
  for(int i=0;i<tipLabels.length;i++)
  {
    positions[i] = new PVector(-1,-1);
    oldPos[i] = new PVector(-1,-1);    
  }
  
  // CHANGE THESE FOR TUNING
  oldXMin = 80;
  oldXMax = 240;
  oldYMin = 80;
  oldYMax = 200;
  // CHANGE THESE FOR TUNING  
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
      oldPos[i].set(positions[i]);
      PXCMGesture.GeoNode node = new PXCMGesture.GeoNode();
      session.QueryGeoNode(tipLabels[i], node);
      if(node!=null)
      {
        float px = map(node.positionImage.x,oldXMin, oldXMax,0,320);
        float py = map(node.positionImage.y,oldYMin, oldYMax,0,240);
        positions[i].set(lm_size[0]-px, py, node.openness);
      }
      else
      {
        positions[i].set(-1,-1,0);
      }
    }
    
    setColor();
    
    for(int p=0;p<positions.length;p++)
    {
      if(positions[p].x>=0&&positions[p].y>=0)
      {
        float vx = (float)(positions[p].x-oldPos[p].x);
        float vy = (float)(positions[p].y-oldPos[p].y);
        int bsize = (int)(map(positions[p].z,20,100,4,16));
        if(positions[p].z>20)
        {
          setDens(fluid,(int)positions[p].x*2,(int)positions[p].y*2,bsize,bsize,fColor[0],fColor[1],fColor[2]);
        }
        setVel(fluid,(int)oldPos[p].x*2,(int)oldPos[p].y*2,bsize/2,bsize/2,vx*0.08,vy*0.08);
      }
    }
    session.ReleaseFrame();
    fluid.update();
    image(fluid.getDensityMap(),0,0,640,480);
  }
  drawPalette();
  ellipse(positions[0].x*2,positions[0].y*2,20,20);      
  ellipse(positions[1].x*2,positions[1].y*2,20,20);        
}

void stop()
{
  super.stop();
  session.Close();
}

void drawPalette()
{
  pushStyle();
  stroke(128);
  rectMode(CORNERS);
  for(int i=0;i<8;i++)
  {
    fill(PALETTE[i]);
    rect(580,i*60,639,i*60+59);
  }
  popStyle();
}

void setColor()
{
  int idx = 0;
  if(positions[0].x*2>600&&positions[0].y*2<479)
  {
    idx = (int)(positions[0].y*2/60.0);
    fColor[0] = red(PALETTE[idx])/255.0;
    fColor[1] = green(PALETTE[idx])/255.0;
    fColor[2] = blue(PALETTE[idx])/255.0;  
  }
  else if(positions[1].x*2>600&&positions[1].y*2<479)
  {
    idx = (int)(positions[1].y*2/60.0);
    fColor[0] = red(PALETTE[idx])/255.0;
    fColor[1] = green(PALETTE[idx])/255.0;
    fColor[2] = blue(PALETTE[idx])/255.0;  
  }
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


