//
//  NSObject+Extensions.m
//  DetectItUI
//
//  Created by Илья Харабет on 14.09.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

#import "NSObject+Extensions.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (Extension)

#pragma mark - Public Methods

#pragma mark *** Values getting ***

- (nullable NSArray<NSObject *> *)arrayValueByGetterNamed:(NSString *)getterName {
    return [self valueOfType:[NSArray class] getterNamed:getterName];
}

- (nullable NSDictionary<NSString *, id> *)dictionaryValueByGetterNamed:(NSString *)getterName {
    return [self valueOfType:[NSDictionary class] getterNamed:getterName];
}

- (nullable NSString *)stringValueByGetterNamed:(NSString *)getterName {
    return [self valueOfType:[NSString class] getterNamed:getterName];
}

- (nullable UIColor *)colorValueByGetterNamed:(NSString *)getterName {
    return [self valueOfType:[UIColor class] getterNamed:getterName];
}

#pragma mark *** Values setting ***

- (void)setIVarValue:(nullable id)value getterNamed:(NSString *)getterName {
    @try {
        SEL getterSelector = NSSelectorFromString(getterName);
        SEL setterSelector = NSSelectorFromString([self setterMethodName:getterName]);
        NSString *ivarName = [NSString stringWithFormat:@"_%@", getterName];
        if ([self respondsToSelector:getterSelector] && [self respondsToSelector:setterSelector]) {
            [self setValue:value forKey:ivarName];
        }
    } @catch (NSException *exception) {

    }
}

- (void)setValueUsingSetter:(nullable id)value getterNamed:(NSString *)getterName {
    [self callMethodNamed:[self setterMethodName:getterName] withObject:value];
}

- (void)setObjectInDictionary:(id)object forKey:(NSString *)key getterNamed:(NSString *)getterName {
    NSMutableDictionary *dictionary = [[self dictionaryValueByGetterNamed:getterName] mutableCopy];
    if (!dictionary) {
        return;
    }

    dictionary[key] = object;

    [self callMethodNamed:[self setterMethodName:getterName] withObject:[dictionary copy]];
}

#pragma mark *** Methods calling ***

- (void)callMethodNamed:(NSString *)methodName {
    [self callMethodNamed:methodName withObject:nil];
}

- (void)callMethodNamed:(NSString *)methodName withObject:(nullable id)argument {
    @try {
        SEL selector = NSSelectorFromString(methodName);
        if ([self respondsToSelector:selector]) {
            _Pragma("clang diagnostic push")
            _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
            if (argument) {
                [self performSelector:selector withObject:argument];
            } else {
                [self performSelector:selector];
            }
            _Pragma("clang diagnostic pop")
        }
    } @catch (NSException *exception) {

    }
}


#pragma mark - Private Methods

- (nullable id)valueOfType:(Class)type getterNamed:(NSString *)getterName {
    id typedValue;
    @try {
        SEL selector = NSSelectorFromString(getterName);
        if ([self respondsToSelector:selector]) {
            _Pragma("clang diagnostic push")
            _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
            id value = [self performSelector:selector];
            if ([value isKindOfClass:type]) {
                typedValue = value;
            }_Pragma("clang diagnostic pop")
        }
    } @catch (NSException *exception) {

    } @finally {
        return typedValue;
    }
}

- (NSString *)setterMethodName:(NSString *)getterMethodName {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    NSString *firstChar = [getterMethodName substringToIndex:1];
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    NSString *pascalCasedResult = [folded.uppercaseString stringByAppendingString:[getterMethodName substringFromIndex:1]];

    return [NSString stringWithFormat:@"set%@:", pascalCasedResult];
}

@end

NS_ASSUME_NONNULL_END
