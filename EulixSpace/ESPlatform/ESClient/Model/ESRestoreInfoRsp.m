#import "ESRestoreInfoRsp.h"

@implementation ESRestoreInfoRsp

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"boxId": @"boxId", @"endTime": @"endTime", @"msg": @"msg", @"startTime": @"startTime", @"status": @"status", @"storageMoved": @"storageMoved", @"storageTotal": @"storageTotal", @"taskType": @"taskType", @"timeRemain": @"timeRemain", @"transId": @"transId" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"boxId", @"endTime", @"msg", @"startTime", @"status", @"storageMoved", @"storageTotal", @"taskType", @"timeRemain", @"transId"];
  return [optionalProperties containsObject:propertyName];
}

@end
