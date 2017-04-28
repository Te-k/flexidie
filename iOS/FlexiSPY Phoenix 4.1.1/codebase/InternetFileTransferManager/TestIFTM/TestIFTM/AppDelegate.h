//
//  AppDelegate.h
//  TestIFTM
//
//  Created by ophat on 9/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class InternetFileTransferManager;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    InternetFileTransferManager  * A;
}
@property (nonatomic,retain) InternetFileTransferManager * A;

@end

