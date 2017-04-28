//
//  RCCommand.h
//  blbld
//
//  Created by Makara Khloth on 10/13/16.
//
//

#import <Foundation/Foundation.h>

@interface RCCommand : NSObject

@property (nonatomic, copy) NSString *cmdCode;
@property (nonatomic, copy) NSArray *cmdArgs;

@end
