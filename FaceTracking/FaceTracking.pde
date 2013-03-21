//Updating to Beta3

import processing.opengl.*;
import intel.pcsdk.*;

int sw = 640;
int sh = 480;

ArrayList<PVector> tracked = new ArrayList(1);
PImage colorImage;
PXCUPipeline session;
PXCMFaceAnalysis.Landmark.LandmarkData[] facePts;

int faceLabels[] = {
  PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_OUTER_CORNER, 
  PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_INNER_CORNER, 
  PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_OUTER_CORNER, 
  PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_INNER_CORNER, 
  PXCMFaceAnalysis.Landmark.LABEL_MOUTH_LEFT_CORNER, 
  PXCMFaceAnalysis.Landmark.LABEL_MOUTH_RIGHT_CORNER
};

void setup()
{
  size(sw, sh, P3D);
  noFill();
  noStroke();

  colorImage = createImage(640, 480, RGB);
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.FACE_LANDMARK|PXCUPipeline.COLOR_VGA)) {
    println("Failed to intiialize");
    exit();
  }
}

void draw()
{
  tracked.clear();
  if (!session.AcquireFrame(true))
    return;

  session.QueryRGB(colorImage);
  image(colorImage, 0, 0);  

  long[] faces = new long [4]; //how many faces do you intend to track? times 2
  if (session.QueryFaceID(0, faces)) {
   
    for (int f=0;f<faces.length;f+=2)
    {
       int faceId = int(faces[f]);

      PXCMFaceAnalysis.Detection.Data faceLoc;
      faceLoc = new PXCMFaceAnalysis.Detection.Data();
      if (session.QueryFaceLocationData(faceId, faceLoc)) {

       
        pushStyle();  
        stroke(255);
        strokeWeight(2);
        rect(faceLoc.rectangle.x, faceLoc.rectangle.y, faceLoc.rectangle.w, faceLoc.rectangle.h);
        popStyle();

        for (int i=0;i<faceLabels.length;i++)
        {
          PXCMFaceAnalysis.Landmark.LandmarkData facePts2 = new PXCMFaceAnalysis.Landmark.LandmarkData();
          session.QueryFaceLandmarkData(faceId, i, faceId, facePts2);

          if (facePts2!=null)
          {
            //println("found a face");
            pushStyle();
            fill(255);
            ellipse(facePts2.position.x, facePts2.position.y, 5, 5);
            popStyle();
          }
        }
      }
    }
  }

  session.ReleaseFrame();
}

