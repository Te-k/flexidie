//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 7/11/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstalledAppHelper.h"
#import "RunningApplicationDataProvider.h"
#import "IconUtils.h"
#import "InstalledApplicationDataProvider.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
//	[InstalledAppHelper createInstalledApplicationMetadataArray];
    
	//RunningApplicationDataProvider *rp = [[RunningApplicationDataProvider alloc] init];
	//NSArray *app  =	[rp createRunningApplicationArray];
	//NSLog(@"app %@", app);
	
//	NSArray *array=  [ NSArray arrayWithObjects:@"icon",	@"Icon.png",	@"ICON",	@"ICON.png",
//															@"Icon.PNG",				@"ICON.PNG",
//												@"icon@2x", @"Icon@2x.png", @"ICON@2x",	@"ICON@2x.png",
//															@"Icon@2x.PNG",				@"ICON@2x.PNG",
//					  nil];
//	NSLog(@"%@", [IconUtils getHighResolutionIconsNameFromIcons:array]);
    
    InstalledApplicationDataProvider *provider = [[InstalledApplicationDataProvider alloc] init];
    [provider commandData];
    
//    NSMutableArray *allApp = [NSMutableArray array];
//    
//    while ([provider hasNext]) {
//        id app = [provider getObject];
//        [allApp addObject:app];
//        
//    }
//    NSLog(@"#### %@", allApp);
    [pool release];
    return retVal;
}
