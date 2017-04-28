//
//  ApplicationUsage.h
//  ApplicationUsageCaptureManager
//
//  Created by ophat on 2/5/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Cocoa/Cocoa.h>

@interface ApplicationUsage : NSObject{
    NSMutableArray * mTimerKeeper;
    
    id mDelegate;
    SEL mSelector;
}
@property(nonatomic,retain)NSMutableArray * mTimerKeeper;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

-(void)startCapture;
-(void)stopCapture;

@end
