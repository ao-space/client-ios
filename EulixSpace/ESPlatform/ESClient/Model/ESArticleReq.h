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





@protocol ESArticleReq
@end

@interface ESArticleReq : ESObject

/* 目录id [optional]
 */
@property(nonatomic) NSNumber* cataId;
/* 文章内容 [optional]
 */
@property(nonatomic) NSString* content;
/* 是否发布 [optional]
 */
@property(nonatomic) NSNumber* isPublish;
/* 标题 
 */
@property(nonatomic) NSString* title;

@end
