import intel.pcsdk.*;

PXCUPipeline session;
String lastRecognized = "";
String[] commands = {"hello", "new york", "hello new york"};


void setup()
{
  size(640, 480);
  session = new PXCUPipeline(this);
  session.Init(PXCUPipeline.VOICE_RECOGNITION);  
  session.SetVoiceCommands(commands);
}


void draw()
{
  background(0);
  textSize(12); 
  text("Say 'hello' or 'new york' or 'hello new york'", 5, 15);
  textSize(30);
  
  if(session.AcquireFrame(true))
  {
    PXCMVoiceRecognition.Recognition recoData = new PXCMVoiceRecognition.Recognition();
    if(session.QueryVoiceRecognized(recoData))
      lastRecognized = recoData.dictation;      
    session.ReleaseFrame();
  }
  
  text(lastRecognized, 100, 250);
}
