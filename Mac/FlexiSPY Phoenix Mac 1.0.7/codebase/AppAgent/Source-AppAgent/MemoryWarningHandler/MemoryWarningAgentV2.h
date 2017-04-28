//
//  MemoryWarningAgentV2.h
//  AppAgent
//
//  Created by Makara Khloth on 4/9/15.
//
//

#import <Foundation/Foundation.h>

@interface MemoryWarningAgentV2 : NSObject

- (void) startListenToMemoryWarningLevelNotification;
- (void) stopListenToMemoryWarningLevelNotification;

@end
