//
//  InjectorWrapper.h
//  Dark
//
//  Created by Erwan Barrier on 8/6/12.
//  Copyright (c) 2012 Erwan Barrier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKInjectorProxy : NSObject

+ (BOOL)inject:(NSError **)error;

@end
