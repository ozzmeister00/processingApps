import intel.pcsdk.*;

float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
    exit();
}

void draw()
{
  background(0);
  if(session.AcquireFrame(false))
  {
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      mHandPos[0] = hand.positionImage.x;
      mHandPos[1] = hand.positionImage.y;
      mHandPos[2] = hand.positionWorld.y;
      mHandPos[3] = hand.openness;
    }
    session.ReleaseFrame(); //must do tracking before frame is released
  }
  
  //DRAW SOMETHING!!!
  float invertedPositionImageX = map(mHandPos[0], 0, 320, 640, 0); //flip our X axis by using the map fuction
  float openness = map(mHandPos[3], 0, 100, 0, 255);
  float distance = map(mHandPos[2], 0, 1, 100, 0);
  fill(openness, 90, 30); 
  ellipse(invertedPositionImageX, mHandPos[1]*2, distance, distance);
}

