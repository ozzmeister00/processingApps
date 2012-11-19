//import processing.opengl.*;

import intel.pcsdk.*;
import blobDetection.*;
import fisica.*;

int[] lm = new int[2];
PImage labelMap;

BlobDetection blobDetector;
FWorld world;
ArrayList<FPoly> labelBlobs = new ArrayList();
ArrayList<FCircle> drops = new ArrayList();
void setup()
{
  size(640,480,OPENGL);
  noFill();
  noStroke();
  PXCUPipeline.Init(PXCUPipeline.PXCU_PIPELINE_GESTURE);
  lm = PXCUPipeline.QueryLabelMapSize();
  labelMap = createImage(lm[0],lm[1],RGB);

  blobDetector = new BlobDetection(lm[0], lm[1]);  
  blobDetector.setPosDiscrimination(false);
  blobDetector.setThreshold(0.1);
  
  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  world.setGravity(0,800);
  world.remove(world.bottom);
  frameRate(30);
}

void draw()
{
  if(!PXCUPipeline.AcquireFrame(true))
    return;
  background(33,159,210);
  if((frameCount % 24)==0)
    addCircles();
  if(PXCUPipeline.QueryLabelMapAsImage(labelMap))
  {
    //image(labelMap,0,0);
    blobDetector.computeBlobs(labelMap.pixels);
    Blob current;
    EdgeVertex e0,e1;
    
    for(int b=0;b<blobDetector.getBlobNb();b++)
    {
      current=blobDetector.getBlob(b);
      FPoly p = new FPoly();
      p.setStaticBody(true);
      p.setStrokeWeight(2);
      p.setStroke(255,161,51);
      p.setFill(146,185,30);
      p.setDensity(1);
      
      if(current!=null)
      {
        for(int e=0;e<current.getEdgeNb();e+=7)
        {
          e1 = current.getEdgeVertexB(e);
          p.vertex(e1.x*width,e1.y*height);
        }
      }
      world.add(p);
      labelBlobs.add(p);
    }
    world.step();
    world.draw(this);
    for(FPoly wp : labelBlobs)
    {
      world.remove(wp);
    }
    labelBlobs.clear();    
  }
  PXCUPipeline.ReleaseFrame();
}

void stop()
{
  super.stop();
  PXCUPipeline.Close();
}

void addCircles()
{
  for(int i=0;i<20;i++)
  {
    FCircle c = new FCircle(random(20,40));
    c.setNoStroke();
    c.setFill(222,74,28);
    c.setPosition(random(0,width),0);
    c.setVelocity(0,random(300,500));
    c.setRestitution(0.5);
    c.setDamping(0);
    world.add(c);
  }
}
