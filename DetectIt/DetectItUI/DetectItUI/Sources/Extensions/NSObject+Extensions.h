//
//  NSObject+Extensions.h
//  DetectItUI
//
//  Created by Илья Харабет on 14.09.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Extension)

#pragma mark *** Values getting ***

- (nullable NSArray<NSObject *> *)arrayValueByGetterNamed:(NSString *)getterName NS_SWIFT_NAME(arrayValue(getter:));
- (nullable NSDictionary<NSString *, id> *)dictionaryValueByGetterNamed:(NSString *)getterName NS_SWIFT_NAME(dictionaryValue(getter:));
- (nullable NSString *)stringValueByGetterNamed:(NSString *)getterName NS_SWIFT_NAME(stringValue(getter:));
- (nullable UIColor *)colorValueByGetterNamed:(NSString *)getterName NS_SWIFT_NAME(colorValue(getter:));

#pragma mark *** Values setting ***

- (void)setIVarValue:(nullable id)value getterNamed:(NSString *)getterName NS_SWIFT_NAME(setIVarValue(value:getter:));
- (void)setValueUsingSetter:(nullable id)value getterNamed:(NSString *)getterName NS_SWIFT_NAME(setValueUsingSetter(value:getter:));
- (void)setObjectInDictionary:(id)object
                       forKey:(NSString *)key
                  getterNamed:(NSString *)getterName NS_SWIFT_NAME(setObjectInDictionary(object:key:getter:));

#pragma mark *** Methods calling ***

- (void)callMethodNamed:(NSString *)methodName NS_SWIFT_NAME(callMethod(named:));
- (void)callMethodNamed:(NSString *)methodName withObject:(nullable id)argument NS_SWIFT_NAME(callMethod(named:with:));

@end

NS_ASSUME_NONNULL_END
