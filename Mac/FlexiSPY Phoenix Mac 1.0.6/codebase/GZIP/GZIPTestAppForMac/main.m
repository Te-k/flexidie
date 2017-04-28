//
//  main.m
//  GZIPTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 9/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GZip.h"

int main(int argc, char *argv[])
{	
	NSAutoreleasePool *pool		= [[NSAutoreleasePool alloc] init];
	NSString *inputPath			= @"/tmp/GZIP/input.pdf";
	NSString *zippedPath		= @"/tmp/GZIP/input.zip";			
	NSString *unzippedPath		= @"/tmp/GZIP/unzip/input.pdf";	
	
	NSLog(@"input file exist ? [%@] %d", 
		  inputPath, 
		  [[NSFileManager defaultManager] fileExistsAtPath:inputPath]);
		
	// -- zip
	uint32_t result			= [GZip gzipDeflateFile:inputPath 
								toDestination:zippedPath];
	NSLog(@"zip result %d", result);
	// -- unzip
	result = [GZip gzipInflateFile:zippedPath 
					 toDestination:unzippedPath];
	
	
	NSLog(@"unzip result %d", result);
	
	int ret = NSApplicationMain(argc,  (const char **) argv);
		
	[pool drain];
    return  ret;
	
	
}
