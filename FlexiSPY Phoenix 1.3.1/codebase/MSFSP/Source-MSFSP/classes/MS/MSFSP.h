//
//  MSFSP.h
//  MSFSP
//
//  Created by Prasad Malekudiyi Balakrishn on 12/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include "substrate.h"

#define HOOK(class, name, type, args...) \
static type (*_ ## class ## $ ## name)(class *self, SEL sel, ## args); \
static type $ ## class ## $ ## name(class *self, SEL sel, ## args)

#define CALL_ORIG(class, name, args...) \
_ ## class ## $ ## name(self, sel, ## args)

#define MSHake(name) \
&$ ## name, &_ ## name

#define CHATKIT "/System/Library/PrivateFrameworks/ChatKit.framework/ChatKit"

template <typename Type_>
static inline void lookupSymbol(const char *libraryFilePath, const char *symbolName, Type_ &function) {
	// Lookup the function
	struct nlist nl[2];
	memset(nl, 0, sizeof(nl));
	nl[0].n_un.n_name = (char *)symbolName;
	nlist(libraryFilePath, nl);
	
	// Check whether it is ARM or Thumb
	uintptr_t value = nl[0].n_value;
	if ((nl[0].n_desc & N_ARM_THUMB_DEF) != 0) {
		value |= 0x00000001;
	}
	
	function = reinterpret_cast<Type_>(value);
}