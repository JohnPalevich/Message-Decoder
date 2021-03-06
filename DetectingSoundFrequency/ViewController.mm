

#import "ViewController.h"

#import "mo_audio.h" //stuff that helps set up low-level audio
#import "FFTHelper.h"
#import "NoteToMessage.h"

#define SAMPLE_RATE 44100  //22050 //44100
#define FRAMESIZE  512
#define NUMCHANNELS 2

#define kOutputBus 0
#define kInputBus 1

@interface ViewController ()
-(void) updateFreq: (Float32) freq power: (Float32) power;

@end


/// Nyquist Maximum Frequency
const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;

/// caculates HZ value for specified index from a FFT bins vector
Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}



// The Main FFT Helper
FFTHelperRef *fftConverter = NULL;



//Accumulator Buffer=====================

const UInt32 accumulatorDataLength = 2048; // 131072;  //16384; //32768; 65536; 131072;
UInt32 accumulatorFillIndex = 0;
Float32 *dataAccumulator = nil;
static void initializeAccumulator() {
    dataAccumulator = (Float32*) malloc(sizeof(Float32)*accumulatorDataLength);
    accumulatorFillIndex = 0;
}
static void destroyAccumulator() {
    if (dataAccumulator!=NULL) {
        free(dataAccumulator);
        dataAccumulator = NULL;
    }
    accumulatorFillIndex = 0;
}

static BOOL accumulateFrames(Float32 *frames, UInt32 length) { //returned YES if full, NO otherwise.
    //    float zero = 0.0;
    //    vDSP_vsmul(frames, 1, &zero, frames, 1, length);
    
    if (accumulatorFillIndex>=accumulatorDataLength) { return YES; } else {
        memmove(dataAccumulator+accumulatorFillIndex, frames, sizeof(Float32)*length);
        accumulatorFillIndex = accumulatorFillIndex+length;
        if (accumulatorFillIndex>=accumulatorDataLength) { return YES; }
    }
    return NO;
}

static void emptyAccumulator() {
    accumulatorFillIndex = 0;
    memset(dataAccumulator, 0, sizeof(Float32)*accumulatorDataLength);
}
//=======================================


//==========================Window Buffer
const UInt32 windowLength = accumulatorDataLength;
Float32 *windowBuffer= NULL;
//=======================================



/// max value from vector with value index (using Accelerate Framework)
static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
}




///returns HZ of the strongest frequency.
static Float32 strongestFrequencyHZ(Float32 *buffer, FFTHelperRef *fftHelper, UInt32 frameSize, Float32 *freqValue) {
    
    
    //the actual FFT happens here
    //****************************************************************************
    Float32 *fftData = computeFFT(fftHelper, buffer, frameSize);
    //****************************************************************************
    
    
    fftData[0] = 0.0;
    unsigned long length = frameSize/2.0;
    Float32 max = 0;
    unsigned long maxIndex = 0;
    unsigned long cutOffIndex = length/15; //dont recognize low frequency
    max = vectorMaxValueACC32_index(fftData + cutOffIndex, length - cutOffIndex, 1, &maxIndex);
    maxIndex += cutOffIndex;
    if (freqValue!=NULL) { *freqValue = max; }
    Float32 HZ = frequencyHerzValue(maxIndex, length, NyquistMaxFreq);
    return HZ;
}



__weak ViewController *viewControllerToUpdate = nil;


#pragma mark MAIN CALLBACK
void AudioCallback( Float32 * buffer, UInt32 frameSize, void * userData )
{
    
    
    //take only data from 1 channel
    Float32 zero = 0.0;
    vDSP_vsadd(buffer, 2, &zero, buffer, 1, frameSize*NUMCHANNELS);
    
    
    
    if (accumulateFrames(buffer, frameSize)==YES) { //if full
        
        //windowing the time domain data before FFT (using Blackman Window)
        if (windowBuffer==NULL) { windowBuffer = (Float32*) malloc(sizeof(Float32)*windowLength); }
        vDSP_blkman_window(windowBuffer, windowLength, 0);
        vDSP_vmul(dataAccumulator, 1, windowBuffer, 1, dataAccumulator, 1, accumulatorDataLength);
        //=========================================
        
        
        Float32 maxHZValue = 0;
        
        Float32 maxHZ = strongestFrequencyHZ(dataAccumulator, fftConverter, accumulatorDataLength, &maxHZValue);

        dispatch_async(dispatch_get_main_queue(), ^{ //update UI only on main thread
            [viewControllerToUpdate updateFreq: maxHZ power: maxHZValue];
        });
        
        emptyAccumulator(); //empty the accumulator when finished
    }
    memset(buffer, 0, sizeof(Float32)*frameSize*NUMCHANNELS);
}















@implementation ViewController
{
    NoteToMessage * _noteToMessage;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _noteToMessage = [[NoteToMessage alloc] init];
    
    viewControllerToUpdate = self;
    
    //initialize stuff
    fftConverter = FFTHelperCreate(accumulatorDataLength);
    initializeAccumulator();
    [self initMomuAudio];

}

-(void) initMomuAudio {
    bool result = false;
    result = MoAudio::init( SAMPLE_RATE, FRAMESIZE, NUMCHANNELS, false);
    if (!result) { NSLog(@" MoAudio init ERROR"); }
    result = MoAudio::start( AudioCallback, NULL );
    if (!result) { NSLog(@" MoAudio start ERROR"); }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void) dealloc {
    destroyAccumulator();
    FFTHelperRelease(fftConverter);
}


- (void) updateFreq: (Float32) freq power: (Float32) power{
    HZValueLabel.text = [_noteToMessage messageForFreq: freq power: power];
}
- (IBAction)clear:(UIButton *)sender {
    [_noteToMessage clear];
    HZValueLabel.text = @"";
}

@end
