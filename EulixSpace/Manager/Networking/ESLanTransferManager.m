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
//  ESLanTransferManager.m
//  EulixSpace
//
//  Created by dazhou on 2023/2/2.
//  Copyright © 2023 eulix.xyz. All rights reserved.
//

#import "ESLanTransferManager.h"
#import "ESGlobalMacro.h"
#import "ESLocalPath.h"
#import "ESNetworking.h"
#import "ESSpaceGatewayGenericCallServiceApi.h"
#import "ESBoxManager.h"
#import "ESServiceNameHeader.h"
#import "ESNetworkRequestManager.h"


typedef void (^ESLanTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

@interface ESLanTaskDelegate : NSObject

@property (nonatomic, copy) ESLanTaskCompletionHandler completionHandler;
@property (nonatomic, copy) ESProgressHandler progressHandler;

@property (nonatomic, strong) NSString * downloadTargetPath;
@property (nonatomic, copy) NSURL *downloadFileURL;

@end


@implementation ESLanTaskDelegate

@end


@interface ESLanTransferManager ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSData * certData;
@property (nonatomic, strong) NSMutableDictionary *taskDelegate;
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, assign) BOOL isReqingCert;

@end

@implementation ESLanTransferManager


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
    [self initSession];

    NSString * lanCertKey = [NSString stringWithFormat:@"%@_LanCertKey", ESBoxManager.activeBox.boxUUID];
    NSString * localCertString = [[NSUserDefaults standardUserDefaults] objectForKey:lanCertKey];
    if (localCertString) {
        ESDLog(@"[上传下载] 自签名证书-有本地存储");
        NSData * certData = [[NSData alloc] initWithBase64EncodedString:localCertString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        self.certData = certData;
    }
    
    return self;
}

- (void)initSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.HTTPShouldUsePipelining = YES;
    configuration.HTTPMaximumConnectionsPerHost = 4;
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    configuration.timeoutIntervalForRequest = 60 * 60;
    configuration.timeoutIntervalForResource = 60 * 60;
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.session = session;
}

- (BOOL)hasCertData {
    return self.certData != nil && self.certData.length > 0;
}

- (void)reqCertIfNot {
    if (![self hasCertData]) {
        [self reqCert];
    }
}

- (void)reqCert {
    if (self.isReqingCert) {
        return;
    }
    self.isReqingCert = YES;
    [ESNetworkRequestManager sendCallRequestWithServiceName:eulixspace_agent_service apiName:get_lan_cert queryParams:nil header:nil body:nil modelName:nil successBlock:^(NSInteger requestId, id  _Nullable response) {
        self.isReqingCert = NO;
        NSString * certStr = response[@"cert"];
        if (!certStr) {
            ESDLog(@"[上传下载] 自签名证书请求-内容为nil");
            return;
        }
        
        NSString * lanCertKey = [NSString stringWithFormat:@"%@_LanCertKey", ESBoxManager.activeBox.boxUUID];
        NSString * localCertString = [[NSUserDefaults standardUserDefaults] objectForKey:lanCertKey];
        if (localCertString && [localCertString isEqualToString:certStr]) {
            ESDLog(@"[上传下载] 自签名证书请求-内容相同");
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:certStr forKey:lanCertKey];
        NSData * certData = [[NSData alloc] initWithBase64EncodedString:certStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        self.certData = certData;
        ESDLog(@"[上传下载] 自签名证书请求-成功");
    } failBlock:^(NSInteger requestId, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.isReqingCert = NO;
        ESDLog(@"[上传下载] 自签名证书请求-失败:%@", error);
    }];
}

- (NSURLSessionUploadTask *)uploadFile:(NSString *)filePath
                                  host:(NSString *)host
                                 query:(NSDictionary *)query
                                token:(NSString *)token
                              progress:(ESProgressHandler)progress
                     completionHandler:(ESLanTaskCompletionHandler)completionHandler {
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://%@:%ld/space/v1/api/multipart/upload", host, [self getTlsPort]];
    NSURL * url = [self createUrl:urlString query:query];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:token forHTTPHeaderField:@"Token"];

    NSURLSessionUploadTask * task = [self.session uploadTaskWithRequest:urlRequest fromFile:[NSURL fileURLWithPath:filePath]];
    [self addDelegateForUploadTask:task progress:progress completionHandler:completionHandler];
    
    return task;
}

- (NSURLSessionDownloadTask *)downloadFile:(NSString *)filePath
                                      host:(NSString *)host
                                     query:(NSDictionary *)query
                                    header:(NSDictionary *)header
                                  progress:(ESProgressHandler)progress
                         completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSString * urlString = [[NSString alloc] initWithFormat:@"https://%@:%ld/space/v1/api/file/download", host, [self getTlsPort]];
    NSURL * url = [self createUrl:urlString query:query];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [header enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * obj, BOOL * _Nonnull stop) {
        [urlRequest setValue:obj forHTTPHeaderField:key];
    }];
    
    NSURLSessionDownloadTask * task = [self.session downloadTaskWithRequest:urlRequest];
    [self addDelegateForDownloadTask:task path:filePath progress:progress completionHandler:completionHandler];
    return task;
}

- (long)getTlsPort {
    ESBoxIPModel * ipModel = [ESBoxManager.activeBox.boxIPResp getConnectedBoxIP];
    long port = 443;
    if (ipModel && ipModel.tlsPort > 0) {
        port = ipModel.tlsPort;
    }
    return port;
}

- (NSURL *)createUrl:(NSString *)urlString query:(NSDictionary *)query {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:urlString];
    NSMutableArray *queryItems = [NSMutableArray array];
    [query enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ( [key isKindOfClass:[NSString class]]) {
            NSURLQueryItem * newQueryItem = [[NSURLQueryItem alloc] initWithName:key value:obj];
            [queryItems addObject:newQueryItem];
        }
    }];
    if (queryItems.count > 0) {
        [components setQueryItems:[queryItems copy]];
    }
    urlString = [components URL].absoluteString;
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    return url;
}

