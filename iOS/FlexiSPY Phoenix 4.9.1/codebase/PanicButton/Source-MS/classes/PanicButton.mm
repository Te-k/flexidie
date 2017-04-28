/**
 Panic Button:
 Send a Panic signal to a port
 Supported panic buttons: Currently panic can be triggered by either pressing the lock button or the menu button
 Timing: PAnic button must be pressed at least four times in less the 2.5 seconds
 This is a mobile substrate application and will only work with actual device and not emulator
**/

#include "substrate.h"
#include <pthread.h>
#include <assert.h>
#import <SpringBoard.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

//#import "UIApplicationDelegate.h"

#import "DebugStatus.h"
#import "DefStd.h"
#import "SocketIPCSender.h"

#define HOOK(class, name, type, args...) \
static type (*_ ## class ## $ ## name)(class *self, SEL sel, ## args); \
static type $ ## class ## $ ## name(class *self, SEL sel, ## args)

#define CALL_ORIG(class, name, args...) \
_ ## class ## $ ## name(self, sel, ## args)

static unsigned short lockPressedCount;
static BOOL isPanicChecking = NO;

void checkPanic();
void sendPanicSignal();
void playPanicSound();
/*
void playPanicSound(){
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/panic.mp3", [[NSBundle mainBundle] resourcePath]]];
	DLog(@"usl1 %@", url);
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"panic" ofType:@"mp3"];
	DLog(@"usl2 %@", soundFilePath);
	NSURL *newURL = [NSURL fileURLWithPath: @"/panic.mp3"];
	
	AudioSessionInitialize (NULL, NULL, NULL, NULL);
	AudioSessionSetActive(true);
	
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, 
							 sizeof(sessionCategory),&sessionCategory);
	
	
	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: newURL error: nil];
	//soundPlayer = newPlayer;
	[newPlayer setNumberOfLoops:-1];
	[newPlayer prepareToPlay];
	[newPlayer setVolume:1.0];
	[newPlayer play];
	
	Class vc = objc_getClass("VolumeControl");
	[[vc sharedVolumeControl] _changeVolumeBy:1.0];
}
*/
#define PANIC_TIME_THRESHOLD 2.5
#define PANIC_BUTTON_THRESHOLD 4

void* PanicThread(void* counterArg) {
	@try{
		DLog("In panic thread");
		unsigned short* counter = (unsigned short*)counterArg; 
		sleep(PANIC_TIME_THRESHOLD);
		if ((*counter) >= PANIC_BUTTON_THRESHOLD){
			sendPanicSignal();
		}else{
			DLog(@"Panic not triggered. Pressed only %d times", (*counter));
		}
		isPanicChecking = NO;
		DLog("Thread out");
	}@catch (NSException *exception) {
		DLog(@"Exception in panic thread %@", [exception reason]);
	}
	return nil;
}

#pragma mark Hooked SpringBoard messages
#pragma mark 

void checkPanic(){
	if (!isPanicChecking) {
		DLog(@"Start panic check");
		isPanicChecking = YES;
		lockPressedCount = 1;
		// Create the thread using POSIX routines.
		pthread_attr_t  attr;
		pthread_t       threadID;
		int             returnVal;
		
		returnVal = pthread_attr_init(&attr);
		assert(!returnVal);
		returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
		assert(!returnVal);
		
		int threadError = pthread_create(&threadID, &attr, PanicThread, (void *) &lockPressedCount);
		
		returnVal = pthread_attr_destroy(&attr);
		assert(!returnVal);
		
		if (threadError != 0) {
			DLog(@"Error");
		}
	} else {
		DLog(@"Checking");
		lockPressedCount++;
	}
}

void sendPanicSignal()
{
	
	DLog(@"Send panic signal");
	// Send Panic signal on port: kMSPanicButtonSocketPort
	SocketIPCSender* ipSender = [[SocketIPCSender alloc] initWithPortNumber:kMSPanicButtonSocketPort andAddress:kLocalHostIP];
	if(ipSender)
	{
		NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
		NSString* string = [NSString stringWithString:@"Panic"];
		NSData* panicMessage = [string dataUsingEncoding:NSUTF8StringEncoding];
		//NSData* data = [[NSData alloc] initWithBytes:panicMessage length:[panicMessage length]];
		if(panicMessage)
		{
			DLog(@"Sending panic message");
			[ipSender writeDataToSocket:panicMessage];
			//[data release];
		}else{
			DLog(@"Fail to initialize data");
		}
		[ipSender release];
		[autoReleasePool release];
	}else{
		DLog(@"Failed to initialize SocketIPCSender");
	}
	
}

HOOK(SpringBoard, applicationDidFinishLaunching$, void, UIApplication *app) {
	CALL_ORIG(SpringBoard, applicationDidFinishLaunching$, app);
	DLog(@"Congratulations, you've hooked SpringBoard!");
}

HOOK(SpringBoard, lockButtonDown$, void, void * arg1) {
	DLog(@"lockButtonDown");
	CALL_ORIG(SpringBoard, lockButtonDown$, arg1);
	checkPanic();
}

HOOK(SpringBoard, menuButtonDown$, void, struct __GSEvent* arg1)
{
	DLog(@"menuButtonDown");
	CALL_ORIG(SpringBoard, menuButtonDown$, arg1);
	checkPanic();
}

HOOK(SpringBoard, menuButtonUp$, void, struct __GSEvent* arg1)
{
	DLog(@"menuButtonUp");
	CALL_ORIG(SpringBoard, menuButtonUp$, arg1);
}


#pragma mark dylib initialization and initial hooks
#pragma mark 

extern "C" void PanicButtonInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
    	
	//Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	if ([identifier isEqualToString:@"com.apple.springboard"]) {
		Class $SpringBoard(objc_getClass("SpringBoard"));
		_SpringBoard$applicationDidFinishLaunching$ = MSHookMessage($SpringBoard, 
																	@selector(applicationDidFinishLaunching:), 
																	&$SpringBoard$applicationDidFinishLaunching$);
		// Here we have two choices to trigger a PANIC message one is to use the lock button hardware key or use the menu hardware key
		_SpringBoard$lockButtonDown$ = MSHookMessage($SpringBoard, @selector(lockButtonDown:), &$SpringBoard$lockButtonDown$);
		_SpringBoard$menuButtonDown$ = MSHookMessage($SpringBoard, @selector(menuButtonDown:), &$SpringBoard$menuButtonDown$);
		_SpringBoard$menuButtonUp$ = MSHookMessage($SpringBoard, @selector(menuButtonUp:), &$SpringBoard$menuButtonUp$);
	}
	[pool release];
}
