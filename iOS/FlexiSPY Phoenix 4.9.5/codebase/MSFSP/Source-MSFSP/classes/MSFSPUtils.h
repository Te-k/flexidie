//
//  MSFSPUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 2/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define typename(x) _Generic((x),                                                 \
_Bool: "_Bool",                  unsigned char: "unsigned char",          \
char: "char",                     signed char: "signed char",            \
short int: "short int",         unsigned short int: "unsigned short int",     \
int: "int",                     unsigned int: "unsigned int",           \
long int: "long int",           unsigned long int: "unsigned long int",      \
long long int: "long long int", unsigned long long int: "unsigned long long int", \
float: "float",                         double: "double",                 \
long double: "long double",                   char *: "pointer to char",        \
void *: "pointer to void",                int *: "pointer to int",         \
default: "other")

@interface MSFSPUtils : NSObject {

}

+ (NSInteger) systemOSVersion;
+ (void) logSelectors: (id) objc;
+ (void) logClasses;
+ (void) logMethods: (Class) clz;

@end
