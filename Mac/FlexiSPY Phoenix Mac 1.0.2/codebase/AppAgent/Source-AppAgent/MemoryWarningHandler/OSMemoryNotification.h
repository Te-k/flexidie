/*
 * Copyright (c) 2006 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */

#ifndef _OSMEMORYNOTIFICATION_H_
#define _OSMEMORYNOTIFICATION_H_

#include <sys/cdefs.h>

/*
**  OSMemoryNotification.h
**  
**  Kernel-generated notification mechanism to alert registered tasks when physical memory
**  pressure reaches certain thresholds. Notifications are triggered in both directions
**  so clients can manage their memory usage more and less aggressively.
**
*/

__BEGIN_DECLS

struct timeval;

/*
** Opaque type for notification object
*/
 
typedef struct _OSMemoryNotification * OSMemoryNotificationRef;

/*
** Threshold values for notifications
*/
 
typedef enum {
	OSMemoryNotificationLevelAny      = -1,
	OSMemoryNotificationLevelNormal   =  0,
	OSMemoryNotificationLevelWarning  =  1,
	OSMemoryNotificationLevelUrgent   =  2,
	OSMemoryNotificationLevelCritical =  3
} OSMemoryNotificationLevel;

/*
** Creation routines. Returns the created OSMemoryNotificationRef in the note param.
** returns: 0 on success
**          ENOMEM if insufficient memory or resources exists to create the notification object
**          EINVAL if the threshold is not a valid notification level
*/

int OSMemoryNotificationCreate(OSMemoryNotificationRef *note);

/*
** returns: 0 on success
**          EINVAL if the notification is not an initialized notification object
*/

int OSMemoryNotificationDestroy(OSMemoryNotificationRef note);

/*
** Block waiting for notification
** returns: 0 on success, with the level that triggered the notification in the level param
**          EINVAL if the notification object is invalid
**          ETIMEDOUT if abstime passes before notification occurs
*/
int OSMemoryNotificationWait(OSMemoryNotificationRef note, OSMemoryNotificationLevel *level);
int OSMemoryNotificationTimedWait(OSMemoryNotificationRef note, OSMemoryNotificationLevel *level, const struct timeval *abstime);

/*
** Simple polling interface to detect current memory pressure level
*/

OSMemoryNotificationLevel OSMemoryNotificationCurrentLevel(void);

/*
** External notify(3) string for manual notification setup
*/

extern const char *kOSMemoryNotificationName;

__END_DECLS

#endif /* _OSMEMORYNOTIFICATION_H_ */