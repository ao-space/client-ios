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


#import "ESArticleRes.h"
#import "ESPageInfo.h"
@protocol ESArticleRes;
@class ESArticleRes;
@protocol ESPageInfo;
@class ESPageInfo;



@protocol ESPageListResultArticleRes
@end

@interface ESPageListResultArticleRes : ESObject


@property(nonatomic) NSArray<ESArticleRes>* list;

@property(nonatomic) ESPageInfo* pageInfo;

@end
