//
//  AppDelegate.h
//  TestApp
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppScreenShotManagerImpl;
@interface AppDelegate : NSObject <NSApplicationDelegate>{
    AppScreenShotManagerImpl * appScreenShotManagerImpl;
}
@property(nonatomic,retain) AppScreenShotManagerImpl * appScreenShotManagerImpl;

@end

