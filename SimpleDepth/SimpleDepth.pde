import intel.pcsdk.*; //import the Intel Perceptual Computing SDK

int[] depth_size = new int[2];
short[] depthMap;
PImage depthImage;

PXCUPipeline session;

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.DEPTH_QVGA);

  //SETUP DEPTH MAP
  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }
}

void draw()
{ 
  if (session.AcquireFrame(false))
  {
    session.QueryDepthMap(depthMap);    
    float remapMouseX = map(mouseX, 0, width, 255, 8192);
    
    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
    {
      depthImage.pixels[i] = color(map(depthMap[i], 0, remapMouseX, 0, 255));
    }
    depthImage.updatePixels();
    session.ReleaseFrame();//VERY IMPORTANT TO RELEASE THE FRAME    
  }
  image(depthImage, 0, 0, 640, 480);
}

