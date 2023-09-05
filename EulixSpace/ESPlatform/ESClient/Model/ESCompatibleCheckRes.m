#import "ESCompatibleCheckRes.h"

@implementation ESCompatibleCheckRes

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"isAppForceUpdate": @"isAppForceUpdate", @"isBoxForceUpdate": @"isBoxForceUpdate", @"lastestAppPkg": @"lastestAppPkg", @"lastestBoxPkg": @"lastestBoxPkg" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"isAppForceUpdate", @"isBoxForceUpdate", @"lastestAppPkg", @"lastestBoxPkg"];
  return [optionalProperties containsObject:propertyName];
}

@end
