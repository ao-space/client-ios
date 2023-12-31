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





@protocol ESSubdomainUpdateResult
@end

@interface ESSubdomainUpdateResult : ESObject

/* 盒子的 UUID, success为true时返回 [optional]
 */
@property(nonatomic) NSString* boxUUID;
/* 错误码, success为false时返回 [optional]
 */
@property(nonatomic) NSNumber* code;
/* 错误消息, success为false时返回 [optional]
 */
@property(nonatomic) NSString* error;
/* 推荐的subdomain, success为false时返回 [optional]
 */
@property(nonatomic) NSArray<NSString*>* recommends;
/* 全局唯一的 subdomain, success为true时返回 [optional]
 */
@property(nonatomic) NSString* subdomain;
/* 是否成功 [optional]
 */
@property(nonatomic) NSNumber* success;
/* 用户id, success为true时返回 [optional]
 */
@property(nonatomic) NSString* userId;

@end
