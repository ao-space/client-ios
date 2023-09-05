//
//  YCProperty.h
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/8.
//
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

/**
 @see https://github.com/ibireme/YYKit
 */

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, YCEncodingType) {
    YCEncodingTypeMask = 0xFF,     ///< mask of type value
    YCEncodingTypeUnknown = 0,     ///< unknown
    YCEncodingTypeVoid = 1,        ///< void
    YCEncodingTypeBool = 2,        ///< bool
    YCEncodingTypeInt8 = 3,        ///< char / BOOL
    YCEncodingTypeUInt8 = 4,       ///< unsigned char
    YCEncodingTypeInt16 = 5,       ///< short
    YCEncodingTypeUInt16 = 6,      ///< unsigned short
    YCEncodingTypeInt32 = 7,       ///< int
    YCEncodingTypeUInt32 = 8,      ///< unsigned int
    YCEncodingTypeInt64 = 9,       ///< long long
    YCEncodingTypeUInt64 = 10,     ///< unsigned long long
    YCEncodingTypeFloat = 11,      ///< float
    YCEncodingTypeDouble = 12,     ///< double
    YCEncodingTypeLongDouble = 13, ///< long double
    YCEncodingTypeObject = 14,     ///< id
    YCEncodingTypeClass = 15,      ///< Class
    YCEncodingTypeSEL = 16,        ///< SEL
    YCEncodingTypeBlock = 17,      ///< block
    YCEncodingTypePointer = 18,    ///< void*
    YCEncodingTypeStruct = 19,     ///< struct
    YCEncodingTypeUnion = 20,      ///< union
    YCEncodingTypeCString = 21,    ///< char*
    YCEncodingTypeCArray = 22,     ///< char[10] (for example)
    YCEncodingTypeString = 23,     ///< NSString
};

typedef NS_ENUM(NSUInteger, YCPropertyParsingType) {
    YCPropertyParsingTypeAll,
    YCPropertyParsingTypeDB,
};

@class YCProperty;

extern YCEncodingType YCEncodingGetType(const char *typeEncoding);

extern NSNumber *YCModelCreateNumberFromProperty(__unsafe_unretained id model,
                                                 __unsafe_unretained YCProperty *property);

extern void YCModelSetNumberToProperty(__unsafe_unretained id model,
                                       __unsafe_unretained NSNumber *num,
                                       __unsafe_unretained YCProperty *property);

@protocol YCPropertyProtocol <NSObject>

+ (BOOL)yc_includingSuper;

@end

@interface YCProperty : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, assign) BOOL isNumber;

@property (nonatomic, assign, readonly) SEL getter; ///< getter (nonnull)

@property (nonatomic, assign, readonly) SEL setter; ///< setter (nonnull)

@property (nonatomic, assign, readonly) YCEncodingType type; ///< Ivar's type

@property (nonatomic, copy, readonly) NSString *objcType; ///< Ivar's type's name, like UILabel

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface NSObject (YCProperty)

/**
 If `value` is nil, return value of key, otherwize will save value of key
 If `key` is nil, return all keys of `value`
 */
- (id (^)(NSString *key, id value))yc_store;

- (NSArray<YCProperty *> *)yc_propertyArray;

+ (NSArray<YCProperty *> *)yc_propertyArray;

+ (NSArray<YCProperty *> *)yc_propertyArrayWithType:(YCPropertyParsingType)type;

@end
