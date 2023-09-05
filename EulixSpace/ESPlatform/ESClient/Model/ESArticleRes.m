#import "ESArticleRes.h"

@implementation ESArticleRes

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"cataId": @"cataId", @"content": @"content", @"createAt": @"createAt", @"_id": @"id", @"publishdAt": @"publishdAt", @"state": @"state", @"title": @"title", @"updateAt": @"updateAt" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"cataId", @"content", @"createAt", @"_id", @"publishdAt", @"state", @"title", @"updateAt"];
  return [optionalProperties containsObject:propertyName];
}

@end
