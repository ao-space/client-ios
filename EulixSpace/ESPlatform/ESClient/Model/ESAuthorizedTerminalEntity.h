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





@protocol ESAuthorizedTerminalEntity
@end

@interface ESAuthorizedTerminalEntity : ESObject


@property(nonatomic) NSString* aoid;

@property(nonatomic) NSString* clientRegKey;

@property(nonatomic) NSDate* createAt;

@property(nonatomic) NSDate* expireAt;

@property(nonatomic) NSNumber* _id;

@property(nonatomic) NSString* terminalMode;

@property(nonatomic) NSNumber* userid;

@property(nonatomic) NSString* uuid;

@end
