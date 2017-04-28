//
//  VideoDownloadOperation.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 7/25/2557 BE.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>




@protocol VideoDownloadDelegate <NSObject>

@required
- (void) videoDidFinishDownload: (NSDictionary *) aInfo;

@end




static NSString * const kRelayInfoKey                   = @"relayInfoKey";
static NSString * const kIsSuccessKey                   = @"isSuccessKey";
static NSString * const kIsSuccessReasonKey             = @"isSuccessReasonKey";
static NSString * const kVideoOutputKey                 = @"videoOutputKey";
static NSString * const kVideoOutputExtensionKey        = @"videoOutputExtensionKey";


@interface VideoDownloadOperation : NSOperation {
    id          mDelegate;
    NSString    *mVideoPathString;
    NSString    *mVideoOutputPath;
}

@property (nonatomic, retain) NSDictionary *mReleyInfo;

- (instancetype) initWithVideoPath: (NSString *) aVideoPathString
                        outputPath: (NSString *) aVideoOutputPath
                          delegate: (id) aDelegate;
@end




#pragma mark - ALAsset Category



@interface ALAsset (Export)
- (BOOL) exportDataToURL: (NSURL*) fileURL error: (NSError**) error;
@end

