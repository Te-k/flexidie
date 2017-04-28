//
//  main.m
//  GZIPTestApp
//
//  Created by Benjawan Tanarattanakorn on 7/31/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GZip.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	NSString *inputPath		= @"/tmp/GZIP/input";
	NSString *zippedPath	= @"/tmp/GZIP/input.zip";			
	NSString *unzippedPath	= @"/tmp/GZIP/unzip/input";
	
	
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
    [pool release];
    return retVal;
}
