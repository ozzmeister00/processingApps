import processing.opengl.*;

import intel.pcsdk.*;
import blobDetection.*;
import fisica.*;

short[] depth;
int[] lm = new int[2];
int counter = 0;
PImage blobMap;
PImage depthMap;
PImage bgimage;

BlobDetection blobDetector;
FWorld world;
ArrayList<FPoly> labelBlobs = new ArrayList();
ArrayList<FCircle> drops = new ArrayList();
ArrayList<PImage> flakes = new ArrayList();
ArrayList<Blob> foundBlobs = new ArrayList();
PXCUPipeline session;

void setup()
{
  size(640,480,OPENGL);
  noFill();
  noStroke();
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.GESTURE|PXCUPipeline.DEPTH_QVGA);
  lm = session.QueryLabelMapSize();
  blobMap = createImage(lm[0],lm[1],RGB);
  depthMap = createImage(lm[0],lm[1],ARGB);
  bgimage = loadImage("bkg.jpg");
  flakes.add(loadImage("flake01.png"));
  flakes.add(loadImage("flake02.png"));
  flakes.add(loadImage("flake03.png"));
  flakes.add(loadImage("flake04.png"));
  flakes.add(loadImage("flake05.png"));
  flakes.add(loadImage("flake06.png"));  
  blobDetector = new BlobDetection(lm[0], lm[1]);  
  blobDetector.setPosDiscrimination(false);
  blobDetector.setThreshold(0.1);
  
  lm = session.QueryDepthMapSize();
  depth = new short[lm[0]*lm[1]];
  
  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  world.setGravity(0,400);
  world.remove(world.top);
  world.remove(world.left);
  world.remove(world.right);  
  world.remove(world.bottom);
  frameRate(30);
}

void draw()
{
  if(!session.AcquireFrame(true))
    return;
  noStroke();
  image(bgimage,0,0,640,480);
  if((frameCount % 6)==0)
    addCircles();
  if(session.QueryDepthMap(depth))
  {
    depthMap.loadPixels();
    blobMap.loadPixels();
    for(int p=0;p<depth.length;p++)
    {
      int _c = (int)(constrain(map(depth[p],1000,200,0,255),0,255));
      depthMap.pixels[p]=color(255,_c);
      blobMap.pixels[p]=color(_c,_c,_c);
    }
    depthMap.updatePixels();
    blobMap.updatePixels();
    image(depthMap,0,0,640,480);
    //blobDetector.computeBlobs(labelMap.pixels);
    blobDetector.computeBlobs(blobMap.pixels);
    Blob current;
    EdgeVertex e0,e1;
    e0 = new EdgeVertex(0,0);
    e1 = new EdgeVertex(0,0);
    for(int b=0;b<blobDetector.getBlobNb();b++)
    {
      current=blobDetector.getBlob(b);
      FPoly p = new FPoly();
      p.setStaticBody(true);
      p.setDensity(1);
      p.setDrawable(false);
      p.setGrabbable(false);
      if(current!=null)
      {
        for(int e=0;e<current.getEdgeNb();e+=8)
        {
          e0 = current.getEdgeVertexA(e);
          e1 = current.getEdgeVertexB(e);
          if(abs(dist(e0.x,e0.y,e1.x,e1.y))<2)
          {
            float vx = (e0.x+e1.x)*0.5;
            float vy = (e0.y+e1.y)*0.5;
            p.vertex(vx*width,vy*height);
          }
        }
        foundBlobs.add(current);
      }
      world.add(p);
      labelBlobs.add(p);
    }
    world.step();
    world.draw(this);
    
    for(Blob fb : foundBlobs)
    {
        for(int e=0;e<fb.getEdgeNb();e+=4)
        {
          e1 = fb.getEdgeVertexA(e);
          stroke(255);
          strokeWeight(4);
          noFill();
          point(e1.x*width,e1.y*height);
        }
    }
    for(FPoly wp : labelBlobs)
    {
      world.remove(wp);
    }
    labelBlobs.clear();
    foundBlobs.clear();    
  }
  session.ReleaseFrame();
}

void stop()
{
  super.stop();
  session.Close();
}

void addCircles()
{
  for(int i=0;i<3;i++)
  {
    FCircle c = new FCircle(10);
    c.setNoStroke();
    c.setFill(255,255,255);
    c.setPosition(random(0,width),0);
    c.setVelocity(0,random(10,50));
    c.setRestitution(0.1);
    c.setDamping(0.1);
    //c.setDrawable(false);
    c.attachImage((PImage)flakes.get((int)random(5)));
    c.setGrabbable(false);
    counter = 1-counter;
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
