#import "ESPackageRes.h"

@implementation ESPackageRes

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
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"downloadUrl": @"downloadUrl", @"isForceUpdate": @"isForceUpdate", @"md5": @"md5", @"minAndroidVersion": @"minAndroidVersion", @"minBoxVersion": @"minBoxVersion", @"minIOSVersion": @"minIOSVersion", @"pkgName": @"pkgName", @"pkgSize": @"pkgSize", @"pkgType": @"pkgType", @"pkgVersion": @"pkgVersion", @"updateDesc": @"updateDesc", @"restart" : @"restart"}];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"downloadUrl", @"isForceUpdate", @"md5", @"minAndroidVersion", @"minBoxVersion", @"minIOSVersion", @"pkgName", @"pkgSize", @"pkgType", @"pkgVersion", @"updateDesc", @"restart"];
  return [optionalProperties containsObject:propertyName];
}

@end
