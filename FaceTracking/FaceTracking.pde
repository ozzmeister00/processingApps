import intel.pcsdk.*;

int sw = 640;
int sh = 480;

ArrayList<PVector> tracked = new ArrayList(1);
PImage colorImage;
PXCUPipeline session;
PXCMFaceAnalysis.Landmark.LandmarkData[] facePts;

int faceLabels[] = {PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_OUTER_CORNER,
                    PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_INNER_CORNER,
                    PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_OUTER_CORNER,
                    PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_INNER_CORNER,                    
                    PXCMFaceAnalysis.Landmark.LABEL_MOUTH_LEFT_CORNER,
                    PXCMFaceAnalysis.Landmark.LABEL_MOUTH_RIGHT_CORNER};

void setup()
{
  size(sw,sh,OPENGL);
  noFill();
  noStroke();
  
  colorImage = createImage(640,480,RGB);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.FACE_LANDMARK|PXCUPipeline.COLOR_VGA);
}

void draw()
{
  tracked.clear();
  if(!session.AcquireFrame(true))
    return;
  
  session.QueryRGB(colorImage);
  image(colorImage,0,0);  
  int[] faces = session.QueryFaceID();
  pushStyle();  
  if(faces!=null)
  {
    for(int f=0;f<faces.length;f++)
    {
      PXCMFaceAnalysis.Detection.Data faceLoc = session.QueryFaceLocationData(faces[f]);
      if(faceLoc!=null)
      {
        stroke(255);
        strokeWeight(2);
        rect(faceLoc.rectangle.x,faceLoc.rectangle.y,faceLoc.rectangle.w,faceLoc.rectangle.h);
        for(int i=0;i<faceLabels.length;i++)
        {
          facePts = session.QueryFaceLandmarkData(faces[f],faceLabels[i]);
          if(facePts!=null)
          {
            for(int p=0;p<facePts.length;p++)
            {
              pushStyle();
              fill(255);
              ellipse(facePts[p].position.x,facePts[p].position.y,5,5);
              popStyle();
            }
          }
        }
      }
    }
  }
  popStyle();  
  session.ReleaseFrame();
}


