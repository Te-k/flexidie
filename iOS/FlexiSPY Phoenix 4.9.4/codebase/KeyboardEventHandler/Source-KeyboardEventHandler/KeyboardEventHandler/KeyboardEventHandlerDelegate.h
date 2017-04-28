//
//  KeyboardEventHandlerDelegate.h
//  KeyboardEventHandler
//
//  Created by Ophat Phuetkasickonphasutha on 10/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@protocol KeyboardEventHandlerDelegate <NSObject>
- (void) keyPressCallback:(EventHandlerCallRef) aHandler eventRef:(EventRef) aEvent method:(void *)aUserData;
- (void) keyReleaseCallback:(EventHandlerCallRef) aHandler eventRef:(EventRef) aEvent method:(void *)aUserData;
@end
