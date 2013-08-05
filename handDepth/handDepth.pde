import intel.pcsdk.*; //import the Intel Perceptual Computing SDK

int[] depth_size = new int[2];
short[] depthMap;
PImage depthImage;
float handOpen = 4096;

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.DEPTH_QVGA);
  if(!session.Init(PXCUPipeline.GESTURE))
    exit();

  //SETUP DEPTH MAP
  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }
}

void draw()
{ 
  background(0);
  if (session.AcquireFrame(false))
  {
    session.QueryDepthMap(depthMap);
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      handOpen = map(hand.openness, 0, 100, 255, 8192);
    }
    
    //REMAPPING THE DEPTH IMAGE TO A PIMAGE
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
    {
      depthImage.pixels[i] = color(map(depthMap[i], 0, handOpen, 0, 255));
    }
    depthImage.updatePixels();
    
    session.ReleaseFrame();       
  }
  image(depthImage, 0, 0, 640, 480);
}
