//
//  YCProperty.m
//  YCEasyTool
//
//  Created by Ye Tao on 2017/2/8.
//
//

#import "YCProperty.h"
#import "YCMemeryCache.h"
#import <objc/runtime.h>

YCEncodingType YCEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) {
        return YCEncodingTypeUnknown;
    }
    size_t len = strlen(type);
    if (len == 0) {
        return YCEncodingTypeUnknown;
    }
    YCEncodingType qualifier = 0;

    len = strlen(type);
    if (len == 0) {
        return YCEncodingTypeUnknown | qualifier;
    }
    switch (type[1]) {
        case 'v':
            return YCEncodingTypeVoid | qualifier;
        case 'B':
            return YCEncodingTypeBool | qualifier;
        case 'c':
            return YCEncodingTypeInt8 | qualifier;
        case 'C':
            return YCEncodingTypeUInt8 | qualifier;
        case 's':
            return YCEncodingTypeInt16 | qualifier;
        case 'S':
            return YCEncodingTypeUInt16 | qualifier;
        case 'i':
            return YCEncodingTypeInt32 | qualifier;
        case 'I':
            return YCEncodingTypeUInt32 | qualifier;
        case 'l':
            return YCEncodingTypeInt32 | qualifier;
        case 'L':
            return YCEncodingTypeUInt32 | qualifier;
        case 'q':
            return YCEncodingTypeInt64 | qualifier;
        case 'Q':
            return YCEncodingTypeUInt64 | qualifier;
        case 'f':
            return YCEncodingTypeFloat | qualifier;
        case 'd':
            return YCEncodingTypeDouble | qualifier;
        case 'D':
            return YCEncodingTypeLongDouble | qualifier;
        case '#':
            return YCEncodingTypeClass | qualifier;
        case ':':
            return YCEncodingTypeSEL | qualifier;
        case '*':
            return YCEncodingTypeCString | qualifier;
        case '^':
            return YCEncodingTypePointer | qualifier;
        case '[':
            return YCEncodingTypeCArray | qualifier;
        case '(':
            return YCEncodingTypeUnion | qualifier;
        case '{':
            return YCEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 3 && *(type + 2) == '?') {
                return YCEncodingTypeBlock | qualifier;
            } else {
                return YCEncodingTypeObject | qualifier;
            }
        }
        default:
            return YCEncodingTypeUnknown | qualifier;
    }
}

#define YCPropertyIgnoreList @[ \
    @"hash",                    \
    @"superclass",              \
    @"description",             \
    @"debugDescription",        \
]

static inline NSArray *YCGetPropertyList(Class someClass, YCPropertyParsingType parsingType) {
    unsigned int outCount;
    NSMutableArray *list = [NSMutableArray array];
    objc_property_t *properties = class_copyPropertyList(someClass, &outCount);
    for (NSUInteger i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        if (name) {
            NSString *propertyName = [NSString stringWithUTF8String:name];
            if ([YCPropertyIgnoreList containsObject:propertyName]) {
                continue;
            }
        }
        YCProperty *item = [[YCProperty alloc] initWithProperty:property];
        //db only support class and number
        if (parsingType == YCPropertyParsingTypeDB) {
            if (item.isNumber || item.type == YCEncodingTypeString) {
                [list addObject:item];
            }
        } else {
            [list addObject:item];
        }
    }
    free(properties);
    //ignore Apple's class
    if ([someClass respondsToSelector:@selector(yc_includingSuper)]) {
        Class superclass = class_getSuperclass(someClass);
        BOOL includingSuper = [someClass yc_includingSuper];
        if (includingSuper &&
            strncmp(class_getName(superclass), "NS", 2) != 0 &&
            strncmp(class_getName(superclass), "UI", 2) != 0) {
            NSArray *superList = YCGetPropertyList(superclass, parsingType);
            [list addObjectsFromArray:superList];
        }
    }
    return list;
}

@interface YCProperty ()

@property (nonatomic, assign) objc_property_t property ;

@end

@implementation YCProperty

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) {
        return nil;
    }
    self = [super init];
    if (self) {
        _property = property;
        const char *name = property_getName(property);
        if (name) {
            self.name = [NSString stringWithUTF8String:name];
        }
        const char *attributes = property_getAttributes(property);
        char buffer[1 + strlen(attributes)];
        strcpy(buffer, attributes);
        char *state = buffer, *attribute;
        YCEncodingType type = YCEncodingTypeUnknown;
        while ((attribute = strsep(&state, ",")) != NULL) {
            if (attribute[0] == 'T') {
                if (strlen(attribute) <= 4) {
                    type = YCEncodingGetType(attribute);
                    break;
                }
                const char *objcType = (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
                if (strcmp(objcType, "NSString") == 0 || strcmp(objcType, "NSNumber") == 0) {
                    type = YCEncodingTypeString;
                } else {
                    type = YCEncodingTypeClass;
                }
                self.objcType = [NSString stringWithUTF8String:objcType];
                break;
            }
        }
        _type = type;
        _isNumber = (type >= YCEncodingTypeBool && type <= YCEncodingTypeLongDouble);
    }
    return self;
}

- (void)setName:(NSString *)name {
    _name = [name copy];
    [self generateAccess];
}

- (void)setObjcType:(NSString *)objcType {
    _objcType = [objcType copy];
}

- (void)generateAccess {
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@-%d", self.name, (int)self.type];
}

@end

static void *YCForeverStorageKey = &YCForeverStorageKey;

@interface NSObject ()

@property (nonatomic, strong) NSMutableDictionary *ycf_storage;

@end

@implementation NSObject (YCProperty)

- (void)setYcf_storage:(NSMutableDictionary *)ycf_storage {
    objc_setAssociatedObject(self, &YCForeverStorageKey, ycf_storage, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableDictionary *)ycf_storage {
    NSMutableDictionary *storage = objc_getAssociatedObject(self, &YCForeverStorageKey);
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        [self setYcf_storage:storage];
    }
    return storage;
}

- (id (^)(NSString *, id))yc_store {
    id (^block)(NSString *key, id value) = ^id(NSString *key, id value) {
        if (key && value) {
            self.ycf_storage[key] = value;
        }
        if (key && !value) {
            return self.ycf_storage[key];
        }
        if (!key && value) {
            return [self.ycf_storage allKeysForObject:value];
        }
        return self;
    };
    return block;
}

- (NSArray<YCProperty *> *)yc_propertyArray {
    return [[self class] yc_propertyArray];
}

+ (NSArray<YCProperty *> *)yc_propertyArray {
    NSArray<YCProperty *> *yc_propertyArray = [YCMemeryCache cacheForKey:NSStringFromClass(self)];
    if (!yc_propertyArray) {
        yc_propertyArray = YCGetPropertyList(self, YCPropertyParsingTypeDB);
        [YCMemeryCache cacheObject:yc_propertyArray forKey:NSStringFromClass(self)];
    }
    return yc_propertyArray;
}

+ (NSArray<YCProperty *> *)yc_propertyArrayWithType:(YCPropertyParsingType)type {
    NSArray<YCProperty *> *yc_propertyArray = [YCMemeryCache cacheForKey:NSStringFromClass(self)];
    if (!yc_propertyArray) {
        yc_propertyArray = YCGetPropertyList(self, type);
        [YCMemeryCache cacheObject:yc_propertyArray forKey:NSStringFromClass(self)];
    }
    return yc_propertyArray;
}

@end
