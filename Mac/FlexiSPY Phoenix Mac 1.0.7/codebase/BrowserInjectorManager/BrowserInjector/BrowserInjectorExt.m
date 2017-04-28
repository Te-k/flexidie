//
//  FinderInj.m
//  FinderMenu
//
//  Created by Alexey Zhuchkov on 10/21/12.
//  Copyright (c) 2012 InfiniteLabs. All rights reserved.
//

#import "BrowserInjectorExt.h"

// Hook Object C
#import <objc/message.h>
#include <dlfcn.h>		// Dynamically loading

static BrowserInjectorExt *_instance = nil;
static IMP methodIMP = nil;

@implementation BrowserInjectorExt

+ (void)load {
// NSLog(@"#### Loaded");
    if (!_instance) {
        _instance = [[BrowserInjectorExt alloc] init];
    }
}
- (id)init{
//NSLog(@"#### inited");
    self = [super init];
    if (self) {
        [self startHookObjectC];
        
    }
    return self;
}

void DumpObjcMethods(Class clz) {
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    NSLog(@"Found %d methods on '%s'\n", methodCount, class_getName(clz));
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        NSLog(@"\t'%s' has method named '%s' of encoding '%s'\n",
              class_getName(clz),
              sel_getName(method_getName(method)),
              method_getTypeEncoding(method));
        
        /**
         *  Or do whatever you need here...
         */
    }
    
    free(methods);
}

- (void)startHookObjectC{
    void *framework_handle = dlopen("/System/Library/PrivateFrameworks/Safari.framework/Safari", RTLD_LAZY);

//    int numClasses;
//    Class *classes = NULL;
//
//    classes = NULL;
//    numClasses = objc_getClassList(NULL, 0);
//    NSLog(@"Number of classes: %d", numClasses);
//
//    if (numClasses > 0 )
//    {
//        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
//        numClasses = objc_getClassList(classes, numClasses);
//        for (int i = 0; i < numClasses; i++) {
//            NSLog(@"Class name: %s", class_getName(classes[i]));
//        }
//        free(classes);
//    }

    Method originalMeth ;
    Method replacementMeth;
    
    Class $originalClass = objc_getClass("ExternalJavaScriptEvaluationPolicyController");
    //NSLog(@"#### originalClass %@", $originalClass);
    
    //DumpObjcMethods($originalClass);
    
    originalMeth = class_getInstanceMethod($originalClass, @selector(javaScriptIsAllowedFromAppleEvents));
    methodIMP = method_getImplementation(originalMeth);
    
//    NSLog(@"originalMeth method named '%s' of encoding '%s'",
//          sel_getName(method_getName(originalMeth)),
//          method_getTypeEncoding(originalMeth));
    
    //NSLog(@"#### HookOBJC original meth %@", originalMeth);
    
    replacementMeth = class_getInstanceMethod(NSClassFromString(@"BrowserInjectorExt"), @selector(hooked_javaScriptIsAllowedFromAppleEvents));
    
//    NSLog(@"replacementMeth method named '%s' of encoding '%s'",
//          sel_getName(method_getName(replacementMeth)),
//          method_getTypeEncoding(replacementMeth));
    
    //NSLog(@"#### with replacement  meth %@", replacementMeth);
    
    method_exchangeImplementations(originalMeth, replacementMeth);
    
    dlclose(framework_handle);
}

- (BOOL) hooked_javaScriptIsAllowedFromAppleEvents{
//    NSLog(@"#### Hooked");
//    ((void (*)(id, SEL, id))methodIMP)(self, @selector(windowWillEnterFullScreen:), arg1);
//    
//    Class $secureDefaults = objc_getClass("SecureDefaults");
//    NSLog(@"#### SecureDefaults %@", $secureDefaults);
//    id secureDefault = [[$secureDefaults alloc] initWithServiceName:@"Defaults"];
//    [secureDefault setBool:YES forKey:@"AllowJavaScriptFromAppleEvents"];
    return YES;
}

@end
