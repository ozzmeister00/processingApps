
class Smooth
{
	int SMOOTHING = 4;  // higher number, more smoothing but more latency...
	int smoothingIndex = 0, smoothingVectorIndex = 0;
	float[] smoothingBuffer;
	PVector[] smoothingVectorBuffer;

	public Smooth(int smoothAmt)
	{
		SMOOTHING = smoothAmt;
		smoothingBuffer = new float[SMOOTHING];
		smoothingVectorBuffer = new PVector[SMOOTHING];
		
		// initialize the smoothing buffer
		for(int i=0; i<SMOOTHING; i++)
		{
			smoothingBuffer[i] = -1;
			smoothingVectorBuffer[i] = new PVector(-1.0, -1.0, -1.0);
		}
	}
	
	public Smooth()
	{
		this(4);
	}
	
	float smoothValue(float newVal)
	{
		smoothingBuffer[smoothingIndex] = newVal;
		smoothingIndex++;
		if (smoothingIndex >= SMOOTHING)
			smoothingIndex = 0;
		
		// return average
		float tot = 0;
		int c=0;
		for(int i=0; i<SMOOTHING; i++)
		{
			if(smoothingBuffer[i] > -1)
			{
				tot += smoothingBuffer[i];
				c++;
			}
		}
		return tot/c;
	}


	PVector smoothVector(PVector newVal)
	{
		smoothingVectorBuffer[smoothingVectorIndex] = newVal;
		smoothingVectorIndex++;
		if (smoothingVectorIndex >= SMOOTHING)
			smoothingVectorIndex = 0;
		
		// return average
		PVector total = new PVector(0,0,0);
		PVector ave = new PVector(0,0,0);
		
		int c = 0;
		for(int i=0; i<SMOOTHING; i++)
		{
			if(smoothingVectorBuffer[i].x > -1.0)
			{
				total.x += smoothingVectorBuffer[i].x;
				total.y += smoothingVectorBuffer[i].y;
				total.z += smoothingVectorBuffer[i].z;	
				c++;
			}
		}
		
		ave.x = total.x/c;
		ave.y = total.y/c;
		ave.z = total.z/c;
		
		return ave;
	}
}
