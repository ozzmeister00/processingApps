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
  //background(0);
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
  
  //float openness = map(mHandPos[3], 0, 100, 0, 255);
  if(mHandPos[3] > 15)
  { 
    background(0, 255, 0);
  } 
  else
  {
    background(255, 0, 0);  
  }
}

