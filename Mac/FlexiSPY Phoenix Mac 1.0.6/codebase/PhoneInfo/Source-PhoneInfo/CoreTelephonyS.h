/*******************************************************************************
 * iPhone-Wireless Project : Telephony Library                                 *
 * Copyright (C) 2007      Geohot <geohot@gmail.com>                           *
 * Copyright (C) 2007-2008 Pumpkin <pumpkingod@gmail.com>                      *
 * Copyright (C) 2007-2008 Lokkju <lokkju@gmail.com>                           *
 *******************************************************************************
 * $LastChangedDate::                                                        $ *
 * $LastChangedBy::                                                          $ *
 * $LastChangedRevision::                                                    $ *
 * $Id::                                                                     $ *
 *******************************************************************************
 *  This program is free software: you can redistribute it and/or modify       *
 *  it under the terms of the GNU General Public License as published by       *
 *  the Free Software Foundation, either version 3 of the License, or          *
 *  (at your option) any later version.                                        *
 *                                                                             *
 *  This program is distributed in the hope that it will be useful,            *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 *  GNU General Public License for more details.                               *
 *                                                                             *
 *  You should have received a copy of the GNU General Public License          *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 *******************************************************************************/

/* $HeadURL$ */
#include <CoreFoundation/CoreFoundation.h>

//Functions I'm sure about
struct CTServerConnection
{
	int a;
	int b;
	CFMachPortRef myport;
	int c;
	int d;
	int e;
	int f;
	int g;
	int h;
	int i;
};

struct CellInfo
{
	int servingmnc;
	int network;
	int location;
	int cellid;
	int station;
	int freq;
	int rxlevel;
	int c1;
	int c2;
};

struct CTResult
{
    int flag;
    int a;
};

struct CTServerConnection * _CTServerConnectionCreate(CFAllocatorRef, void *, int *);
void _CTServerConnectionDestroy(struct CTServerConnection*);
void _CTServerConnectionCopyMobileIdentity(struct CTResult *,   struct CTServerConnection *,  NSString **);//the void* is a callback
void _CTServerConnectionCopyMobileSubscriberIdentity(struct CTResult *, struct CTServerConnection *,  NSString **);
void _CTServerConnectionCopySIMIdentity(struct CTResult *, struct CTServerConnection *,  NSString **);
void _CTServerConnectionCopyPhoneNumber(struct CTResult *, struct CTServerConnection *,  id *);
void _CTServerConnectionCopyServingNetworkInfo(struct CTResult *, struct CTServerConnection *,  id *);
void _CTServerConnectionCopyServingCellInfo(struct CTResult *, struct CTServerConnection *,  id *);
void _CTServerConnectionCopyVoiceMailInfo(struct CTResult *, struct CTServerConnection *,  id *);

void _CTServerConnectionCopyRegistrationInfo(struct CTResult *, struct CTServerConnection *,  id *);

mach_port_t _CTServerConnectionGetPort(struct CTServerConnection *);
int *_CTServerConnectionCellMonitorStart(int *,struct CTServerConnection *);

void _CTServerConnectionRegisterForNotification(void *, struct CTServerConnection *, void *); //kCTCellMonitorUpdateNotification
void kCTCellMonitorUpdateNotification();

int *_CTServerConnectionCellMonitorGetCellCount(int *,struct CTServerConnection *,int *);
int *_CTServerConnectionCellMonitorGetCellInfo(int *,struct CTServerConnection *,int, struct CellInfo *);	//3rd is cell tower num

char *_CTGetIMEI();
