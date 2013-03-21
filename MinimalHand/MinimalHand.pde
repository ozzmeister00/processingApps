//Beta3 - Minimalist hand example
import intel.pcsdk.*;

PXCUPipeline session;
PImage labelMap;

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.GESTURE);
  int[] labelMapSize = new int[2];
  session.QueryLabelMapSize(labelMapSize);
  labelMap = createImage(labelMapSize[0], labelMapSize[1], RGB);
}

void draw()
{
  background(0);
  session.AcquireFrame(true);
  session.QueryLabelMapAsImage(labelMap);

  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand);

  //DRAW SOMETHING!!!
  ellipse(hand.positionImage.x*2, hand.positionImage.y*2, hand.positionWorld.y*-100, hand.positionWorld.y*-100);
  
  
  session.ReleaseFrame(); //must do tracking before frame is released
}

