//Updated to Beta3
//import processing.opengl.*;
import intel.pcsdk.*;

boolean debug=true;
boolean drawRGB=true;
boolean rgbPts=true;

short[] depthMap;

int maxDepth = 900;
int[] depthMapSize = new int[2];
int[] uvMapSize = new int[2];

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
  
  colorImage = createImage(640,480,RGB);
}

void draw()
{  
  if(session.AcquireFrame(false))
  {
    pointCloud.clear();
    session.QueryDepthMap(depthMap);
    session.QueryRGB(colorImage);
    session.QueryUVMap(uvMap);
    colorImage.loadPixels();
    
    for (int x=0;x<depthMapSize[0];++x)
    {
      for(int y=0;y<depthMapSize[1];++y)
      {
        int i_p = y*320+x;
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
  translate(-160,-120,-400);
  colorImage.loadPixels();
  for(int p=0;p<pointCloud.size();++p)
  {
    stroke(0,255,0);
    strokeWeight(2);
    PVector pt = (PVector)pointCloud.get(p);
    int cx = (int)(uvMap[((int)pt.y*depthMapSize[0]+(int)pt.x)*2]*640+0.5f);
    int cy = (int)(uvMap[((int)pt.y*depthMapSize[0]+(int)pt.x)*2+1]*480+0.5f);
    if (cx >= 0 && cx < 640 && cy >= 0 && cy < 480 && rgbPts)
    {
      stroke(colorImage.pixels[cy*640+cx]);
    }
    else
      stroke(0,255,0);
    
    point(pt.x,pt.y,pt.z*0.5);
  }
  popMatrix();
  popMatrix();
}

void keyPressed()
{
  if(key=='c')
  {
    drawRGB=!drawRGB;
  }
  if(key=='d')
  {
    debug=!debug;
  }
  if(key=='p')
    rgbPts=!rgbPts;
}

color getColorFromDepth(int px, int py)
{
  int i_c = (py*2)*640+(px*2);
  color _c = colorImage.pixels[i_c];
  int _r = (_c>>16)&0xFF;
  int _g = (_c>>8)&0xFF;
  int _b = _c&0xFF;
  return color(_r,_g,_b,255);
}


