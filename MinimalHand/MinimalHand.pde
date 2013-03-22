//Beta3 - Minimalist hand example
import intel.pcsdk.*;
PXCUPipeline session;
void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.GESTURE);
}

void draw()
{
  background(0); 
  session.AcquireFrame(true);
  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand); 
  
  //DRAW SOMETHING!!!
  float invertedPositionImageX = map(hand.positionImage.x, 0, 320, 640, 0); //flip our X axis by using the map fuction
  float openness = map(hand.openness, 0, 100, 0, 255);
  float distance = map(hand.positionWorld.y, 0, 1, 100, 0);
  fill(openness, 90, 30); 
  ellipse(invertedPositionImageX, hand.positionImage.y*2, distance, distance);
  
  session.ReleaseFrame(); //must do tracking before frame is released
}

