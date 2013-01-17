import ddf.minim.*;
import ddf.minim.ugens.*;
import intel.pcsdk.*;

int MAX_VOICES = 16;
String[] NOTES = {"C7","D7","E7","F7","G7","A7","B7","C8",
                  "C6","D6","E6","F6","G6","A6","B6","C7",
                  "C5","D5","E5","F5","G5","A5","B5","C6",
                  "C4","D4","E4","F4","G4","A4","B4","C5",
                  "C3","D3","E3","F3","G3","A3","B3","C4",
                  "C2","D2","E2","F2","G2","A2","B2","C3",
                  "C7","D7","E7","F7","G7","A7","B7","C8",
                  "C6","D6","E6","F6","G6","A6","B6","C7",
                  "C5","D5","E5","F5","G5","A5","B5","C6",
                  "C4","D4","E4","F4","G4","A4","B4","C5",
                  "C3","D3","E3","F3","G3","A3","B3","C4",
                  "C2","D2","E2","F2","G2","A2","B2","C3"                  
                  };

int playing = 0;
short[] depth;
int[] dm;
color xmin = color(238,146,21);
color xmax = color(222,73,30);
color ymin = color(148,187,20);
color ymax = color(33,159,210);


PImage depthMap;
//ArrayList<Button> buttons = new ArrayList();
Button[] buttons = new Button[48];

PXCUPipeline session;
Minim minim;
AudioOutput aOut;

int[] fingertips = {  PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING,
                      PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY};

 
void setup()
{
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.DEPTH_QVGA|PXCUPipeline.GESTURE);

  dm = session.QueryDepthMapSize();
  if(dm!=null)
  {
    depth = new short[dm[0]*dm[1]];
    depthMap = createImage(dm[0],dm[1],RGB);
  }
    
  size(640,480,P2D);
  ellipseMode(CORNER);
  noStroke(); 

  int b=0;  
  for(int y=0;y<height;y+=80)
  {
    for(int x=0;x<width;x+=80)
    {
      //buttons.add(new Button(x,y,"C3"));
      buttons[b] = new Button(x,y,NOTES[b]);
      b++;
    }
  }
  frameRate(30);
  
  minim = new Minim(this);
  aOut = minim.getLineOut();
  println(buttons.length);
}

void draw()
{
  background(0);
  if(!session.AcquireFrame(true))
    return;
  //PXCUPipeline.QueryLabelMapAsImage(labelMap);
  session.QueryDepthMap(depth);
  if(depth!=null)
  {
    depthMap.loadPixels();
    for(int p=0;p<depth.length;p++)
    {
      float t = 255-(constrain(map(depth[p],100,1000,0,255),0,255));
      depthMap.pixels[p] = color(t,t,t);
    }
    depthMap.updatePixels();
    pushMatrix();
    translate(640,0);
    scale(-1,1);  
    image(depthMap,0,0,640,480);
    popMatrix();
  }

  //for(int b=0;b<buttons.size();b++)
  for(int b=0;b<buttons.length;b++)
  {
    //Button cb = (Button)buttons.get(b);    
    for(int t=0;t<fingertips.length;t++)
    {
      PXCMGesture.GeoNode tip = session.QueryGeoNode(fingertips[t]);
      if(tip!=null)
      {
        int pix=(int)(width-(tip.positionImage.x*2));
        int piy = (int)(tip.positionImage.y*2);
        //if(abs(dist(pix,piy,cb.mPos.x,cb.mPos.y))<31)
        if(abs(dist(pix,piy,buttons[b].mPos.x,buttons[b].mPos.y))<31)
        {
          //cb.touched();
          buttons[b].touched();
          break;
        }
      }
    }
    //cb.step();
    //cb.display();
    buttons[b].step();
    buttons[b].display();
  }
  
  session.ReleaseFrame();
}

void stop()
{
  session.Close();
  minim.stop();
  super.stop();
 
}
