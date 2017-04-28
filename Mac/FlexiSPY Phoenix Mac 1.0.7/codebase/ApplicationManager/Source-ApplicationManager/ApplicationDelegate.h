//
//  ApplicationDelegate.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RunningApplicationDelegate <NSObject>
- (void) deliverRunningApplicationDidFinished: (NSError *) aError;
@end

@protocol InstalledApplicationDelegate <NSObject>
- (void) deliverInstalledApplicationDidFinished: (NSError *) aError;
@end

