#import "ESRestoreStartReq.h"

@implementation ESRestoreStartReq

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
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxId": @"boxId", @"restoreFolder": @"restoreFolder", @"restoreUser": @"restoreUser", @"secPass": @"secPass", @"strategy": @"strategy",@"restoreDataType": @"restoreDataType"}];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"boxId", @"restoreFolder", @"restoreUser", @"secPass", @"strategy",@"restoreDataType"];
  return [optionalProperties containsObject:propertyName];
}

@end
