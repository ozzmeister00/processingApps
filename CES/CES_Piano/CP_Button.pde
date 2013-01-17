color[] FILL_COLORS = {color(242,143,24), color(222,73,30), color(146,185,30), color(41,172,214)};

                       
class Button
{
  boolean mTouched;
  boolean mPlayed;
  int mCounter;
  String mNote;
  PVector mPos;
  color mFill;
  
  Button(){}
  
  Button(int px, int py, String pnote)
  {
    this.mTouched = false;
    this.mPos = new PVector(px,py);
    this.mNote = pnote;
  }
  
  void touched()
  {
    if(!this.mTouched)
    {
      this.mTouched = true;
      this.mCounter = 30;
      this.mFill = FILL_COLORS[(int)random(FILL_COLORS.length)];
      if(playing<MAX_VOICES)
      {
        this.mPlayed = true;
        playing+=1;
        aOut.playNote(0.0,0.5,this.mNote);
      }
    }
  }
  void step()
  {
    if(this.mCounter>0)
      --this.mCounter;
    if(this.mCounter==15)
    {
      if(this.mPlayed)
        playing -=1;
      this.mPlayed = false;
    }
    
    if(this.mCounter==0)
    {
      this.mTouched = false;
    }
  }
  
  void display()
  {
    pushStyle();
    noFill();
    stroke(255);
    strokeWeight(1);
    ellipse(this.mPos.x,this.mPos.y,80,80);
    if(this.mTouched&&this.mCounter>0)
    {
      pushStyle();
      noStroke();
      fill(this.mFill,map(this.mCounter,0,30,0,255));
      ellipse(this.mPos.x,this.mPos.y,80,80);
      popStyle();
    }
    popStyle();
  }
}
