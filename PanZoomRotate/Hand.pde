

class Hand
{
	PXCUPipeline perc;
	
	// play with this to get more or less sensitive grab detection
	final int OPEN_THRESHOLD = 25;
	
	// hand tracking
	public PXCMGesture.GeoNode hand = null;
	PXCMGesture.GeoNode prevHand = null;
	
	PImage spotlightImg = loadImage("spotlight.png");
	boolean visible;
	
	public PVector screenCoords = new PVector(0.0, 0.0);   // screen coords of hand position
	public PVector prevScreenCoords = new PVector(0.0, 0.0);  // screen coords from the previous frame
	public PVector depthCoords = new PVector(0.0, 0.0);   // (depth) image coords of hand position
	public PVector closeCoords = new PVector(0.0, 0.0);   // screen coords where the hand was first closed
	
	Smooth op = new Smooth(2);  // for smoothing the openness data
	Smooth posSmooth = new Smooth(2);  // for smoothing the screenCoords
	
	
	
	public Hand(PXCUPipeline pp)
	{
		perc = pp;
                PXCMGesture.GeoNode geoHand = new PXCMGesture.GeoNode();
                perc.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_LEFT, geoHand);
	}
	
	
	public void updateHand(int nodeType) //did have geonode here
	{
                PXCMGesture.GeoNode newHand = new PXCMGesture.GeoNode();
                boolean haveHand = perc.QueryGeoNode(nodeType, newHand);
 
		prevHand = hand;
		hand = newHand;
		
		if(haveHand)
		{
			visible = true;
			
			prevScreenCoords.x = screenCoords.x;
			prevScreenCoords.y = screenCoords.y;
			
			screenCoords.x = map(hand.positionImage.x, 0, depthW, width, 0);
			screenCoords.y = map(hand.positionImage.y, 0, depthH, 0, height);
			screenCoords = posSmooth.smoothVector(screenCoords);
			
			depthCoords.x = hand.positionImage.x;
			depthCoords.y = hand.positionImage.y;
			
			if(isClosed() && !wasClosed())
				closeCoords = screenCoords;
		}
		else
                {
			visible = false;
                        hand = null;
                }
	}
	
	
	public boolean isClosed()    // is currently closed in this frame?
	{
		if(hand != null)
			return hand.openness < OPEN_THRESHOLD;
		else
			return false;
	}
	
	public boolean wasClosed()  // was it closed in the previous frame?
	{
		if(prevHand != null)
			return prevHand.openness < OPEN_THRESHOLD;
		else
			return false;
	}
	
	
	public void display()
	{
		if(hand == null || !visible)
			return;
		
		noStroke();
		
		if(isClosed())
			tint(200, 200, 50, 255);
		else
			tint(200, 80);
		
		float sz = map(op.smoothValue(hand.openness), 0, 100, 0.4, 1.0);
		
		// draw the hand feedback...a spotlight
		imageMode(CENTER);
		pushMatrix();
		translate(screenCoords.x, screenCoords.y);
		image(spotlightImg, 0, 0, spotlightImg.width*sz, spotlightImg.height*sz);
		popMatrix();
		imageMode(CORNER);
	}
	
}
