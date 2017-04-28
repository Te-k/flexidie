//
//  PrinterFileMonitor.h
//  blbld
//
//  Created by Makara Khloth on 10/26/16.
//
//

#import <Foundation/Foundation.h>

@interface PrinterFileMonitor : NSObject {
    FSEventStreamRef mStream;
    NSOperationQueue *mQueue;
    
    NSUInteger mPrinterJobID;
    NSString *mPrinterFilePath;
}

@property (readonly) NSString *mPrinterFilePath;

- (instancetype) initWithPrinterFilePath: (NSString *) aPath;

- (void) startCapture;
- (void) stopCapture;

@end
