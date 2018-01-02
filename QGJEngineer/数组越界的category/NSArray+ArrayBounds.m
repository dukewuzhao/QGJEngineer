//
//  NSArray+ArrayBounds.m
//  ArrayBoundsDemo
//
//  Created by NickyTsui on 2017/3/17.
//  Copyright © 2017年 nickytsui. All rights reserved.
//

#import "NSArray+ArrayBounds.h"
#import <objc/runtime.h>
@implementation NSArray (ArrayBounds)
+ (void)load{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  //方法交换只要一次就好
        Method oldObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
        Method newObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(__nickyTsui__objectAtIndex:));
        method_exchangeImplementations(oldObjectAtIndex, newObjectAtIndex);
    });
}
- (id)__nickyTsui__objectAtIndex:(NSUInteger)index{
    if (index > self.count - 1 || !self.count){
        @try {
            return [self __nickyTsui__objectAtIndex:index];
        } @catch (NSException *exception) {
            //__throwOutException  抛出异常
            return nil;
        } @finally {
            
        }
    }
    else{
        return [self __nickyTsui__objectAtIndex:index];
    }
}
@end



//mutableArray的对象也需要做方法交换
@interface NSMutableArray (ArrayBounds)
@end
@implementation NSMutableArray (ArrayBounds)

+ (void)load{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  //方法交换只要一次就好
        Method oldObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
        Method newObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(__nickyTsui__objectAtIndex:));
        method_exchangeImplementations(oldObjectAtIndex, newObjectAtIndex);
    });
}
- (id)__nickyTsui__objectAtIndex:(NSUInteger)index{
    if (index > self.count - 1 || !self.count){
        @try {
            return [self __nickyTsui__objectAtIndex:index];
        } @catch (NSException *exception) {
            //__throwOutException  抛出异常
            return nil;
        } @finally {
            
        }
    }
    else{
        return [self __nickyTsui__objectAtIndex:index];
    }
}

@end
