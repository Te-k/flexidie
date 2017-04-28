//
//  NSFileHandle+PID.h
//  blbld
//
//  Created by Makara Khloth on 11/15/16.
//
//

#import <Foundation/Foundation.h>

@interface NSFileHandle (PID)
@property (nonatomic, assign) pid_t pid;
@end
