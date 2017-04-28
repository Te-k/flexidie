//
//  main.c
//  Dark
//
//  Created by Erwan Barrier on 8/8/12.
//  Copyright (c) 2012 Erwan Barrier. All rights reserved.
//

#include <syslog.h>

__attribute__((constructor))
void load()
{
  syslog(LOG_NOTICE, "MachInjectSample PAYLOAD: My pid is %d\n", getpid());
}