//
//  main.m
//  OTCTestApp
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OTCTestAppApp.h"

int main(int argc, char *argv[])
{
	int returnCode;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    returnCode = UIApplicationMain(argc, argv, @"OTCTestAppApp", @"OTCTestAppApp");
    [pool release];
    return returnCode;
}
