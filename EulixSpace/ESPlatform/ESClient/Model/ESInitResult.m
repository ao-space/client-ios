#import "ESInitResult.h"

@implementation ESInitResult

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
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxName": @"boxName", @"boxUuid": @"boxUuid", @"clientUuid": @"clientUuid", @"connected": @"connected", @"initialEstimateTimeSec": @"initialEstimateTimeSec", @"network": @"network", @"paired": @"paired", @"pairedBool": @"pairedBool", @"productId": @"productId",@"sspUrl":@"sspUrl" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"boxName", @"boxUuid", @"clientUuid", @"connected", @"initialEstimateTimeSec", @"network", @"paired", @"pairedBool", @"productId",@"sspUrl"];
  return [optionalProperties containsObject:propertyName];
}

@end
