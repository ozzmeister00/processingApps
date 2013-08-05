import intel.pcsdk.*;

float[] mHandPos = new float[4];
float[] sHandPos = new float[4];

float threshold = 15;

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
PXCMGesture.GeoNode sHand = new PXCMGesture.GeoNode();

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
    // if you can get the hand, update its data
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      mHandPos[0] = mHandPos[1];
      mHandPos[1] = mHandPos[2];
      mHandPos[2] = mHandPos[3];
      mHandPos[3] = hand.openness;
    }
    // if you can get the hand, update its data
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, sHand))
    {
      sHandPos[0] = sHandPos[1];
      sHandPos[1] = sHandPos[2];
      sHandPos[2] = sHandPos[3];
      sHandPos[3] = sHand.openness;
    }
    session.ReleaseFrame(); //must do tracking before frame is released
  }
  // do everything else once we're done with the tracking data
  float mOpen = (mHandPos[0] + mHandPos[1] + mHandPos[2] + mHandPos[3]) / 4;
  float sOpen = (sHandPos[0] + sHandPos[1] + sHandPos[2] + sHandPos[3]) / 4;
  // set the background color based on main and secondary hand openness
  background(map(mOpen, 0, 100, 0, 255), map(sOpen, 0, 100, 0, 255), 0);
}

