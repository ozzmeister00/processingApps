import intel.pcsdk.*;

float[] m_hand_pos = new float[4];
float[] s_hand_pos = new float[4];

float openThreshold = 15;

float radius = 50;

PXCUPipeline session;
//PXCMGesture.GeoNode m_hand_node = new PXCMGesture.GeoNode();
//PXCMGesture.GeoNode s_hand_node = new PXCMGesture.GeoNode();

class Hand
{
  public PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  
  // change this to control how much dampening you want on the hand values
  private int smoothSize = 10;
  
  public boolean right = true; 
  
  // used for smoothing out raw position data from the camera
  private float[] xList = new float[smoothSize];
  private float[] yList = new float[smoothSize];
  private float[] zList = new float[smoothSize];
  private float[] openList = new float[smoothSize];
  
  // used for publically accessing current, dampened, hand position
  public float x = 0;
  public float y = 0;
  public float z = 0; // distance from camera
  public float openness = 0;
  public boolean visible = false;
  
  private float smoothVals ( float[] list, float newVal )
  {
   // loops over the list of values whose length is determined by the 
   // private "smoothSize" variable. Moves each value one place to the left
   // and adds the newest value to the end of the input list
   // and returns the average of the sum of the list
    float sum = 0;
   int i = 0;
   for(i=0; i < smoothSize; i++)
   {
    int j = i + 1;
    if(j == smoothSize)
    {
      list[i] = newVal;
    }  
    else
    {
      list[i] = list[j]; 
    }
    sum += list[i];
   }
   
   return sum / smoothSize;
  }
  
  public void update ()
  {
    if(right) 
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_RIGHT, hand)) { visible = true; }
      else { visible = false; }  
    }
    else 
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_LEFT, hand)) { visible = true; } 
      else { visible = false; }  
    }
    if(visible)
    {
      x = smoothVals(xList, map(hand.positionImage.x, 0, 320, 640, 0));
      y = smoothVals(yList, map(hand.positionImage.y, 0, 320, 0, 640));
      z = smoothVals(zList, map(hand.positionWorld.y, 0, 1, 100, 0));
      openness = smoothVals(openList, hand.openness);
    }
  }
}

float distance ( float x1, float y1, float x2, float y2 )
{
  return sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2));
}

Hand l_hand, r_hand;

void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
  {
    exit();
  }

  l_hand = new Hand();
  r_hand = new Hand();

  l_hand.right = false;
 
  background(0); 
}

void draw()
{
  //background(0);
  if(session.AcquireFrame(false))
  {
    l_hand.update();
    r_hand.update();
    session.ReleaseFrame(); 
  }
  
  // set the fill color
  
  // control radius of ellipse with distance between two completely closed hands
  if(r_hand.visible & l_hand.visible & r_hand.openness < openThreshold & l_hand.openness < openThreshold)
  {
    radius = distance(r_hand.x, r_hand.y, l_hand.x, l_hand.y);
  }
  
  // if the right hand is visible and closed, draw  a circle
  if(r_hand.visible & r_hand.openness <= openThreshold)
  {
    fill(255, 255, 255);
    stroke(255, 0, 0);
    ellipse(r_hand.x, r_hand.y, radius, radius);
  }
  // if the right hand is visible and open, use an "eraser"
  else if(r_hand.visible & r_hand.openness > openThreshold)
  {
    fill(0, 0, 0);
    stroke(255, 0, 0);
    ellipse(r_hand.x, r_hand.y, radius, radius);
  }
}
