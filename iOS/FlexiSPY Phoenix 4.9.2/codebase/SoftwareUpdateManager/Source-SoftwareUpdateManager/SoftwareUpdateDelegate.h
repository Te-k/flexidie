//
//  SoftwareUpdateDelegate.h
//  SoftwareUpdateManager
//
//  Created by Ophat Phuetkasickonphasutha on 6/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol SoftwareUpdateDelegate <NSObject>

-(void)softwareUpdateCompleted: (NSError *) aError;

@end
