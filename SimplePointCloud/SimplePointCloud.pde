//Updated to Beta3
//import processing.opengl.*;
import intel.pcsdk.*;

boolean debug=true;
boolean drawRGB=true;
boolean rgbPts=true;
boolean useIR=true;

short[] depthMap;
short[] irMap;

int maxDepth = 900;
int ptSize = 1;

int[] depthMapSize = new int[2];
int[] uvMapSize = new int[2];
int[] rgbMapSize = new int[2];
int[] irMapSize = new int[2];

float[] uvMap;

ArrayList<PVector> pointCloud = new ArrayList<PVector>();

PImage colorImage;

PXCUPipeline session;

void setup()
{
  stroke(0,255,0);
  strokeWeight(2);
  noFill();
  size(640,480,P3D);
  
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.DEPTH_QVGA|PXCUPipeline.COLOR_VGA)) exit();
  
  session.QueryDepthMapSize(depthMapSize);
  depthMap = new short[depthMapSize[0] * depthMapSize[1]];
  
  session.QueryUVMapSize(uvMapSize);
  uvMap = new float[uvMapSize[0] * uvMapSize[1] * 2];
  
  session.QueryRGBSize(rgbMapSize);
  colorImage = createImage(rgbMapSize[0],rgbMapSize[1],RGB);
  
  session.QueryIRMapSize(irMapSize);
  irMap = new short[irMapSize[0]*irMapSize[1]];
}

void draw()
{  
  if(session.AcquireFrame(false))
  {
    pointCloud.clear();
    session.QueryDepthMap(depthMap);
    session.QueryRGB(colorImage);
    session.QueryUVMap(uvMap);
    if(useIR)
      session.QueryIRMap(irMap);
    colorImage.loadPixels();
    
    for (int x=0;x<depthMapSize[0];++x)
    {
      for(int y=0;y<depthMapSize[1];++y)
      {
        int i_p = y*depthMapSize[0]+x;
        if(depthMap[i_p]<maxDepth)
          pointCloud.add(new PVector(x,y,depthMap[i_p]));
      }
    }
    session.ReleaseFrame();
  }
  
  background(0,32,0);
  pushMatrix();
  translate(width/2,height/2,0);  
  rotateY(radians(map(mouseX,0,width,-180,180)));
  if(debug)
  {
    pushStyle();
    strokeWeight(3);
    box(640,480,400);
    popStyle();
  }
  
  if(drawRGB)
  {
    pushMatrix();
    translate(-320,-240,200);
    image(colorImage,0,0);
    popMatrix();
  }
  
  pushMatrix();
  translate(0,0,-450);
  colorImage.loadPixels();
  boolean drawPoint = false;
  pushStyle();
  for(int p=0;p<pointCloud.size();++p)
  {
    drawPoint = false;
    stroke(0,255,0);
    
    PVector pt = (PVector)pointCloud.get(p);
    if(useIR)
      strokeWeight(map((float)irMap[(int)pt.y*irMapSize[0]+(int)pt.x],0,3000,1,10));
    else
      strokeWeight(ptSize);
    int cx = (int)(uvMap[((int)pt.y*depthMapSize[0]+(int)pt.x)*2]*rgbMapSize[0]+0.5f);
    int cy = (int)(uvMap[((int)pt.y*depthMapSize[0]+(int)pt.x)*2+1]*rgbMapSize[1]+0.5f);
    if (cx >= 0 && cx < rgbMapSize[0] && cy >= 0 && cy < rgbMapSize[1] && rgbPts)
    {
      drawPoint = true;
      stroke(colorImage.pixels[cy*rgbMapSize[0]+cx]);
    }
    else
    {
      if(!rgbPts)
      {
        drawPoint = true;
        stroke(0,255,0);
      }
      else
      {
        drawPoint = false;
      }
    }
    if(drawPoint)
      point(map(pt.x,0,320,-320,320),map(pt.y,0,240,-240,240),pt.z*0.8);
  }
  popStyle();
  popMatrix();
  popMatrix();
}

void keyPressed()
{
  if(key=='c')
    drawRGB=!drawRGB;
  if(key=='d')
    debug=!debug;
  if(key=='p')
    rgbPts=!rgbPts;
  if(key=='i')
    useIR=!useIR;
  if(key=='a')
  {
    --ptSize;
    if(ptSize<=0)
      ptSize=1;
  }
  if(key=='s')
  {
    ++ptSize;
  }
}
