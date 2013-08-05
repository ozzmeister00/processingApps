import intel.pcsdk.*;

PXCUPipeline session;
PImage rgbTex;

float overlay ( float source, float base )
{
    float retVal = 0.0;
    if(source > 0.5)
    {
      retVal = 2 * source * base;
    }
    else
    {
      retVal = 1 - 2 * (1 - source) * (1 - base);
    }
    return map(retVal, 0, 1, 0, 255);
}

void setup()
{
  size(640,480);
  rgbTex = createImage(640,480,RGB);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.COLOR_VGA|PXCUPipeline.FACE_LOCATION|PXCUPipeline.FACE_LANDMARK);
}

void draw()
{
  if(session.AcquireFrame(false))
  {
    session.QueryRGB(rgbTex);
    session.ReleaseFrame();
  }
  if(true)
  {
    for(int x=0;x < rgbTex.width; x++)
    {
      for(int y=0;y < rgbTex.height; y++)
      {
        color currPixel = rgbTex.get(x, y);
        float fRed = red(currPixel);
        float fGreen = green(currPixel);
        float fBlue = blue(currPixel);
        
        float nRed = map(fRed, 0, 255, 0, 1);
        float nGreen = map(fGreen, 0, 255, 0, 1);
        float nBlue = map(fBlue, 0, 255, 0, 1);
        
        rgbTex.set(x, y, color(overlay(nRed, nRed), overlay(nGreen, nGreen), overlay(nBlue, nBlue)));
      } 
    }
  }
  image(rgbTex,0,0);
}
