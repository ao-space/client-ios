#import "ESAppletRegistryInfo.h"

@implementation ESAppletRegistryInfo

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"appletName": @"appletName", @"appletNameEn": @"appletNameEn", @"appletVersion": @"appletVersion", @"categories": @"categories", @"downUrl": @"downUrl", @"iconUrl": @"iconUrl", @"isForceUpdate": @"isForceUpdate", @"minCompatibleBoxVersion": @"minCompatibleBoxVersion", @"state": @"state", @"updateDesc": @"updateDesc" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"appletName", @"appletNameEn", @"categories", @"downUrl", @"iconUrl", @"isForceUpdate", @"minCompatibleBoxVersion", @"state", @"updateDesc"];
  return [optionalProperties containsObject:propertyName];
}

@end
