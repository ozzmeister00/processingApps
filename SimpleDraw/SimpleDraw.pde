import intel.pcsdk.*;

float[] m_hand_pos = new float[4];
float[] s_hand_pos = new float[4];

float open_threshold = 15;

PXCUPipeline session;
//PXCMGesture.GeoNode m_hand_node = new PXCMGesture.GeoNode();
//PXCMGesture.GeoNode s_hand_node = new PXCMGesture.GeoNode();

class Hand
{
  public PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  
  public boolean primary = true; 
  public float openness = 0;
  public float x = 0;
  public float y = 0;
  public float z = 0; // distance from camera
  public boolean visible = false;
  
  public void update ()
  {
    if(primary) 
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
      {   
        x = map(hand.positionImage.x, 0, 320, 640, 0);
        y = map(hand.positionImage.y, 0, 320, 0, 640);
        z = map(hand.positionWorld.y, 0, 1, 100, 0);
        openness = hand.openness;
        //openness = map(hand.openness, 0, 100, 0, 255);
        visible = true;        
      }
      else
      {
        visible = false;  
      }
    }
    else
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
      {   
        x = map(hand.positionImage.x, 0, 320, 640, 0);
        y = map(hand.positionImage.y, 0, 320, 0, 640);
        z = map(hand.positionWorld.y, 0, 1, 100, 0);
        openness = hand.openness;
        //openness = map(hand.openness, 0, 100, 0, 255);
        visible = true;        
      }
      else
      {
        visible = false;  
      }
    }
  }
}

Hand s_hand, m_hand;

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
  {
    exit();
  }

  m_hand = new Hand();
  s_hand = new Hand();

  s_hand.primary = false;
 
  background(0); 
}

void draw()
{
  background(0);
  if(session.AcquireFrame(false))
  {
   m_hand.update();
   s_hand.update();
   session.ReleaseFrame(); 
  }
  
  // set the fill color
  fill(255, 255, 255);
  stroke(255, 0, 0);
  
  if(m_hand.visible)
  {
    ellipse(m_hand.x, m_hand.y, m_hand.openness, m_hand.openness);
  } 
  if(s_hand.visible)
  {
    ellipse(s_hand.x, s_hand.y, s_hand.openness, s_hand.openness); 
  }
  
  // control radius of ellipse with distance between two completely closed hands
  
  // use one completely open hand for 
  // exit the application if it detects a wave
}
