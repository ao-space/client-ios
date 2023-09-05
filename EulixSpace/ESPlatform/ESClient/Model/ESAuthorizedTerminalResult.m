#import "ESAuthorizedTerminalResult.h"

@implementation ESAuthorizedTerminalResult

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"address": @"address", @"aoid": @"aoid", @"clientRegKey": @"clientRegKey", @"loginTime": @"loginTime", @"online": @"online", @"terminalModel": @"terminalModel", @"terminalType": @"terminalType", @"uuid": @"uuid" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"address", @"aoid", @"clientRegKey", @"loginTime", @"online", @"terminalModel", @"terminalType", @"uuid"];
  return [optionalProperties containsObject:propertyName];
}

@end
