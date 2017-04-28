//
//  PanicLocationEventProvider.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/14/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"


@interface PanicLocationEventProvider : NSObject <DataProvider> {
	int total;
	int count;
}

@property (nonatomic, assign) int total;

-(id)init;

@end
