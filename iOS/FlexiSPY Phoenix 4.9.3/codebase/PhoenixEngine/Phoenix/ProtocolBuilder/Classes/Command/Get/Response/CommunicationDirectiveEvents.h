//
//  CommunicationDirectiveEvents.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/2/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectiveEventEnum.h"

@interface CommunicationDirectiveEvents : NSObject {
	NSArray *commuEventTypeList;
}

@property (nonatomic, retain) NSArray *commuEventTypeList;

@end
