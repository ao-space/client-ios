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


#import "ESBoxRegistryResultNetworkClient.h"
@protocol ESBoxRegistryResultNetworkClient;
@class ESBoxRegistryResultNetworkClient;



@protocol ESUserEntity
@end

@interface ESUserEntity : ESObject


@property(nonatomic) NSString* aoId;

@property(nonatomic) NSString* authKey;

@property(nonatomic) NSString* clientRegKey;

@property(nonatomic) NSString* clientUUID;

@property(nonatomic) NSDate* createAt;

@property(nonatomic) NSNumber* _id;

@property(nonatomic) NSString* image;

@property(nonatomic) NSString* imageMd5;

@property(nonatomic) NSString* personalName;

@property(nonatomic) NSString* personalSign;

@property(nonatomic) NSString* phoneModel;

@property(nonatomic) ESBoxRegistryResultNetworkClient* role;

@property(nonatomic) NSString* userDomain;

@property(nonatomic) NSString* userRegKey;

@end
