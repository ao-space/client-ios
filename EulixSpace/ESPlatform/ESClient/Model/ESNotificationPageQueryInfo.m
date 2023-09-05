#import "ESNotificationPageQueryInfo.h"

@implementation ESNotificationPageQueryInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    // initialize property's default value, if any
    self.page = @1;
    self.pageSize = @10;
    
  }
  return self;
}


/**
 * Maps json key to property name.
 * This method is used by `JSONModel`.
 */
+ (JSONKeyMapper *)keyMapper {
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"optTypes": @"optTypes", @"page": @"page", @"pageSize": @"pageSize" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"optTypes", @"page", @"pageSize"];
  return [optionalProperties containsObject:propertyName];
}

@end
