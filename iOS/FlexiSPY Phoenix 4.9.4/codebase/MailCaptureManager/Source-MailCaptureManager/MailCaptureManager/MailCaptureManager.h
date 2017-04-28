//
//  MailCaptureManager.h
//  MailCaptureManager
//
//  Created by ophat on 5/27/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCapture.h"

@class MailCapture;
@interface MailCaptureManager : NSObject<EventCapture>{
    MailCapture * mMailCapture;
    id  mDelegate;
}
@property(nonatomic,retain) MailCapture * mMailCapture;
@property(nonatomic,assign) id mDelegate;

-(id) initWithAttachment:(NSString *)aAttachment;
-(void) startCapture;
-(void) stopCapture;

@end
