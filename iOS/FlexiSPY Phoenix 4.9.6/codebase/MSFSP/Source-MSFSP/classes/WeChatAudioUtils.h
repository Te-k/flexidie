//
//  WeChatAudioUtils.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 10/8/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface WeChatAudioUtils : NSObject

+ (id) sharedWeChatAudioUtils;

@property (nonatomic, retain) NSString *mAudioPath;

+ (BOOL) convertAUDFromPath: (NSString *) aAUDPath toAMRPath: (NSString *) aAMRPath;
+ (BOOL) convertAUDFromData: (NSData *) aAUDData toAMRPath: (NSString *) aAMRPath;

@end
