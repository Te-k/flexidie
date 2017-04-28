/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessingType
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

typedef enum
	{
		kProcessingTypeSync,
		kProcessingTypeAsyncHTTP,
	    kProcessingTypeAsyncNonHTTP
	}   RemoteCmdProcessingType;

