//
//  RCHandler.h
//  blbld
//
//  Created by Makara Khloth on 10/13/16.
//
//

#import <Foundation/Foundation.h>

@class RCCommand;

@interface RCHandler : NSObject

+ (void) handleCommand: (RCCommand *) command;

@end
