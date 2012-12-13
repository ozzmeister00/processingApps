import intel.pcsdk.*;

boolean trackFace = true;
int sw = 640;
int sh = 480;
int rmin,rmax;
float ds;
color ib = color(0,0,255);
color iy = color(255,255,0);
ArrayList<PVector> tracked = new ArrayList(1);
PImage colorImage;
PXCUPipeline session;

void setup()
{
  ds = dist(0,0,sw/8,sh/8);  
  rmin = 24;
  rmax = 80;
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.FACE_LOCATION|PXCUPipeline.COLOR_VGA);
  tracked.add(new PVector(0,0));
  size(sw,sh,OPENGL);
  //ellipseMode(RADIUS);
  colorImage = createImage(640,480,RGB);
  noStroke();
  background(16);
}

void draw()
{
  //background(0);
  fill(0,8);
  rect(0,0,width,height);
  int xs = 32;
  int xmax = width/xs;
  int ys = 32;
  int ymax = height/ys;
  tracked.clear();
  if(!session.AcquireFrame(false))
    return;
  
  session.QueryRGB(colorImage);
  image(colorImage,0,0);  
  int[] faces = session.QueryFaceID();
  if(faces!=null)
  {
    for(int f=0;f<faces.length;f++)
    {
      PXCMFaceAnalysis.Detection.Data faceLoc = session.QueryFaceLocationData(faces[f]);
      if(faceLoc!=null)
      {
        println("Face: "+f);
        println(faceLoc.rectangle.x+","+faceLoc.rectangle.y+","+faceLoc.rectangle.w+","+faceLoc.rectangle.h);
        //float rx = (faceLoc.rectangle.x+faceLoc.rectangle.w)/2;
        //float ry = (faceLoc.rectangle.y+faceLoc.rectangle.h)/2;
        //tracked.add(new PVector(width-rx,ry));
        noFill();
        stroke(255);
        strokeWeight(2);
        rect(faceLoc.rectangle.x,faceLoc.rectangle.y,faceLoc.rectangle.w,faceLoc.rectangle.h);
      }
    }
  }

  /*
  for(int y=0;y<height+ys-1;y+=ys)
  {
    for(int x=0;x<width+xs-1;x+=xs)
    {
      PVector f = (PVector)tracked.get(0);
      float dm = dist(f.x,f.y,x,y);
      float t = constrain((1-dm/ds),0,1);
      float wx=lerp(rmin,rmax,t);
      float a = lerp(128,255,t);
      color c = lerpColor(iy,ib,t);
      fill(c,a);
      pushMatrix();
      translate(x,y,t);      
      ellipse(0,0,wx,wx);
      popMatrix();
    }    
  }*/
  
  session.ReleaseFrame();
}