- (void)addDelegateForUploadTask:(NSURLSessionUploadTask *)task progress:(ESProgressHandler)progress completionHandler:(ESLanTaskCompletionHandler)completionHandler {
    [self.lock lock];
    ESLanTaskDelegate *delegate = [[ESLanTaskDelegate alloc] init];
    delegate.progressHandler = progress;
    delegate.completionHandler = completionHandler;
    self.taskDelegate[@(task.taskIdentifier)] = delegate;
    [self.lock unlock];
}

- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)task path:(NSString *)filePath progress:(ESProgressHandler)progress completionHandler:(ESLanTaskCompletionHandler)completionHandler {
    [self.lock lock];
    ESLanTaskDelegate *delegate = [[ESLanTaskDelegate alloc] init];
    delegate.completionHandler = completionHandler;
    delegate.progressHandler = progress;
    delegate.downloadTargetPath = filePath;
    self.taskDelegate[@(task.taskIdentifier)] = delegate;
    [self.lock unlock];
}

#pragma mark - NSURLSession delegate
/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(__unused NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error {
    ESLanTaskDelegate *delegate = [self delegateForTask:task];
    [self removeDelegateForTask:task];
    
    if (delegate.completionHandler && error) {
        delegate.completionHandler(task.response, nil, error);
    }
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
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    ESDLog(@"[上传下载] 自签名证书验证 - 开始");
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust]) {
        do
        {
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            if(nil == serverTrust)
                break; /* failed */
            /**
             *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA），请替换掉你的证书名称
             */
            NSData * caCert = self.certData;
            if(nil == caCert) {
                break; /* failed */
            }
            
            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
            if(nil == caRef) {
                break; /* failed */
            }

            //可以添加多张证书
            NSArray *caArray = @[(__bridge id)(caRef)];

            if(nil == caArray) {
                break; /* failed */
            }

            //将读取的证书设置为服务端帧数的根证书
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            if(!(errSecSuccess == status)) {
                break; /* failed */
            }
            
            NSMutableArray *policies = [NSMutableArray array];
//            if (self.validatesDomainName) {
//                [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
//            } else {
//                [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
//            }

            [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];

            SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
            
            SecTrustRef allowedTrust = nil;
            SecPolicyRef policy = SecPolicyCreateBasicX509();
            SecTrustCreateWithCertificates(caRef, policy, &allowedTrust);
            CFErrorRef error;
            bool re = SecTrustEvaluateWithError(serverTrust, &error);
            CFRelease(policy);
            
            if (!re || error) {
                ESDLog(@"[上传下载] 自签名证书验证失败 - %@", error);
                break;
            }

            ESDLog(@"[上传下载] 自签名证书验证 - 通过");
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
            return [[challenge sender] useCredential: credential
                          forAuthenticationChallenge: challenge];

        }
        while(0);
    }

    // If check failed, then req lastest Cert again.
    [self reqCert];
    
    // Bad dog
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge,credential);
    return [[challenge sender] cancelAuthenticationChallenge: challenge];
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
//    [ESNetworking.shared URLSessionDidFinishEventsForBackgroundURLSession];
}

/* Sent periodically to notify the delegate of upload progress.  This
 * information is also available as properties of the task.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if (totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"File-Size"];
        if (contentLength) {
            totalUnitCount = (int64_t)[contentLength longLongValue];
        }
    }

    ESLanTaskDelegate * delegate = [self delegateForTask:task];
    if (delegate.progressHandler) {
        delegate.progressHandler(bytesSent, totalBytesSent, totalUnitCount);
    }
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

    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
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
    ESLanTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate.completionHandler) {
        delegate.completionHandler(dataTask.response, data, nil);
    }
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

#pragma mark - NSURLSessionDownloadDelegate
/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    ESLanTaskDelegate *delegate = [self delegateForTask:downloadTask];
    NSError * error;
    
    if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)downloadTask.response;
        if (response.statusCode >= 400) {
            NSData * data = [NSData dataWithContentsOfURL:location];
            NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dict = [str toJson];
            NSString * domain = [[NSString alloc] initWithFormat:@"statusCode:%ld", response.statusCode];
            error = [NSError errorWithDomain:domain code:response.statusCode userInfo:dict];
            ESDLog(@"[上传下载] 下载内容: %@", str);

            if (delegate.completionHandler) {
                delegate.completionHandler(downloadTask.response, nil, error);
            }
            return;
        }
    }
    

    NSURL * url = [NSURL fileURLWithPath:delegate.downloadTargetPath];
    delegate.downloadFileURL = url;
    if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:delegate.downloadFileURL error:&error]) {
        ESDLog(@"[上传下载] 下载结束-文件写入-失败 %@", error);
        delegate.downloadFileURL = nil;
    }
    if (delegate.completionHandler) {
        delegate.completionHandler(downloadTask.response, delegate.downloadFileURL, error);
    }
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    ESLanTaskDelegate *delegate = [self delegateForTask:downloadTask];

    int64_t fileSize = totalBytesExpectedToWrite;
    if (totalBytesExpectedToWrite == -1) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)downloadTask.response;
        fileSize = [response.allHeaderFields[@"File-Size"] longLongValue];
    }
    
    if (delegate.progressHandler) {
        delegate.progressHandler(bytesWritten, totalBytesWritten, fileSize);
    }
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (ESLanTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    ESLanTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.taskDelegate[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return delegate;
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    [self.lock lock];
    self.taskDelegate[@(task.taskIdentifier)] = nil;
    [self.lock unlock];
}

@end
