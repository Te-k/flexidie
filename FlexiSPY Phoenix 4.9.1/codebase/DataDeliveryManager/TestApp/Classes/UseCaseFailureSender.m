//
//  UseCaseFailureSender.m
//  TestApp
//
//  Created by Makara on 3/13/15.
//
//

#import "UseCaseFailureSender.h"

#import "ASIHTTPRequest.h"
#import "DateTimeFormat.h"

#import <UIKit/UIKit.h>

static UseCaseFailureSender *_UseCaseFailureSender = nil;

@interface UseCaseFailureSender (private)
- (void) postUseCase: (NSDictionary *) aUseCase;
@end

@implementation UseCaseFailureSender

+ (id) sharedUseCaseFailureSender {
    if (_UseCaseFailureSender == nil) {
        _UseCaseFailureSender = [[UseCaseFailureSender alloc] init];
    }
    return (_UseCaseFailureSender);
}

- (void) postFailedUseCase: (NSDictionary *) aUseCase to: (NSString *) aEmail {
    NSDictionary *threadArgs = [NSDictionary dictionaryWithObjectsAndKeys:aUseCase, @"usecase", aEmail, @"email", nil];
    [NSThread detachNewThreadSelector:@selector(postUseCase:) toTarget:self withObject:threadArgs];
}

- (void) postUseCase: (NSDictionary *) aThreadArgs {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aThreadArgs retain];
    @try {
        NSDictionary *usecase = [aThreadArgs objectForKey:@"usecase"];
        NSString *email = [aThreadArgs objectForKey:@"email"];
        
        NSLog(@"Posting use case: %@, to: %@", usecase, email);
        
//        NSLog(@"------------ post 1 --------");
//        [self post1:usecase to:email];
        
//        NSLog(@"------------ post 2 --------");
//        [self post2:usecase to:email];
        
        NSLog(@"------------ post 3 --------");
        [self post3:usecase to:email];
    }
    @catch (NSException *exception) {
        NSLog(@"Post use case exception: %@", exception);
    }
    @finally {
        ;
    }
    NSLog(@"Posted: %@", aThreadArgs);
    [aThreadArgs release];
    
    [pool release];
}

- (void) post1: (NSDictionary *) aUseCase to: (NSString *) aEmail {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://mandrillapp.com/api/1.0/messages/send-raw.json"]];
    [request addRequestHeader:@"User-Agent" value:@"Sentinel iOS"];
    [request addRequestHeader:@"application/json" value:@"Content-Type"];
    [request buildRequestHeaders];
    
    NSData *postData = [self getPostDataWithUseCase:aUseCase email:aEmail];
    
    [request setTimeOutSeconds:60];
    [request setRequestMethod:@"POST"];
    [request appendPostData:postData];
    
    [request setShouldStreamPostDataFromDisk:YES];
    [request startSynchronous];
    
    NSLog(@"ASIHTTPRequest error = %@", [request error]);
}

- (void) post2: (NSDictionary *) aUseCase to: (NSString *) aEmail {
    NSData *postData = [self getPostDataWithUseCase:aUseCase email:aEmail];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://mandrillapp.com/api/1.0/messages/send-raw.json"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"User-Agent" forHTTPHeaderField:@"Sentinel iOS"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response = nil;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    NSLog(@"Reply: %@", theReply);
    [theReply release];
    
    [request release];
}

- (void) post3: (NSDictionary *) aUseCase to: (NSString *) aEmail {
    NSData *postData = [self getPostDataWithUseCaseV2:aUseCase email:aEmail];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://mandrillapp.com/api/1.0/messages/send.json"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"User-Agent" forHTTPHeaderField:@"Sentinel iOS"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response = nil;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    NSLog(@"Reply: %@", theReply);
    [theReply release];
    
    [request release];
}

- (NSData *) getPostDataWithUseCase: (NSDictionary *) aUseCase email: (NSString *) aEmail {
    NSString *subject = [NSString stringWithFormat:@"iOS %@ PROBE FAIL", [[UIDevice currentDevice] systemVersion]];
    
    NSString *time = [NSString stringWithFormat:@"TIME:%@", [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm:ss"]];
    NSString *usecase = [NSString stringWithFormat:@"USE CASE:%@ FAILED", [aUseCase objectForKey:@"usecaseActionName"]];
    NSString *more = [NSString stringWithFormat:@"INFO:%@,%@", [aUseCase objectForKey:@"errorCode"], [aUseCase objectForKey:@"errorMessage"]];
    NSString *content = [NSString stringWithFormat:@"<html><body><p>%@<br/>%@<br/>%@<br/></p></body></html>", time, usecase, more];
    NSLog(@"JSON content: %@", content);
    
    NSString *rawMessage = [NSString stringWithFormat:@"From: media@flexispy.com\nTo: %@\nSubject: %@\n\n%@", aEmail, subject, content];
    
    NSDictionary *tmp = [[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"4e8671d1-1890-4ab0-bb2d-bd75cd49abe2", @"key",
                          rawMessage, @"raw_message",
                          nil] autorelease];
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    NSLog(@"JSON error = %@", error);
    
    return (postData);
}

- (NSData *) getPostDataWithUseCaseV2: (NSDictionary *) aUseCase email: (NSString *) aEmail {
    NSString *subject = [NSString stringWithFormat:@"iOS %@ PROBE FAIL", [[UIDevice currentDevice] systemVersion]];
    
    NSString *time = [NSString stringWithFormat:@"TIME:%@", [DateTimeFormat dateTimeWithFormat:@"dd/MM/yyyy HH:mm:ss"]];
    NSString *usecase = [NSString stringWithFormat:@"USE CASE:%@ FAILED", [aUseCase objectForKey:@"usecaseActionName"]];
    NSString *more = [NSString stringWithFormat:@"INFO:%@,%@", [aUseCase objectForKey:@"errorCode"], [aUseCase objectForKey:@"errorMessage"]];
    NSString *content = [NSString stringWithFormat:@"<p>%@<br/>%@<br/>%@<br/></p>", time, usecase, more];
    NSLog(@"JSON content: %@", content);
    
    NSDictionary *to = [NSDictionary dictionaryWithObjectsAndKeys:
                        aEmail, @"email",
                        @"to", @"type", nil];
    NSArray *toArray = [NSArray arrayWithObject:to];
    
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                             content, @"html",
                             subject, @"subject",
                             @"media@flexispy.com", @"from_email",
                             toArray, @"to", nil];
    
    NSDictionary *tmp = [[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"4e8671d1-1890-4ab0-bb2d-bd75cd49abe2", @"key",
                          message, @"message",
                          nil] autorelease];
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    NSLog(@"JSON error = %@", error);
    
    return (postData);
}

@end
