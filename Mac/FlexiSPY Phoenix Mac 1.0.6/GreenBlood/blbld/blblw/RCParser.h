//
//  RCParser.h
//  blbld
//
//  Created by Makara Khloth on 10/13/16.
//
//

#import <Foundation/Foundation.h>

@class RCCommand;

@interface RCParser : NSObject

+ (RCCommand *) parse: (NSString *) cmd;

@end
