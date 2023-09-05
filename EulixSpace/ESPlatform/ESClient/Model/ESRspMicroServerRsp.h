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


#import "ESMicroServerRsp.h"
@protocol ESMicroServerRsp;
@class ESMicroServerRsp;



@protocol ESRspMicroServerRsp
@end

@interface ESRspMicroServerRsp : ESObject


@property(nonatomic) NSString* code;

@property(nonatomic) NSString* message;

@property(nonatomic) NSString* requestId;

@property(nonatomic) ESMicroServerRsp* results;

@end
