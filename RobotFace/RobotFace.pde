//Updating to Beta3

import processing.opengl.*;
import intel.pcsdk.*;


Landmarks lm;
PXCUPipeline session;

void setup()
{
  size(640, 480, P3D);

  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.FACE_LANDMARK|PXCUPipeline.COLOR_VGA);

  lm = new Landmarks(); //requires the PXCUPipeline session to init(PXCUPipeline.FACE_LANDMARK|PXCUPipeline.COLOR_VGA)
}

void draw()
{
  lm.update(session);
  image(lm.colorImage, 0, 0);  //draw our colorImage
  
  if (mousePressed) {
    lm.drawFace(); //quick way to show face, but not terribly useful
  } 
  else {

    //how to get the data
    pushStyle();  

    fill(0, 90, 250, 100);
    rect(lm.faceX, lm.faceY, lm.faceWidth, lm.faceHeight);

    fill(40, 255, 80, 100);
    ellipse(lm.rightEye.x, lm.rightEye.y, lm.rightEye.z, lm.rightEye.z);
    ellipse(lm.leftEye.x, lm.leftEye.y, lm.leftEye.z, lm.leftEye.z);
    rectMode(RADIUS);
    fill(255, 0, 0, 100);
    rect(lm.mouth.x, lm.mouth.y, lm.mouth.z/2, map(mouseY, 0, height, 30, 3));


    for (int i = 0;i<6;i++) {
      fill(25, 25, 255, 200);
      ellipse(lm.spots[i].x, lm.spots[i].y, 10, 10);
    }
    popStyle();
  }

}

