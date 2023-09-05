#import "ESAppletInfoRes.h"

@implementation ESAppletInfoRes

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"appletId": @"appletId", @"appletVersion": @"appletVersion", @"iconUrl": @"iconUrl", @"isForceUpdate": @"isForceUpdate", @"md5": @"md5", @"name": @"name", @"nameEn": @"nameEn", @"state": @"state", @"updateAt": @"updateAt", @"updateDesc": @"updateDesc" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"appletId", @"appletVersion", @"iconUrl", @"isForceUpdate", @"md5", @"name", @"nameEn", @"state", @"updateAt", @"updateDesc"];
  return [optionalProperties containsObject:propertyName];
}

@end
