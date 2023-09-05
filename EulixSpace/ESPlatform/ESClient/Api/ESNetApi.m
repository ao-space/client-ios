#import "ESNetApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"
#import "ESRspNetwork.h"
#import "ESRspWifiListRsp.h"
#import "ESRspWifiStatusRsp.h"
#import "ESWifiPwdReq.h"


@interface ESNetApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESNetApi

NSString* kESNetApiErrorDomain = @"ESNetApiErrorDomain";
NSInteger kESNetApiMissingParamErrorCode = 234513;

@synthesize apiClient = _apiClient;

#pragma mark - Initialize methods

- (instancetype) init {
    return [self initWithApiClient:[ESApiClient sharedClient]];
}


-(instancetype) initWithApiClient:(ESApiClient *)apiClient {
    self = [super init];
    if (self) {
        _apiClient = apiClient;
        _mutableDefaultHeaders = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark -

-(NSString*) defaultHeaderForKey:(NSString*)key {
    return self.mutableDefaultHeaders[key];
}

-(void) setDefaultHeaderValue:(NSString*) value forKey:(NSString*)key {
    [self.mutableDefaultHeaders setValue:value forKey:key];
}

-(NSDictionary *)defaultHeaders {
    return self.mutableDefaultHeaders;
}

#pragma mark - Api Methods

///
/// 获取盒子ip地址 [客户端调用]
/// 通过此接口查看盒子ip地址
///  @returns ESRspNetwork*
///
-(NSURLSessionTask*) pairNetLocalIpsWithCompletionHandler: 
    (void (^)(ESRspNetwork* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/pair/net/localips"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"text/plain"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"GET"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESRspNetwork*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspNetwork*)data, error);
                                }
                            }];
}

///
/// 获取盒子扫描到的wifi列表 [客户端]
/// 获取盒子扫描到的wifi列表 [root@WENOS ~]# curl http://172.17.0.1:5680/agent/v1/api/device/netconfig { \"code\": \"AG-200\", \"message\": \"OK\", \"wifiInfos\": [ \"name\": \"ZFY_Wifi\", \"addr\": \"18:3C:B7:5F:D4:58\" }, { \"name\": \"TY-Wifi\", \"addr\": \"C4:2B:44:DC:A1:D0\" } ] }
///  @returns ESRspWifiListRsp*
///
-(NSURLSessionTask*) pairNetNetConfigWithCompletionHandler: 
    (void (^)(ESRspWifiListRsp* output, NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/pair/net/netconfig"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"text/plain"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"GET"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESRspWifiListRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspWifiListRsp*)data, error);
                                }
                            }];
}

///
/// 设置wifi密码 [客户端]
/// 设置wifi密码 [root@WENOS ~]# curl -H \"Content-Type: application/json\" -X POST -d '{\"name\": \"18:3C:B7:5F:D4:8C\", \"password\":\"wrong_password\" }'  http://172.17.0.1:5680/agent/v1/api/device/netconfig {\"code\":\"AG-404\",\"message\":\"ConnectToWifi failed, []\"} [root@WENOS ~]# curl -H \"Content-Type: application/json\" -X POST -d '{\"name\": \"18:3C:B7:5F:D4:8C\", \"password\":\"wifi803b\" }'  http://172.17.0.1:5680/agent/v1/api/device/netconfig { \"code\": \"AG-200\", \"message\": \"OK\" }
///  @param req 需要连接的 wifi 名称和密码的json. 
///
///  @returns ESRspWifiStatusRsp*
///
-(NSURLSessionTask*) pairNetNetConfigSettingWithReq: (ESWifiPwdReq*) req
    completionHandler: (void (^)(ESRspWifiStatusRsp* output, NSError* error)) handler {
    // verify the required parameter 'req' is set
    if (req == nil) {
        NSParameterAssert(req);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"req"] };
            NSError* error = [NSError errorWithDomain:kESNetApiErrorDomain code:kESNetApiMissingParamErrorCode userInfo:userInfo];
            handler(nil, error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/agent/v1/api/pair/net/netconfig"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[@"application/json"]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[@"text/plain"]];

    // Authentication setting
    NSArray *authSettings = @[];

    id bodyParam = nil;
    NSMutableDictionary *formParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localVarFiles = [[NSMutableDictionary alloc] init];
    bodyParam = req;

    return [self.apiClient requestWithPath: resourcePath
                                    method: @"POST"
                                pathParams: pathParams
                               queryParams: queryParams
                                formParams: formParams
                                     files: localVarFiles
                                      body: bodyParam
                              headerParams: headerParams
                              authSettings: authSettings
                        requestContentType: requestContentType
                       responseContentType: responseContentType
                              responseType: @"ESRspWifiStatusRsp*"
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler((ESRspWifiStatusRsp*)data, error);
                                }
                            }];
}



@end
