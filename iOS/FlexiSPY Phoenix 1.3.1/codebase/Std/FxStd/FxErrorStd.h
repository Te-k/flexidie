//
//  FxErrorStd.h
//  FxStd
//
//  Created by Makara Khloth on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
	{
		kFxErrorNone,
		kFxErrorEventDatabase,
		kFxErrorDelivery,
		kFxErrorDDMDatabase,
		kFxErrorEDMDatabase,
		kFxErrorIPCSocket,
		kFxErrorRCM,
		kFxErrorActivationManager,
		//
		kFxErrorCSMHttp,
		kFxErrorCSMServer,
		kFxErrorCSMTransport, // Assume beside Http and Server
	} FxErrorCategory;

typedef enum 
	{
		kViewGotoNextRowEventDatabaseError  = 2000,
		kDAOEventDatabaseNotFound			= 2001,
		kViewColumnEventDatabaseNotFound	= 2002,
		kActivationManagerBusy				= 2003,
		kDDMPersistNoneResumableRequest		= 2004,
		kRCMNSExceptionWhileProcessProcessor= 2005,
		kEventDeliveryManagerBusy			= 2006,
		kNoHomeNumber						= 2007,
		kPairingIDNotFound					= 2008,
		kAddressBookManagerBusy				= 2009,
		kBookmarkManagerBusy				= 2010,
		kRunningApplicationManagerBusy		= 2011,
		kInstalledApplicationManagerBusy	= 2012,
		kApplicationProfileManagerBusy		= 2013,
		kUrlProfileManagerBusy				= 2014,
		kUrlSignUpError						= 2015,
		kOnDemandRecordFailToStart			= 2016,
		kOnDemandRecordNotComplete			= 2017,
		kCalendarManagerBusy				= 2018,
		kLocationServiceDisabled			= 2019,
		kNoteManagerBusy					= 2020,
		kOnDemandRecordCallInProgress		= 2021
	}   FxErrorCode;


typedef enum
   {
	   kLocationError=-700

        
   }FxLocationErrorCode;


