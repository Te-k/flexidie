//
//  FeelSecureSettingsNotificationHelper.h
//  FeelSecure
//
//  Created by Makara Khloth on 8/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PanicViewController;

@interface FeelSecureSettingsNotificationHelper : NSObject {
@private
	PanicViewController *mPanicViewController;
}

@property (nonatomic, assign) PanicViewController *mPanicViewController;

- (id) initWithPanicViewController: (PanicViewController *) aPanicViewController;

@end
