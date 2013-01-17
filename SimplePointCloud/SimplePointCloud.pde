//import processing.opengl.*;
import intel.pcsdk.*;

int sWidth = 640;
int sHeight = 480;
int maxDepth = 900;
boolean debug=false;
boolean drawRGB=false;
boolean rgbPts=true;
short[] depthMap;
int[] depthMapSize;
PImage colorImage;

PXCUPipeline session;

void setup()
{
  stroke(0,255,0);
  strokeWeight(2);
  noFill();
  size(sWidth, sHeight, OPENGL);
  
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.DEPTH_QVGA|PXCUPipeline.COLOR_VGA)) exit();
  depthMapSize = session.QueryDepthMapSize();
  depthMap = new short[depthMapSize[0] * depthMapSize[1]];
  colorImage = createImage(640,480,RGB);
}

void draw()
{
  background(0,32,0);
  pushMatrix();
  translate(width/2,height/2,-200);  
  rotateY(radians(180+mouseX));
  if(debug)
  {
    pushStyle();
    strokeWeight(3);
    box(640,480,400);
    popStyle();
  }

  if(session.AcquireFrame(true))
  {
    session.QueryDepthMap(depthMap);
    session.QueryRGB(colorImage);
    if(drawRGB)
    {
      pushMatrix();
      translate(-320,-240,200);
      image(colorImage,0,0);
      popMatrix();
    }
    colorImage.loadPixels();
    
    for (int x = 0; x < depthMapSize[0]; x+=2)
    {
      for(int y = 0; y < depthMapSize[1]; y+=2)
      {
        int i_p = y*320+x;
        if(depthMap[i_p]<maxDepth)
        {
          pushStyle();
          color fc = color(0,255,0);
          if(rgbPts)
            fc = getColorFromDepth(x,y);
          stroke(fc);
          strokeWeight(3);
          pushMatrix();
          translate(0,0,-500);
          int px = (int)(map(x*2,0,640,-320,320));
          int py = (int)(map(y*2,0,480,-240,240));
          point(px,py,depthMap[i_p]*0.8);
          popMatrix();
          popStyle();
        }
      }
    }
    popMatrix();
    session.ReleaseFrame();
  }
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


