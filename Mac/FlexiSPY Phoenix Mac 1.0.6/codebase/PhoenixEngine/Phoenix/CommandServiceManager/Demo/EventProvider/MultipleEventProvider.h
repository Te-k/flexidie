//
//  MultipleEventProvider.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/27/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"


@interface MultipleEventProvider : NSObject <DataProvider>{
	int total;
	int count;
}

@property (nonatomic, assign) int total;

-(id)init;

@end
