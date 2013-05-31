import intel.pcsdk.*;
import blobDetection.*;
import fisica.*;

short[] depth;
int[] lm = new int[2];
PImage labelMap, depthMap;

BlobDetection blobDetector;

ArrayList<FPoly> labelBlobs = new ArrayList();
ArrayList<FCircle> drops = new ArrayList();
FWorld world;

PXCUPipeline session;

void setup()
{
  size(640,480);
  noFill();
  noStroke();
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.DEPTH_QVGA))
    exit();
  if(session.QueryLabelMapSize(lm))
  {
    labelMap = createImage(lm[0],lm[1],RGB);
    depthMap = createImage(lm[0],lm[1],ALPHA);
    blobDetector = new BlobDetection(lm[0], lm[1]);  
    blobDetector.setPosDiscrimination(false);
    blobDetector.setThreshold(0.1);
  }
  if(session.QueryDepthMapSize(lm))
    depth = new short[lm[0]*lm[1]];
  
  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  world.setGravity(0,800);
  world.remove(world.bottom);
  frameRate(60);
}

void draw()
{
  background(33,159,210);
  if((frameCount % 24)==0)
    addCircles();
  
  if(session.AcquireFrame(false))
  {    
    session.QueryLabelMapAsImage(labelMap);
    session.QueryDepthMap(depth);
    session.ReleaseFrame();
  }    
    
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
    p.setDrawable(true);
    p.setGrabbable(false);
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

void stop()
{
  session.Close();
  super.stop();
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
    //c.setDrawable(false);
    c.setGrabbable(false);
    world.add(c);
  }
}

/*
void drawCircles()
{
  for(FPoly b : labelBlobs)
  {
    pushMatrix();
    translate(b.getX(),b.getY())
  }
}*/
