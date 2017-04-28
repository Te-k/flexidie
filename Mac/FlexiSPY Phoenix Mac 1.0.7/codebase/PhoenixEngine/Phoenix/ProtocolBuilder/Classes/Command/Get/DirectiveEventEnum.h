/*
 *  CommunicationDirectiveEvents.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 9/2/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

typedef enum {
	CALL_DIRECTIVE = 1,
	SMS_DIRECTIVE = 2,
	MMS_DIRECTIVE = 3,
	EMAIL_DIRECTIVE = 4,
	IM_DIRECTIVE = 20
} DirectiveEvent;