//
//  SMSEventProvider.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/13/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface SMSEventProvider : NSObject <DataProvider> {
	int total;
	int count;
}

@property (nonatomic, assign) int total;

-(id)init;

@end
