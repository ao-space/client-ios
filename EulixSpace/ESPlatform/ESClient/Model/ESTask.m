#import "ESTask.h"

@implementation ESTask

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"cFile": @"cFile", @"containerImg": @"containerImg", @"doneDownTime": @"doneDownTime", @"doneInstallTime": @"doneInstallTime", @"downStatus": @"downStatus", @"installStatus": @"installStatus", @"rpmPkg": @"rpmPkg", @"startDownTime": @"startDownTime", @"startInstallTime": @"startInstallTime", @"status": @"status", @"versionId": @"versionId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"cFile", @"containerImg", @"doneDownTime", @"doneInstallTime", @"downStatus", @"installStatus", @"rpmPkg", @"startDownTime", @"startInstallTime", @"status", @"versionId"];
  return [optionalProperties containsObject:propertyName];
}

@end
