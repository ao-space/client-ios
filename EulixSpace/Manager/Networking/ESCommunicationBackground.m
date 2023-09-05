/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESCommunicationBackground.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/10/11.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESCommunicationBackground.h"
#import "ESGlobalMacro.h"
#import "ESLocalPath.h"
#import "ESNetworking.h"
#import "ESRealCallRequest.h"
#import "ESUploadEntity.h"
#import "ESSpaceGatewayGenericCallServiceApi.h"

typedef void (^ESSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

@interface ESSessionManagerTaskDelegate : NSObject

@property (nonatomic, strong) NSMutableData *mutableData;

@property (nonatomic, copy) NSString *localDataFile;

@property (nonatomic, copy) ESSessionTaskCompletionHandler completionHandler;

@end

@implementation ESSessionManagerTaskDelegate

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _mutableData = [NSMutableData data];
    return self;
}

@end

@interface ESCommunicationBackground ()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSMutableDictionary *taskDelegate;

@property (nonatomic, copy) void (^taskDidSendBodyData)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);

@end

@implementation ESCommunicationBackground

+ (instancetype)shared {
    static dispatch_once_t once = 0;
    static id instance = nil;

    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.lock = [[NSLock alloc] init];
    self.taskDelegate = NSMutableDictionary.dictionary;
    return self;
}

- (void)setTaskDidSendBodyDataBlock:(void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block {
    self.taskDidSendBodyData = block;
}

static NSString *ESCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

- (NSURLSessionUploadTask *)uploadFile:(NSString *)path
                             serverUrl:(NSString *)serverUrl
                                entity:(ESUploadEntity *)entity
                           realRequest:(ESRealCallRequest *)realRequest
                           callRequest:(ESCallRequest *)callRequest
                               session:(NSURLSession *)session
                     completionHandler:(ESSessionTaskCompletionHandler)completionHandler {
    NSURL *url = [NSURL URLWithString:serverUrl];
    NSString *boundary = ESCreateMultipartFormBoundary();
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [realRequest.headers enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        [urlRequest setValue:obj forHTTPHeaderField:key];
    }];

    NSData *bodyData = [self buildBodyDataFile:path entity:entity request:callRequest boundary:boundary];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%zd", bodyData.length] forHTTPHeaderField:@"Content-Length"];
    NSString *localDataFile = [NSString stringWithFormat:@"%@.upload", path];
    [bodyData writeToFile:localDataFile atomically:YES];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:urlRequest fromFile:[NSURL fileURLWithPath:localDataFile]];
    [self addTaskDelegate:task completionHandler:completionHandler localDataFile:localDataFile];
    return task;
}

- (void)addTaskDelegate:(NSURLSessionUploadTask *)task completionHandler:(ESSessionTaskCompletionHandler)completionHandler localDataFile:(NSString *)localDataFile {
    [self.lock lock];
    ESSessionManagerTaskDelegate *delegate = [[ESSessionManagerTaskDelegate alloc] init];
    delegate.completionHandler = completionHandler;
    delegate.localDataFile = localDataFile;
    self.taskDelegate[@(task.taskIdentifier)] = delegate;
    [self.lock unlock];
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    [self.lock lock];
    self.taskDelegate[@(task.taskIdentifier)] = nil;
    [self.lock unlock];
}

static NSString *const kESMultipartFormCRLF = @"\r\n";

- (NSData *)buildBodyDataFile:(NSString *)path
                       entity:(ESUploadEntity *)entity
                      request:(ESCallRequest *)request
                     boundary:(NSString *)boundary {
    NSMutableData *bodyData = [NSMutableData data];
    NSMutableString *bodyStr = [NSMutableString string];
    ///callRequest
    [bodyStr appendFormat:@"--%@%@", boundary, kESMultipartFormCRLF];
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"callRequest\""];
    [bodyStr appendString:kESMultipartFormCRLF];
    [bodyStr appendFormat:@"Content-Type: application/json"];
    [bodyStr appendString:kESMultipartFormCRLF];
    [bodyStr appendString:kESMultipartFormCRLF];
    [bodyStr appendString:request.toJSONString];
    [bodyStr appendString:kESMultipartFormCRLF];

    ///file
    [bodyStr appendFormat:@"--%@\r\n", boundary];
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"", entity.filename];
    [bodyStr appendString:kESMultipartFormCRLF];
    [bodyStr appendFormat:@"Content-Type: application/octet-stream"];
    [bodyStr appendString:kESMultipartFormCRLF];
    [bodyStr appendString:kESMultipartFormCRLF];

    NSData *start = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:start];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    [bodyData appendData:fileData];
    return bodyData;
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(__unused NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        ESSessionManagerTaskDelegate *delegate = self.taskDelegate[@(task.taskIdentifier)];
        [self removeDelegateForTask:task];
        [delegate.localDataFile clearCachePath];
        //__block id responseObject = nil;
        NSData *data = nil;
        if (delegate.mutableData) {
            data = [delegate.mutableData copy];
            //We no longer need the reference, so nil it out to gain back some memory.
            delegate.mutableData = nil;
        }
        if (delegate.completionHandler) {
            delegate.completionHandler(task.response, data, error);
        }
    });
}

/* Sent if a task requires a new, unopened body stream.  This may be
 * necessary when authentication has failed for any request that
 * involves a body stream.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    needNewBodyStream:(void (^)(NSInputStream *_Nullable bodyStream))completionHandler {
    NSInputStream *inputStream = nil;
    if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }
    if (!inputStream) {
        inputStream = task.originalRequest.HTTPBodyStream;
    }
    if (completionHandler) {
        completionHandler(inputStream);
    }
}

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    ESDLog(@"%s", __func__);
}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler {
    ESDLog(@"%s", __func__);
    if (completionHandler) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    ESDLog(@"%s", __func__);
    [ESNetworking.shared URLSessionDidFinishEventsForBackgroundURLSession];
}

- (void)URLSession:(NSURLSession *)session
          downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didResumeAtOffset:(int64_t)fileOffset
    expectedTotalBytes:(int64_t)expectedTotalBytes {
    ESDLog(@"fileOffset:%lld expectedTotalBytes:%lld", fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if (totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"File-Size"];
        if (contentLength) {
            totalUnitCount = (int64_t)[contentLength longLongValue];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.taskDidSendBodyData) {
            self.taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalUnitCount);
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                    newRequest:(NSURLRequest *)request
             completionHandler:(void (^)(NSURLRequest *_Nullable))completionHandler {
    //ESDLog(@"willPerformHTTPRedirection ------> %@",response);
    ESDLog(@"%s", __func__);
}

/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 *
 * This method will not be called for background upload tasks (which cannot be converted to download tasks).
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    ESDLog(@"%s", __func__);
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    ESDLog(@"%s", __func__);
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    ESDLog(@"%s", __func__);
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    ESDLog(@"%s", __func__);
    ESDLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    ESSessionManagerTaskDelegate *delegate = self.taskDelegate[@(dataTask.taskIdentifier)];
    [delegate.mutableData appendData:data];
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    willCacheResponse:(NSCachedURLResponse *)proposedResponse
    completionHandler:(void (^)(NSCachedURLResponse *_Nullable cachedResponse))completionHandler {
    ESDLog(@"%s", __func__);
}

@end
