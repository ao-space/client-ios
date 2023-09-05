#import "ESUserEntity.h"

@implementation ESUserEntity

- (instancetype)init {
  self = [super init];
  if (self) {
    // initialize property's default value, if any
    
  }
  return self;
}


/**
 * Maps json key to property name.
 * This method is used by `JSONModel`.
 */
+ (JSONKeyMapper *)keyMapper {
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"aoId": @"aoId", @"authKey": @"authKey", @"clientRegKey": @"clientRegKey", @"clientUUID": @"clientUUID", @"createAt": @"createAt", @"_id": @"id", @"image": @"image", @"imageMd5": @"imageMd5", @"personalName": @"personalName", @"personalSign": @"personalSign", @"phoneModel": @"phoneModel", @"role": @"role", @"userDomain": @"userDomain", @"userRegKey": @"userRegKey" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"authKey", @"clientRegKey", @"clientUUID", @"_id", @"image", @"imageMd5", @"personalSign", @"phoneModel", ];
  return [optionalProperties containsObject:propertyName];
}

@end
