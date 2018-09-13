# AppDelegate瘦身

本文主要通过runtime实现将**UIApplicationDelegate**方法在**AppDelegate**类中提取出来，这样避免AppDelegate类变得冗余，可以将UIApplicationDelegate方法中需要处理的逻辑代码剥离出来，单独处理，实现代码低耦合。

- **创建UIApplication的category分类，获取UIApplication的delegate.**

```
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
//获取UIApplication的delegate
[UIApplication exchangeMethods:delegate];

[self nl_setDelegate:delegate];
}
```

- **为UIApplicationDelegate 的方法添加默认实现**

由于UIApplicationDelegate协议中的方法都是可选的，所以AppDelegate类中可能没有所需方法的实现，这时候我们要为方法添加默认实现。这里我们拿 -(void)applicationDidEnterBackground:(UIApplication *)application方法为例，代码如下

```
//这里delegateClass 默认是AppDelegate类，但是如果项目修改AppDelegate的类名，这里相应做改变。
Class delegateClass = object_getClass(delegate);

SEL delegateSelector = @selector(applicationDidEnterBackground:); 

SEL defaultSelector = @selector(default_applicationDidEnterBackground:);
IMP defaultImp = class_getMethodImplementation([self class], defaultSelector);

class_addMethod(delegateClass, delegateSelector, defaultImp, nil);

- (void)default_applicationDidEnterBackground:(UIApplication *)application
{


}
```

- **为UIApplicationDelegate 的方法添加自定义方法实现**

```
Class delegateClass = object_getClass(delegate); 

SEL customSelector = @selector(custom_applicationDidEnterBackground:);
IMP customImp = class_getMethodImplementation([self class], customSelector);

class_addMethod(delegateClass, customSelector, customImp, nil);

```

- **交换AppDelegate方法实现和自定义方法实现**

```
Method systemMethod = class_getInstanceMethod(delegateClass, delegateSelector);
Method newMethod = class_getInstanceMethod(delegateClass, customSelector);
method_exchangeImplementations(systemMethod, newMethod);

```

- **获取UIApplicationDelegate方法回调**

```
- (void)custom_applicationDidEnterBackground:(UIApplication *)application
{
[self custom_applicationDidEnterBackground:application];
//此处获取UIApplicationDelegate 方法 applicationDidEnterBackground:application 回调。

}
```
- **获取UIApplicationDelegate方法，并发送自定义通知，这样可以在项目中任何地方可以监测应用程序状态，并实现自定义逻辑代码**

完整代码请参考:





