//
//  PageValueChangeNotifier.h
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/4/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PageVisitedNotifier.h"

@interface PageValueChangeNotifier : PageVisitedNotifier {
@private
    id mMouseEventHandler;
    
    id mDelegate;
    SEL mSelector;
}

@property (nonatomic, retain) id mMouseEventHandler;
@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@end
