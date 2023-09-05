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
//  ESWebViewJavascriptBridge.m
//  ExampleApp-iOS
//
//  Created by KongBo on 2022/6/2.
//  Copyright © 2022 Marcus Westin. All rights reserved.
//

#import "ESWebViewJavascriptBridge.h"

@interface ESWebViewJavascriptBridge ()<WKScriptMessageHandler>

//@property (weak, nonatomic) id <WebViewJavascriptBridgeBaseDelegate> delegate;
@property (strong, nonatomic) NSMutableArray* startupMessageQueue;
@property (strong, nonatomic) NSMutableDictionary* responseCallbacks;
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;
@property (strong, nonatomic) ESJBHandler messageHandler;

@end

@implementation ESWebViewJavascriptBridge {
    __weak WKWebView* _webView;
    __weak id<WKNavigationDelegate> _webViewDelegate;
    long _uniqueId;
}

static bool logging = false;
static int logMaxLength = 500;

+ (void)enableLogging { logging = true; }
+ (void)setLogMaxLength:(int)length { logMaxLength = length;}

+ (instancetype)bridgeForWebView:(WKWebView*)webView {
    ESWebViewJavascriptBridge* bridge = [[self alloc] init];
    [bridge _setupInstance:webView];
    [bridge reset];
    return bridge;
}

- (id)init {
    if (self = [super init]) {
        self.messageHandlers = [NSMutableDictionary dictionary];
        self.startupMessageQueue = [NSMutableArray array];
        self.responseCallbacks = [NSMutableDictionary dictionary];
        _uniqueId = 0;
    }
    return self;
}

- (void) _setupInstance:(WKWebView*)webView {
    _webView = webView;
//    _webView.navigationDelegate = self;
    _webView.configuration.userContentController = [WKUserContentController new];
}

- (void)dealloc {
    self.startupMessageQueue = nil;
    self.responseCallbacks = nil;
    self.messageHandlers = nil;
}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
    
    [self registerHandler:@"dispatchMessageFromJs" handler:^(id data, ESJBResponseCallback responseCallback) {
        NSDictionary *dic = (NSDictionary *)data;
        if ([dic isKindOfClass:[NSDictionary class]] &&
            [dic.allKeys containsObject:@"callbackId"] &&
            [dic.allKeys containsObject:@"responseData"]) {
            NSString *callbackId = dic[@"callbackId"];
            id responseData = dic[@"responseData"];
           if(callbackId.length > 0 &&  [self.responseCallbacks.allKeys containsObject:callbackId]) {
               ESJBResponseCallback callback =  self.responseCallbacks[callbackId];
               callback(responseData);
               [self.responseCallbacks removeObjectForKey:callbackId];
            }
        }
    }];
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
}

- (void)send:(id)data {
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(ESJBResponseCallback)responseCallback {
    [self sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id _Nullable)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id _Nullable)data responseCallback:(ESJBResponseCallback _Nullable)responseCallback {
    [self sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(ESJBHandler)handler {
    if (handlerName.length <= 0 || !handler) {
        return;
    }
    _messageHandlers[handlerName] = [handler copy];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:handlerName];
}

- (void)removeHandler:(NSString *)handlerName {
    [_messageHandlers removeObjectForKey:handlerName];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (message.name.length <= 0) {
        return;
    }
    if ([_messageHandlers.allKeys containsObject:message.name]) {
        ESJBHandler handler = _messageHandlers[message.name];
     
        ESJBResponseCallback responseCallback = NULL;
        NSString* callbackId = message.body[@"jsCallbackId"];
        if (callbackId) {
            responseCallback = ^(id responseData) {
                if (responseData == nil) {
                    responseData = [NSNull null];
                }
                
                WVJBMessage* msg = @{ @"jsCallbackId":callbackId,
                                      @"responseData": @{//响应数据
                                          @"code": responseData ? @(200) : @(-1),          //响应码，200-成功
                                          @"data": responseData,              //返回数据，原生侧业务方法返回数据，以JSON格式封装
                                          @"msg": @""              //信息描述
                                          }};
                if ([responseData isKindOfClass:[NSDictionary class]] &&
                    [[(NSDictionary *)responseData allKeys] containsObject:@"code"] &&
                    [[(NSDictionary *)responseData allKeys] containsObject:@"data"] &&
                    [[(NSDictionary *)responseData allKeys] containsObject:@"msg"]) {
                    msg = @{ @"jsCallbackId" : callbackId,
                             @"responseData" : responseData};
                }
                [self _dispatchMessageFromNativeCallback:msg];
            };
        } else {
            responseCallback = ^(id ignoreResponseData) {
            };
        }
        
        if (!handler) {
            NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
            return;
        }
        
        if ([message.body isKindOfClass:[NSDictionary class]] &&
            [[(NSDictionary *)message.body allKeys] containsObject:@"jsCallbackId"] &&
            [[(NSDictionary *)message.body allKeys] containsObject:@"method"] &&
            [[(NSDictionary *)message.body allKeys] containsObject:@"params"]) {
            handler(message.body[@"params"], responseCallback);
            return;
        }
        
        handler(message.body, responseCallback);
    }
 
}

- (void)_dispatchMessageFromNativeCallback:(WVJBMessage*)message {
    NSString *messageJSON = [self _serializeMessage:message pretty:NO];
    [self _log:@"dispatchMessageFromNative" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge.dispatchMessageFromNative('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];

    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
//    [_base disableJavscriptAlertBoxSafetyTimeout];
}

- (void)sendData:(id)data responseCallback:(ESJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"params"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"jsmethodName"] = handlerName;
    }
    [self _dispatchMessage:message];
}

- (void)_dispatchMessage:(WVJBMessage*)message {
    NSString *messageJSON = [self _serializeMessage:message pretty:NO];
    [self _log:@"SEND" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge.nativeCallJsMethod('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];

    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

- (void) _evaluateJavascript:(NSString *)javascriptCommand {
    [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
}

- (NSString *)_serializeMessage:(id)message pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json {
    if (!logging) { return; }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        NSLog(@"WVJB %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        NSLog(@"WVJB %@: %@", action, json);
    }
}

@end
