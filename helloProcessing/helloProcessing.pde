/*******************************************************************************

INTEL CORPORATION PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or nondisclosure
agreement with Intel Corporation and may not be copied or disclosed except in
accordance with the terms of that agreement
Copyright(c) 2012-2013 Intel Corporation. All Rights Reserved.

*******************************************************************************/
import intel.pcsdk.*;

int mode=PXCUPipeline.GESTURE|PXCUPipeline.COLOR_VGA;

PImage    rgb=null;
PImage    labelmap=null;
short[]   depthmap=null;
PVector[] pos2d=null;
PVector[] posc=null;
float[]   untrusted=new float[2];

PXCUPipeline pp=null;
PXCMFaceAnalysis.Landmark.LandmarkData[] ldata=new PXCMFaceAnalysis.Landmark.LandmarkData[2];
PXCMFaceAnalysis.Detection.Data ddata=new PXCMFaceAnalysis.Detection.Data();
PXCMVoiceRecognition.Recognition rdata=new PXCMVoiceRecognition.Recognition();
PXCMGesture.GeoNode ndata=new PXCMGesture.GeoNode();
long fdata[]=new long[2];

void setup() {
    size(640,480);
    
    pp=new PXCUPipeline(this);
    if (!pp.Init(mode)) {
      print("Failed to initialize PXCUPipeline\n");
    }
    
    //String[] cmds=new String[]{"one","two","three"};
    //pp.SetVoiceCommands(cmds);
    
    int[] csize=new int[2];
    if (pp.QueryRGBSize(csize)) {
        print("RGBSize("+csize[0]+","+csize[1]+")\n");
        rgb=createImage(csize[0],csize[1],RGB);
    }
    int[] dsize=new int[2];
    if (pp.QueryDepthMapSize(dsize)) {
        print("DepthMapSize("+dsize[0]+","+dsize[1]+")\n");
        labelmap=createImage(dsize[0],dsize[1],RGB);
        depthmap=new short[dsize[0]*dsize[1]];
        pp.QueryDeviceProperty(PXCMCapture.Device.PROPERTY_DEPTH_SATURATION_VALUE,untrusted);
        posc=new PVector[dsize[0]*dsize[1]];
        pos2d=new PVector[dsize[0]*dsize[1]];
        for (int xy=0,y=0;y<dsize[1];y++)
            for (int x=0;x<dsize[0];x++,xy++)
                pos2d[xy]=new PVector(x,y,0);        
    }
}
 
void draw() { 
    if (pp.AcquireFrame(false)) {
      if (pp.QueryRGB(rgb)) {
          if (depthmap!=null) if (pp.QueryDepthMap(depthmap)) 
              AddProjection();
          image(rgb,0,0);
      } else {
          if (pp.QueryLabelMapAsImage(labelmap)) 
              image(labelmap,0,0);
      }

      if (pp.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_HAND_UPPER,ndata)) 
          print("node: "+ndata.positionImage+"\n");
  
//      PXCMGesture.Gesture gdata=new PXCMGesture.Gesture();
//      if (pp.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY,gdata)) 
//          print("gesture "+gdata.label+"\n");
    
      if (pp.QueryFaceID(0,fdata)) { // print the first face
          if (pp.QueryFaceLocationData((int)fdata[0],ddata)) 
              print("face: id="+fdata[0]+", "+ddata.rectangle+"\n");
          
          if (pp.QueryFaceLandmarkData((int)fdata[0], PXCMFaceAnalysis.Landmark.LABEL_6POINTS, ldata)) {
              float x=(ldata[0].position.x+ldata[1].position.x)/2;
              float y=(ldata[0].position.y+ldata[1].position.y)/2;
              print("landmark left-eye "+fdata[0]+",("+x+","+y+")\n");
          }
      }
      
      if (pp.QueryVoiceRecognized(rdata))
          print("voice recognition: label="+rdata.label+",dictation="+rdata.dictation+"\n");
      pp.ReleaseFrame();
    }
}

void AddProjection() {
    for (int xy=0;xy<pos2d.length;xy++)
        pos2d[xy].z=(float)depthmap[xy];

    if (!pp.MapDepthToColorCoordinates(pos2d,posc)) return;

    for (int xy=0;xy<posc.length;xy++) {
        if (depthmap[xy]==untrusted[0] || depthmap[xy]==untrusted[1]) continue;
        int x1=(int)posc[xy].x, y1=(int)posc[xy].y;
        if (x1<0 || x1>=rgb.width || y1<0 || y1>=rgb.height) continue;
        rgb.set(x1,y1,color(0,255,0));
    }
}

