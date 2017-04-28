//
//  UpdateConfigurationDelegate.h
//  UpdateConfigurationManager
//
//  Created by Makara Khloth on 6/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UpdateConfigurationDelegate <NSObject>
- (void) updateConfigurationCompleted: (NSError *) aError;

@end
