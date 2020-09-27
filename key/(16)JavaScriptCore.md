> JavaScriptCore,原本是WebKit中用来解释执行JavaScipt代码的核心引擎。

####介绍

JavaScriptCore框架主要由JSVirtualMachine、JSContext、JSValue类组成。

JSVirtualMachine的作用，是为JavaScript代码的运行提供一个虚拟机环境。在同一时间内，JSVirtualMachine只能执行一个线程。如果想要多个线程执行任务，可以创建多个JSVirtualMachine。每个JSVirtualMachine都有自己的GC，以便进行内存管理，所以多个JSVirtualMachine之间的对象无法传递。

JSContext是JavaScript运行环境的上下文，负责原生和JavaScript的数据传递。

JSValue是JavaScript的值对象，用来记录JavaScript的原始值，并提供原始值对象转换的接口方法。

三者之间的关系如下：

![JSVirtualMachine、JSContext、JSvalue间的关系](/Users/zhoudengjie/文档/awesome/pics/JSCore0.png)

####JavaScript和原生应用进行交互

JavaScriptCore要想和原生应用进行交互，首先要有JSContext。JSContext初始化方法如下:

```objective-c
//使用系统创建的JSVirtualMachine
JSContext *ctx0 = [[JSContext alloc] init];
    
//使用自己创建的JSVirtualMachine
JSVirtualMachine *jsvm = [[JSVirtualMachine alloc] init];
JSContext *ctx1 = [[JSContext alloc] initWithVirtualMachine:jsvm];
```

##### 原生代码调用JavaScript变量

```objective-c
//解析执行JavaScript
JSValue *value0 = [ctx1 evaluateScript:@"var m = 1 + 1"];
//转换变量m为原生对象
NSNumber *number = [ctx1[@"m"] toNumber];
NSLog(@"var i is %@, number is %@", ctx1[@"m"], number);
```

输出：

```
2019-06-23 09:55:16.137059+0800 Awesome[11250:2096321] var i is 2, number is 2
```

上述代码中，JSContext会调用evaluateScript方法，返回JSValue对象。

JSValue类提供了将JavaScript对象值类型转换为原生类型的接口：

| OC(Swift) Types                                              | JavaScript Types | Notes                                                        |
| ------------------------------------------------------------ | ---------------- | ------------------------------------------------------------ |
| nil                                                          | undefined        |                                                              |
| NSNull                                                       | null             |                                                              |
| NSString(Swift String)                                       | String           |                                                              |
| NSNumber 、primitive numeric types                           | Number、Boolean  | Conversion is consistent with the following methods:   </br>     [`init(int32:in:)`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451434-init)/[`toInt32()`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451493-toint32) for signed integer types</br>       [`init(uInt32:in:)`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451402-init)/[`toUInt32()`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451739-touint32) for unsigned integer types</br>     [`init(bool:in:)`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451616-init)/[`toBool()`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451373-tobool) for Boolean types</br>          [`init(double:in:)`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451482-init)/[`toBool()`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451373-tobool) for all other numeric types |
| NSDictionary(Swift Dictionary)                               | Object           | Recurisive conversion                                        |
| NSArray(Swift Array)                                         | Array            | Recurisive conversion                                        |
| NSDate                                                       | Date             |                                                              |
| OC or Swift object (objc_object or AnyObject)</br>  OC or Swift class(Class or AnyClass) | Object           | Coverts with Init(object:in:)/to Object()                    |
| Structure types:  </br>NSRanges,  </br>CGRect,  </br>CGPoint,  </br>CGSize | Object           | Other structure types are not supported                      |
| OC block(Swift closure)                                      | Function         | Convert explic with </br> [`init(object:in:)`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451694-init)/[`toObject()`](https://developer.apple.com/documentation/javascriptcore/jsvalue/1451725-toobject).</br> JavaScript functions do not convert to native blocks/closures unless already backed by a native block/closure |

如果想在原生代码中使用JavaScript中的函数对象，可以通过callWithArguments方法传入参数，然后实现调用。如下：

```objective-c
//解释执行javaScript中的函数
    [ctx1 evaluateScript:@"function add(x, y) {return x + y;}"];
    //获取add函数
    JSValue *func = ctx1[@"add"];
    //传入参数执行add函数
    JSValue *res = [func callWithArguments:@[@(10),@(10)]];
    //将结果转换为原生对象
    NSLog(@"res : %@", [res toNumber]);	
```

输出：`2019-06-23 10:35:32.430620+0800 Awesome[11344:2132943] res : 20`

如果要在原生代码中调用JavaScript全局函数，需要使用JSValue的`invokeMethod:withArguments:`方法，weex框架就是使用这个方法，来获取JavaScript函数的：

```objective-c
- (JSValue *)callJSMethod:(NSString *)method args:(NSArray *)args {
    WXLogDebug(@"Calling JS... method:%@, args:%@",method, args);
    return [[_jsContext globalObject] invokeMethod:method withArguments:args];
}
```

可以看出，JSContext有个globalObject属性，globalObject是JSValue类型，里面记录了JSContext的全局对象，使用globalObject执行的JavaScript函数能够使用全局JavaScript对象。因此，通过globalObject执行invokeMethod:withArguments:方法就能够使用全局JavaScript对象了。如下，调用add方法：

```objective-c
JSValue *invokeMethodRes = [[ctx1 globalObject] invokeMethod:@"add" withArguments:@[@(100),@(100)]];
NSLog(@"invokeMethodRes:%@",[invokeMethodRes toNumber]);
```

输出：`2019-06-23 10:51:27.406345+0800 Awesome[11539:2150821] invokeMethodRes:200`

#### JavaScript如何使用原生代码

- 通过block

  ```objective-c
  ctx1[@"subtraction"] = ^(int x, int y) {
          return x - y;
      };
  JSValue *subValue = [ctx1 evaluateScript:@"subtraction(10, 5)"];
  NSLog(@"subValue:%@", subValue.toNumber);
  ```

  输出：

  **2019-07-01 22:17:06.466242+0800 Awesome[13318:2500613] subValue:5**

  可以看出：js调用原生代码的方式：

  - 首先在jsContext中使用block设置一个函数
  - 在同一个jsContext中用js代码调用设置的函数

- 通过JSExport协议实现在js中调用原生代码，

  在weex引擎里，类WXPolyfillSet遵循了JSExport协议，使得js也能够使用原生代码中的NSMutableSet类型。

  ```objective-c
  @protocol WXPolyfillSetJSExports <JSExport>
  
  + (instancetype)create;
  - (BOOL)has:(id)value;
  - (NSUInteger)size;
  - (void)add:(id)value;
  - (BOOL)delete:(id)value;
  - (void)clear;
  @end
  
  @interface WXPolyfillSet : NSObject<WXPolyfillSetJSExports>
  
  @end
  ```



JSVirtualMachine是一个抽象的JS虚拟机，是提供给开发者开发的，而核心的JavaScriptCore引擎则是一个真实的虚拟机，包含了解释器和运行时。

JavaScriptCore内部是由Parser、Interpreter、Compiler、GC等部分组成，其中Compiler负责把字节码翻译成机器码，并进行优化。

JavaScriptCore解释器进行JavaScript代码的流程：

- 由Parser进行词法分析、语法分析，生成字节码
- 由Interpreter进行解释执行，解释执行的过程是先由LLInt(Low Level Interpreter）来执行Parser生成的字节码，JavaScriptCore会对运行频次高的函数进行优化。优化器有Baseline JIT、DFG、FTL JIT.对于多优化层级切换，JavaScriptCore使用OSR（On Stack Replacement）来管理。

