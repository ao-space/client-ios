#import "ESQuestionnaireRes.h"

@implementation ESQuestionnaireRes

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
  return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"content": @"content", @"endAt": @"endAt", @"feedbackStatistic": @"feedbackStatistic", @"payloadSurveyId": @"payloadSurveyId", @"questionnaireId": @"questionnaireId", @"startAt": @"startAt", @"state": @"state", @"title": @"title" }];
}

/**
 * Indicates whether the property with the given name is optional.
 * If `propertyName` is optional, then return `YES`, otherwise return `NO`.
 * This method is used by `JSONModel`.
 */
+ (BOOL)propertyIsOptional:(NSString *)propertyName {

  NSArray *optionalProperties = @[@"content", @"endAt", @"feedbackStatistic", @"payloadSurveyId", @"questionnaireId", @"startAt", @"state", @"title"];
  return [optionalProperties containsObject:propertyName];
}

@end
