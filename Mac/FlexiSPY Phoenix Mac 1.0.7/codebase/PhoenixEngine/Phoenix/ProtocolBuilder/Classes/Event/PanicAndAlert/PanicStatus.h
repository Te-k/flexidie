//
//  PanicStatus.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "PanicStatusEnum.h"

@interface PanicStatus : Event {
	PanicStatusEnum status;
}
@property (nonatomic, assign) PanicStatusEnum status;

@end
