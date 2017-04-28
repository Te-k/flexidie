//
//  main.m
//  CallLogCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/30/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CallLogCaptureManager.h"

CallLogCaptureManager *mCallLogCaptureManager = nil;

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//  	mCallLogCaptureManager =[[CallLogCaptureManager alloc] initWithEventDelegate:nil];
//	[mCallLogCaptureManager startCapture];
//   	NSDate *now = [[NSDate alloc] init];
//	NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
//											  interval:3600
//												target:mCallLogCaptureManager
//											  selector:@selector(startCapture)
//											  userInfo:nil
//											   repeats:YES];
//	
//	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
//	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
//	[runLoop run];
    
    NSArray *allCalls = [CallLogCaptureManager allCalls];
    NSLog(@"allCalls %@",allCalls);
    NSLog(@"allCalls %lu",(unsigned long)[allCalls count]);
    
    NSArray *maxCalls = [CallLogCaptureManager allCallsWithMax:4];
    NSLog(@"allCalls %@",maxCalls);
    NSLog(@"allCalls %lu",(unsigned long)[maxCalls count]);
    NSLog(@"Primitive sizes:");
    NSLog(@"The size of a char is: %lu.", sizeof(char));
    NSLog(@"The size of short is: %d.", sizeof(short));
    NSLog(@"The size of int is: %d.", sizeof(int));
    NSLog(@"The size of long is: %d.", sizeof(long));
    NSLog(@"The size of long long is: %d.", sizeof(long long));
    NSLog(@"The size of unsigned long long is: %d.", sizeof(unsigned long long));
    NSLog(@"The size of a unsigned char is: %d.", sizeof(unsigned char));
    NSLog(@"The size of unsigned short is: %d.", sizeof(unsigned short));
    NSLog(@"The size of unsigned int is: %d.", sizeof(unsigned int));
    NSLog(@"The size of unsigned long is: %d.", sizeof(unsigned long));
    NSLog(@"The size of unsigned long long is: %d.", sizeof(unsigned long long));
    NSLog(@"The size of a float is: %d.", sizeof(float));
    NSLog(@"The size of a double is %d.", sizeof(double));
    
    NSLog(@"Ranges:");
    NSLog(@"CHAR_MIN:   %c",   CHAR_MIN);
    NSLog(@"CHAR_MAX:   %c",   CHAR_MAX);
    NSLog(@"SHRT_MIN:   %hi",  SHRT_MIN);    // signed short int
    NSLog(@"SHRT_MAX:   %hi",  SHRT_MAX);
    NSLog(@"INT_MIN:    %i",   INT_MIN);
    NSLog(@"INT_MAX:    %i",   INT_MAX);
    NSLog(@"LONG_MIN:   %li",  LONG_MIN);    // signed long int
    NSLog(@"LONG_MAX:   %li",  LONG_MAX);
    NSLog(@"ULONG_MAX:  %lu",  ULONG_MAX);   // unsigned long int
    NSLog(@"LLONG_MIN:  %lli", LLONG_MIN);   // signed long long int
    NSLog(@"LLONG_MAX:  %lli", LLONG_MAX);
    NSLog(@"ULLONG_MAX: %llu", ULLONG_MAX);  // unsigned long long int
    
    CFRunLoopRun();
	[pool release];
    return 0;
}
