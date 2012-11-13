import processing.opengl.*;
import codeanticode.glgraphics.*;
import diewald_fluid.Fluid2D;
import diewald_fluid.Fluid2D_CPU;
import diewald_fluid.Fluid2D_GPU;

import intel.pcsdk.*;

PGraphics bkg;
boolean curtain = false;
boolean drawLabel = true;
int fX = 160;
int fY = 120;
int cS = 4;
int _w = fX*cS;
int _h = fY*cS;

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
  size(640, 480, GLConstants.GLGRAPHICS);
  noStroke();
  
  if (!PXCUPipeline.Init(PXCUPipeline.PXCU_PIPELINE_GESTURE))
  {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }
  fluid = createFluidSolver();
  int[] lm_size=PXCUPipeline.QueryLabelMapSize();
  if (lm_size!=null)
  {
    bkg = createGraphics(lm_size[0], lm_size[1], JAVA2D);
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
  if (PXCUPipeline.AcquireFrame(true))
  {
    for(int i=0;i<tipLabels.length;i++)
    {
      PXCMGesture.GeoNode node = PXCUPipeline.QueryGeoNode(tipLabels[i]);
      if(node!=null)
      {
        positions.set(i,new PVector(node.positionImage.x,node.positionImage.y));
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
      if(drawLabel)
        PXCUPipeline.QueryLabelMapAsImage(bkg);
      bkg.beginDraw();
      if(!drawLabel)
        bkg.background(0);
      for(int p=0;p<positions.size();p++)
      {
        PVector ft = (PVector)positions.get(p);
        if(ft.x>=0&&ft.y>=0)
        {
          bkg.pushStyle();
          bkg.fill(148,184,34);
          bkg.ellipse(ft.x,ft.y,10,10);
          bkg.popStyle();
          float r = map(ft.x,0,320,0,1);
          float b = map(ft.y,0,240,0,1);          
          setDens(fluid,(int)ft.x*2,(int)ft.y*2,4,4,r,.5,b);
          setVel(fluid,(int)ft.x*2,(int)ft.y*2,4,4,0,-.25);
        }
      }
      bkg.endDraw();
    }
    fluid.setTextureBackground(bkg);      
    fluid.update();
    image(fluid.getDensityMap(),0,0,640,480);
    PXCUPipeline.ReleaseFrame();
  }
}

void keyPressed()
{
  if(key=='l')
    drawLabel=!drawLabel;
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


