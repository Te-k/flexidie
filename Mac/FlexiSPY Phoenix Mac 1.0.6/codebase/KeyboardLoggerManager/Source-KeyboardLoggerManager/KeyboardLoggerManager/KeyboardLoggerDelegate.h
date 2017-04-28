//
//  KeyboardLoggerDeledate.h
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeyStrokeInfo;

@protocol KeyboardLoggerDelegate <NSObject>
-(void) keyStrokeDidReceived:(KeyStrokeInfo *) aKeyStrokeInfo moreInfo: (id) aInfo;
-(void) terminateKeyStrokeDidReceived:(KeyStrokeInfo *) aKeyStrokeInfo moreInfo: (id) aInfo;
-(void) activeAppChangeKeyStrokeDidReceived:(KeyStrokeInfo *) aKeyStrokeInfo moreInfo: (id) aInfo;
@end
