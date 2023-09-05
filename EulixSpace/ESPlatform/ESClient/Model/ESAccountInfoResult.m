#import "ESAccountInfoResult.h"

@implementation ESAccountInfoResult

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
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"aoId": @"aoId", @"clientUUID": @"clientUUID", @"createAt": @"createAt", @"imageMd5": @"imageMd5", @"personalName": @"personalName", @"personalSign": @"personalSign", @"phoneModel": @"phoneModel", @"role": @"role", @"userDomain": @"userDomain",@"isSelect" :@"isSelect",@"headImagePath":@"headImagePath", @"aoSpaceId":@"aoSpaceId", @"did":@"did", @"userStorage":@"userStorage", @"totalStorage": @"totalStorage"}];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"aoId", @"clientUUID", @"createAt", @"imageMd5", @"personalName", @"personalSign", @"phoneModel", @"role", @"userDomain",@"isSelect",@"headImagePath", @"aoSpaceId", @"did", @"userStorage", @"totalStorage"];
  return [optionalProperties containsObject:propertyName];
}

@end
