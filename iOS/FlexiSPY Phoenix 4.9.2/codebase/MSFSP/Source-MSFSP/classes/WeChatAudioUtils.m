//
//  WeChatAudioUtils.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 10/8/2557 BE.
//
//

#import "WeChatAudioUtils.h"


static WeChatAudioUtils *_WeChatAudioUtils = nil;


static const char *kAMRHeader  = "#!AMR\n";  // 23 21 41 4D 52 0A


@implementation WeChatAudioUtils



+ (id) sharedWeChatAudioUtils {
    if (_WeChatAudioUtils == nil) {
		_WeChatAudioUtils = [[WeChatAudioUtils alloc] init];
    }
	return (_WeChatAudioUtils);
}

+ (BOOL) convertAUDFromPath: (NSString *) aAUDPath toAMRPath: (NSString *) aAMRPath {
    NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
    
    BOOL success    = NO;
    
    // Ensure that we has the path to original audio
    if (aAUDPath && [aAUDPath length]) {
        
        // Construct the path in our document directory
        DLog(@"Retrieve audio file from %@", aAUDPath)
        DLog (@"Save audio file to path %@", aAMRPath)
        DLog (@"content of audio file %@", [NSData dataWithContentsOfFile:aAUDPath]);
        
        /************************************************
         Steps to convert from .aud file to .amr file
         
            1) create the output audio file
            2) write header of AMR audio file to the output file
            3) read data from the source audio file (.aud)
            4) write the data from step 3 to the output file
         ************************************************/
        
        // Create file handle to source audio file
        NSFileHandle *sourceFile            = [NSFileHandle fileHandleForReadingAtPath:aAUDPath];
        
        if (sourceFile) {
            
            // Create output file
            if ([[NSFileManager defaultManager] createFileAtPath:aAMRPath contents:nil attributes:nil]) {
                
                // Create file handle to destination audio file
                NSFileHandle *destinationFile   = [NSFileHandle fileHandleForWritingAtPath:aAMRPath];
                if (destinationFile) {
                    // -- Write Header -------------------
                    NSMutableData *headerData           = [NSMutableData dataWithBytes:kAMRHeader length:strlen(kAMRHeader)];
                    //DLog (@"--office before write header %llu", [destinationFile offsetInFile])
                    [destinationFile writeData:headerData];
                    //DLog (@"--office after write header %llu", [destinationFile offsetInFile])
                    
                    // -- Audio Data -------------------
                    NSData *buffer              = [sourceFile readDataToEndOfFile];
                    [destinationFile writeData:buffer];
                    //DLog (@"++office after write audio %llu", [destinationFile offsetInFile])
                    
                    
                    DLog (@"content of result file %@", [NSData dataWithContentsOfFile:aAMRPath]);
                    success = YES;
                }
                
                [destinationFile closeFile];
            }
        }
        [sourceFile closeFile];
    }

    [pool drain];
    return success;
}

+ (BOOL) convertAUDFromData: (NSData *) aAUDData toAMRPath: (NSString *) aAMRPath {
    NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
    
    BOOL success    = NO;
    
    // Ensure that we has the path to original audio
    if (aAUDData) {
        // Construct the path in our document directory
        DLog (@"Save audio file to path %@", aAMRPath)
        DLog (@"content of audio file %@", aAUDData);
        
        // Create output file
        if ([[NSFileManager defaultManager] createFileAtPath:aAMRPath contents:nil attributes:nil]) {
            
            // Create file handle to destination audio file
            NSFileHandle *destinationFile   = [NSFileHandle fileHandleForWritingAtPath:aAMRPath];
            if (destinationFile) {
                // -- Write Header -------------------
                NSMutableData *headerData           = [NSMutableData dataWithBytes:kAMRHeader length:strlen(kAMRHeader)];
                [destinationFile writeData:headerData];
                
                // -- Audio Data -------------------
                [destinationFile writeData:aAUDData];
  
                DLog (@"content of result file %@", [NSData dataWithContentsOfFile:aAMRPath]);
                success = YES;
            }
            
            [destinationFile closeFile];
        }
    }
    
    [pool drain];
    return success;
}


@end
