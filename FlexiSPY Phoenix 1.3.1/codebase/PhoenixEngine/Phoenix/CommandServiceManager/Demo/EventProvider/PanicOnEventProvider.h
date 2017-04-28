//
//  Event1Provider.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/8/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface PanicOnEventProvider : NSObject <DataProvider>{
	int total;
	int count;
}

@property (nonatomic, assign) int total;

-(id)init;

@end
