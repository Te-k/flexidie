//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneBookmarkDAO.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);

//	int retVal = 0;
//	PhoneBookmarkDAO *bmDAO = [[PhoneBookmarkDAO alloc] init];
//	NSArray *bm = [bmDAO select];
//	NSLog(@"bookmark %@", bm);
//	NSInteger bmCount = [bmDAO count];
//	NSLog(@"bookmark count %d", bmCount);
	
    [pool release];
    return retVal;
}
