#import "ESBoxInfo.h"

@implementation ESBoxInfo

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxQrCode": @"boxQrCode", @"boxRegKey": @"boxRegKey", @"boxRegisterTime": @"boxRegisterTime", @"boxUuid": @"boxUuid", @"btid": @"btid", @"btidHash": @"btidHash", @"isBoxRegistered": @"isBoxRegistered", @"networkClient": @"networkClient" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"boxQrCode", @"boxRegKey", @"boxRegisterTime", @"boxUuid", @"btid", @"btidHash", @"isBoxRegistered", @"networkClient"];
  return [optionalProperties containsObject:propertyName];
}

@end
