#import "ESFeedbackPayloadReq.h"

@implementation ESFeedbackPayloadReq

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"answer": @"answer", @"answerId": @"answer_id", @"endedAt": @"ended_at", @"openid": @"openid", @"startedAt": @"started_at", @"surveyId": @"survey_id" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"answer", @"answerId", @"endedAt", @"openid", @"startedAt", @"surveyId"];
  return [optionalProperties containsObject:propertyName];
}

@end
