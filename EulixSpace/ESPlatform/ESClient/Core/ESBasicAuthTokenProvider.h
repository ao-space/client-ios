/** The `ESBasicAuthTokenProvider` class creates a basic auth token from username and password.
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen
 * Do not edit the class manually.
 */

#import <Foundation/Foundation.h>

@interface ESBasicAuthTokenProvider : NSObject

+ (NSString *)createBasicAuthTokenWithUsername:(NSString *)username password:(NSString *)password;

@end