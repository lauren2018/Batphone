/*
 *  Spectrogram.h
 *  simpleUI
 *
 *  Created by Stephen Tarzia on 10/2/10.
 *  Copyright 2010 Northwestern University. All rights reserved.
 *
 */

#import "SlidingWindow.h"
#include <pthread.h> // for mutex

// Sliding window spectrogram, with our new summary vector function
class Spectrogram{
public:
	/* constructor */
	Spectrogram(unsigned int freq_bins, unsigned int time_bins);
	/* copies a new spectrum into the spectrogram and removes the oldest spectrum.  
	 * float array parameter must be of length freqBins */
	void update(float* s);
	/* fills the passed buffer with a spectral summary vector of length freqBins.
	 * Spectral summary is the 5th percentile value (over time) for each frequency bin. */
	void getSummary(float* outBuf);
	/* destructor */
	~Spectrogram();
	
	/* dimensions of the spectrogram */
	unsigned int freqBins;
	unsigned int timeBins;
	
private:
	/* the data is sliding windows, one for each frequency bin */
	SlidingWindow** slidingWindows;	
	/* lock to prevent retrieval of data while updating */
	pthread_mutex_t lock;
};