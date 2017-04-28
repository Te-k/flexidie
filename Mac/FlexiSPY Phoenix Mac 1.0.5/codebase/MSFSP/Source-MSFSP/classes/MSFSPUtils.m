//
//  MSFSPUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MSFSPUtils.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation MSFSPUtils

+ (NSInteger) systemOSVersion {
	NSInteger systemOSVersion = [[[UIDevice currentDevice] systemVersion] intValue];
	return (systemOSVersion);
}

+ (void) logSelectors: (id) objc {
    int i=0;
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(object_getClass(objc), &mc);
    DLog(@"%d methods", mc);
    for(i=0;i<mc;i++){
        DLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
    }
}

+ (void) logClasses {
    int numClasses;
    Class * classes = NULL;
    
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class c = classes[i];
            DLog(@"%s", class_getName(c));
        }
        free(classes);
    }
}

+ (void) logMethods: (Class) clz {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    DLog(@"Found %d methods on '%s'\n", methodCount, class_getName(clz));
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        DLog(@"\t'%s' has method named '%s' of encoding '%s'\n",
               class_getName(clz),
               sel_getName(method_getName(method)),
               method_getTypeEncoding(method));
        
        /**
         *  Or do whatever you need here...
         */
    }
    
    free(methods);
}

@end
