#import <Foundation/Foundation.h>

@class ESLogger;

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


static NSString * const kESAPIVersion = @"0.4.2";

@protocol ESConfiguration <NSObject>

/**
 * Api logger
 */
@property (readonly, nonatomic) ESLogger *logger;

/**
 * Base url
 */
@property (readonly, nonatomic) NSString *host;

/**
 * Api key values for Api Key type Authentication
 */
@property (readonly, nonatomic) NSDictionary *apiKey;

/**
 * Api key prefix values to be prepend to the respective api key
 */
@property (readonly, nonatomic) NSDictionary *apiKeyPrefix;

/**
 * Username for HTTP Basic Authentication
 */
@property (readonly, nonatomic) NSString *username;

/**
 * Password for HTTP Basic Authentication
 */
@property (readonly, nonatomic) NSString *password;

/**
 * Access token for OAuth
 */
@property (readonly, nonatomic) NSString *accessToken;

/**
 * Temp folder for file download
 */
@property (readonly, nonatomic) NSString *tempFolderPath;

/**
 * Debug switch, default false
 */
@property (readonly, nonatomic) BOOL debug;

/**
 * SSL/TLS verification
 * Set this to NO to skip verifying SSL certificate when calling API from https server
 */
@property (readonly, nonatomic) BOOL verifySSL;

/**
 * SSL/TLS verification
 * Set this to customize the certificate file to verify the peer
 */
@property (readonly, nonatomic) NSString *sslCaCert;

/**
 * Authentication Settings
 */
@property (readonly, nonatomic) NSDictionary *authSettings;

/**
* Default headers for all services
*/
@property (readonly, nonatomic, strong) NSDictionary *defaultHeaders;

@end
