#import <Foundation/Foundation.h>
#import "ESObject.h"

/**
* EulixOS Platform Server API
* Platform open APIs
*
* OpenAPI spec version: 0.1.0
* Contact: dev-support@eulixos.com
*
* NOTE: This class is auto generated by the swagger code generator program.
* https://github.com/swagger-api/swagger-codegen.git
* Do not edit the class manually.
*/





@protocol ESAuthorizedTerminalResult
@end

@interface ESAuthorizedTerminalResult : ESObject


@property(nonatomic) NSString* address;

@property(nonatomic) NSString* aoid;

@property(nonatomic) NSString* clientRegKey;

@property(nonatomic) NSDate* loginTime;

@property(nonatomic) NSNumber* online;

@property(nonatomic) NSString* terminalModel;

@property(nonatomic) NSString* terminalType;

@property(nonatomic) NSString* uuid;

@end
