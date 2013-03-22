/*******************************************************************************
 
 INTEL CORPORATION PROPRIETARY INFORMATION
 This software is supplied under the terms of a license agreement or nondisclosure
 agreement with Intel Corporation and may not be copied or disclosed except in
 accordance with the terms of that agreement
 Copyright(c) 2012 Intel Corporation. All Rights Reserved.
 
 *******************************************************************************/
//Updated to Beta3
import intel.pcsdk.*;
PXCUPipeline session;
Hands hands;

void setup() {
  size(320, 240);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.GESTURE);
  hands = new Hands(); //requires PXCUPipeline session to init(PXCUPipeline.GESTURE)
}

void draw() { 

  hands.update(session);
  //How to access the image
  image(hands.labelMapImage, 0, 0);

  if (mousePressed) {
    hands.drawHands();
  }
  else { 
    fill(255, 190, 50, 100);
    //How to access the fingertips for each hand
    for (int i = 0;i<5;i++) {
      if (hands.primaryHand[i].x >0) { //check to see if it's null
        ellipse(hands.primaryHand[i].x, hands.primaryHand[i].y, hands.primaryHand[i].z, hands.primaryHand[i].z);
      }
      if (hands.secondaryHand[i].x >0) { //check to see if it's null
        ellipse(hands.secondaryHand[i].x, hands.secondaryHand[i].y, hands.secondaryHand[i].z, hands.secondaryHand[i].z);
      }
    }
  }
}

