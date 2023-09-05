#import "ESPushMessage.h"

@implementation ESPushMessage

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxRegKey": @"boxRegKey", @"boxUUID": @"boxUUID", @"channelProperties": @"channelProperties", @"clientUUIDs": @"clientUUIDs", @"_description": @"description", @"payload": @"payload", @"policy": @"policy", @"type": @"type", @"userIds": @"userIds" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"clientUUIDs", @"_description", @"policy", @"userIds"];
  return [optionalProperties containsObject:propertyName];
}

@end
