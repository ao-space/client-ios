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


#import "ESNetwork.h"
@protocol ESNetwork;
@class ESNetwork;



@protocol ESRspNetwork
@end

@interface ESRspNetwork : ESObject


@property(nonatomic) NSString* code;

@property(nonatomic) NSString* message;

@property(nonatomic) NSString* requestId;

@property(nonatomic) NSArray<ESNetwork>* results;

@end
