#import "ESABContact.h"

@implementation ESABContact

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"address": @"address", @"email": @"email", @"firstName": @"firstName", @"image": @"image", @"lastName": @"lastName", @"middleName": @"middleName", @"telephone": @"telephone", @"userUID": @"userUID" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"address", @"email", @"firstName", @"image", @"lastName", @"middleName", @"telephone", @"userUID"];
  return [optionalProperties containsObject:propertyName];
}

@end
