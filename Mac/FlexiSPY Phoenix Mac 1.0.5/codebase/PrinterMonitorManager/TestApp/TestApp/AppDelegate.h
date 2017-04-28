//
//  AppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 10/26/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PrinterMonitorManager;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    
}

@property (nonatomic, readonly) PrinterMonitorManager *printerMonitorManager;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end

