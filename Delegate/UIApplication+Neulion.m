//
//  UIApplication+Neulion.m
//  Delegate
//
//  Created by Sharon Ouyang on 2018/8/24.
//  Copyright © 2018 NeuLion. All rights reserved.
//

#import "UIApplication+Neulion.h"
#import <objc/runtime.h>

@implementation UIApplication (Neulion)

+ (void)load
{
    SEL systemSelector = @selector(setDelegate:);
    SEL customSelector = @selector(nl_setDelegate:);
    Method systemMethod = class_getInstanceMethod([self class], systemSelector);
    Method customMethod = class_getInstanceMethod([self class], customSelector);
    method_exchangeImplementations(systemMethod, customMethod);
}
- (void)nl_setDelegate:(id<UIApplicationDelegate>)delegate
{
    [UIApplication exchangeMethods:delegate];
    
    [self nl_setDelegate:delegate];
}

+ (void)exchangeMethods:(id)delegate
{
    if (delegate == nil){
        return;
    }
    Class delegateClass = object_getClass(delegate);
    
    SEL delegateSelector = @selector(applicationDidEnterBackground:);
    
    SEL customSelector = @selector(custom_applicationDidEnterBackground:);
    IMP customImp = class_getMethodImplementation([self class], customSelector);
    
    SEL defaultSelector = @selector(default_applicationDidEnterBackground:);
    IMP defaultImp = class_getMethodImplementation([self class], defaultSelector);
    
    class_addMethod(delegateClass, delegateSelector, defaultImp, nil);
    class_addMethod(delegateClass, customSelector, customImp, nil);
    
    
    Method systemMethod = class_getInstanceMethod(delegateClass, delegateSelector);
    Method newMethod = class_getInstanceMethod(delegateClass, customSelector);
    method_exchangeImplementations(systemMethod, newMethod);
    
}

- (void)custom_applicationDidEnterBackground:(UIApplication *)application
{
    [self custom_applicationDidEnterBackground:application];
    
}
- (void)default_applicationDidEnterBackground:(UIApplication *)application
{
    
    
}

@end
