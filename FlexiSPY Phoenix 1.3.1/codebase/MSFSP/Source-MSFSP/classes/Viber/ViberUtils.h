//
//  ViberUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 4/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxIMEvent;

@interface ViberUtils : NSObject {

}

+ (void) sendViberEvent: (FxIMEvent *) aIMEvent;

@end
