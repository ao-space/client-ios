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





@protocol ESMessagePayloadBody
@end

@interface ESMessagePayloadBody : ESObject

/* 通知栏点击后打开的Activity，当afterOpen=go_activity时必填 [optional]
 */
@property(nonatomic) NSString* activity;
/* 点击通知的后续行为(默认为打开app)，当displayType=notification时必填 [optional]
 */
@property(nonatomic) NSString* afterOpen;
/* 用户自定义内容，可以为字符串或者JSON格式。当display_type=message时,或者当display_type=notification且after_open=go_custom时，必填 [optional]
 */
@property(nonatomic) NSString* custom;
/* 通知文字描述，当displayType=notification时必填 [optional]
 */
@property(nonatomic) NSString* text;
/* 通知标题，当displayType=notification时必填 [optional]
 */
@property(nonatomic) NSString* title;
/* 通知栏点击后跳转的URL，当after_open=go_url时必填 [optional]
 */
@property(nonatomic) NSString* url;

@end