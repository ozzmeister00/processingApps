import intel.pcsdk.*;

short[] depthMap;
int[] depthMapSize = new int[2];

PXCUPipeline session;

void setup()
{
  size(640, 480, OPENGL);
  stroke(0, 255, 255);
  strokeWeight(3);
  noFill();

  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.DEPTH_QVGA))
    exit();

  session.QueryDepthMapSize(depthMapSize);
  depthMap = new short[depthMapSize[0] * depthMapSize[1]];
}

void draw()
{
  background(0, 32, 32);

  translate(width/2, height/2, -200);  
  rotateY(radians(180+mouseX));

  if(session.AcquireFrame(false))
  {
    session.QueryDepthMap(depthMap);
    session.ReleaseFrame();
  }
  
  translate(0, 0, -500);

  for (int x = 0; x < depthMapSize[0]; x+=2)
  {
    for (int y = 0; y < depthMapSize[1]; y+=2)
    {
      int i_p = y*320+x;
      int px = (int)(map(x*2, 0, 640, -320, 320));
      int py = (int)(map(y*2, 0, 480, -240, 240));
      point(px, py, depthMap[i_p]);
    }
  }


}

