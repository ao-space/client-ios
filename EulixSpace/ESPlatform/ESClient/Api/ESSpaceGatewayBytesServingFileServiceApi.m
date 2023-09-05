#import "ESSpaceGatewayBytesServingFileServiceApi.h"
#import "ESQueryParamCollection.h"
#import "ESApiClient.h"


@interface ESSpaceGatewayBytesServingFileServiceApi ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *mutableDefaultHeaders;

@end

@implementation ESSpaceGatewayBytesServingFileServiceApi

NSString* kESSpaceGatewayBytesServingFileServiceApiErrorDomain = @"ESSpaceGatewayBytesServingFileServiceApiErrorDomain";
NSInteger kESSpaceGatewayBytesServingFileServiceApiMissingParamErrorCode = 234513;

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
/// 
/// 
///  @param ak  (optional)
///
///  @param folder  (optional)
///
///  @returns void
///
-(NSURLSessionTask*) spaceV1ApiGatewayMfListGetWithAk: (NSString*) ak
    folder: (NSString*) folder
    completionHandler: (void (^)(NSError* error)) handler {
    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/mf/list"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (ak != nil) {
        queryParams[@"ak"] = ak;
    }
    if (folder != nil) {
        queryParams[@"folder"] = folder;
    }
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[]];

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
                              responseType: nil
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler(error);
                                }
                            }];
}

///
/// 
/// 媒体文件通过 Bytes(https://en.wikipedia.org/wiki/Byte_serving) 访问接口。
///  @param fileName 用于指定获取文件的名称，如果使用 betag 或者 uuid 模式，需要加上相应的前缀，例如：betag:{tag}, uuid:{uuid} 
///
///  @param token 用于指定获取文件的 accessToken 
///
///  @param encrypted 用于启用或关闭加密, ture：启用，false：关闭 (optional)
///
///  @param range 用于指定获取部分文件的范围 (optional)
///
///  @returns void
///
-(NSURLSessionTask*) spaceV1ApiGatewayMfTokenFileNameGetWithFileName: (NSString*) fileName
    token: (NSString*) token
    encrypted: (NSNumber*) encrypted
    range: (NSString*) range
    completionHandler: (void (^)(NSError* error)) handler {
    // verify the required parameter 'fileName' is set
    if (fileName == nil) {
        NSParameterAssert(fileName);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"fileName"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayBytesServingFileServiceApiErrorDomain code:kESSpaceGatewayBytesServingFileServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    // verify the required parameter 'token' is set
    if (token == nil) {
        NSParameterAssert(token);
        if(handler) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"Missing required parameter '%@'", nil),@"token"] };
            NSError* error = [NSError errorWithDomain:kESSpaceGatewayBytesServingFileServiceApiErrorDomain code:kESSpaceGatewayBytesServingFileServiceApiMissingParamErrorCode userInfo:userInfo];
            handler(error);
        }
        return nil;
    }

    NSMutableString* resourcePath = [NSMutableString stringWithFormat:@"/space/v1/api/gateway/mf/{token}/{fileName}"];

    NSMutableDictionary *pathParams = [[NSMutableDictionary alloc] init];
    if (fileName != nil) {
        pathParams[@"fileName"] = fileName;
    }
    if (token != nil) {
        pathParams[@"token"] = token;
    }

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    if (encrypted != nil) {
        queryParams[@"encrypted"] = [encrypted isEqual:@(YES)] ? @"true" : @"false";
    }
    NSMutableDictionary* headerParams = [NSMutableDictionary dictionaryWithDictionary:self.apiClient.configuration.defaultHeaders];
    [headerParams addEntriesFromDictionary:self.defaultHeaders];
    if (range != nil) {
        headerParams[@"Range"] = range;
    }
    // HTTP header `Accept`
    NSString *acceptHeader = [self.apiClient.sanitizer selectHeaderAccept:@[]];
    if(acceptHeader.length > 0) {
        headerParams[@"Accept"] = acceptHeader;
    }

    // response content type
    NSString *responseContentType = [[acceptHeader componentsSeparatedByString:@", "] firstObject] ?: @"";

    // request content type
    NSString *requestContentType = [self.apiClient.sanitizer selectHeaderContentType:@[]];

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
                              responseType: nil
                           completionBlock: ^(id data, NSError *error) {
                                if(handler) {
                                    handler(error);
                                }
                            }];
}



@end
