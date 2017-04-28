//
//  MSFDL.h
//  MSFDL
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

//#include "substrate.h"
#include "CydiaSubstrate.h"

#define HOOK(class, name, type, args...) \
static type (*_ ## class ## $ ## name)(class *self, SEL sel, ## args); \
static type $ ## class ## $ ## name(class *self, SEL sel, ## args)

#define CALL_ORIG(class, name, args...) \
_ ## class ## $ ## name(self, sel, ## args)
