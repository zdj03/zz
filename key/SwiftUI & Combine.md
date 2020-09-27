> 函数式编程：纯函数指的是，返回值只由调用时的参数决定，而不依赖于任何系统状态，也不改变其作用域之外的变量状态的函数。我们强调纯函数，是因为其中不存在复杂的依赖关系，理解起来非常简单。而其优秀的特性，也让我们始终可以通过测试来确保逻辑正确。



###Demo：《能否关个灯》

#### @State

> Xcode报：Cannot assign to property:'self' is immutable错误

因为SwiftUI在执行DSL(Domain Specific Language)解析还原成视图节点树时，不允许有未知状态或者动态状态，SwiftUI需要明确的知道此时需要渲染的视图到底是什么。如果我们直接对数据源进行修改，想要通过这个数据源的变化去触发SwiftUI的状态刷新，需要借用@State状态去修饰lights变量，在SwiftUI内部lights会被自动转换为响应的setter和getter方法，对lights进行修改时会触发View的刷新，body会被再次调用，渲染引擎会找出布局上与lights相关的改变部分，并执行刷新。

@State仅只能在属性本身被设置时会触发UI刷新，这个特性让它非常适合使用在值类型中：因为对值类型的属性的变更也会触发整个值的重新设置。不过，在把这样的值在不同对象间传递时，这个值将会遵守值语义发生赋值。

```objective-c
struct ContentView: View {

    // 加上 `@State`
    @State var lights = [
        [Light(), Light(status: true), Light()],
        [Light(), Light(), Light()],
        [Light(), Light(), Light()],
    ]

    // ...
}
```



#### @Binding

和@State类似，@Binding也是对属性的修饰，但它是将值语义的属性转换为引用语义，对被声明为@Binding的属性进行赋值，改变的将不是属性本身，而是它的引用，这个改变将被向外传递



在Swift5中，在一个`@`符号修饰的属性前加上`$`所取得的值，我们称它为投影属性（projection property）。有些@属性，比如这里的@State和@Binding，提供这种投影属性的获取方式，它们的投影属性就是自身所对应的Binding类型。





#### propertyWrapper

`@`属性在swift中，正式的名称叫属性包装（propertyWrapper）。不论是`@State`、`@Binding`、`@ObjectBinding`、`@EnvironmentObject`都是被`@propertyWrapper`修饰的struct类型。如State定义的关键部分如下：

```swift
/// A linked View property that instantiates a persistent state
/// value of type `Value`, allowing the view to read and update its
/// value.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper public struct State<Value> : DynamicProperty {

    /// Initialize with the provided initial value.
    public init(wrappedValue value: Value)

    /// Initialize with the provided initial value.
    public init(initialValue value: Value)

    /// The current state value.
    public var wrappedValue: Value { get nonmutating set }

    /// Produces the binding referencing this state value
    public var projectedValue: Binding<Value> { get }
}
```

实际上使用：

```swift
struct ContentView : View {

    // 1
    @State 
    private var brain: CalculatorBrain = .left("0")

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(brain.output) // 2
              //...
            CalculatorButtonPad(brain: $brain) // 3
              //...
        }
    }
}
```

1、由于`init(initialValue:)`的存在，我们可以使用直接给

brain赋值的写法，将一个CalculatorBrain传递给brain。对属性包装中定义的init方法，我们可以添加更多的参数。不过initialValue这个参数名相对特殊：当它出现在init方法的第一个参数位置时，编译器将允许我们在声明的时候直接为`@State var brain`进行赋值

2、在访问brain时，这个变量暴露出来的就是CalculatorBrain的行为和属性。对brain进行赋值，看起来和普通的变量没有区别。但是实际上这些调用都触发的是属性包装中的wrappedValue。@State的声明，在底层将brain属性包装到了一个`State<CalculatorBrain>`中，并保留外界使用者通过CalculatorBrain接口对它进行操作的可能性。

3、使用`$`访问brain，访问的是projectedValue属性。在State中，这个属性返回一个Binding类型的值，通过遵守BindingConvertible，State暴露了修改其内部存储的方法，这就是为什么传递Binding可以让brain具有引用语义的原因



@State使用场景

1、这个状态是属于单个 `View` 及其子层级，还是需要在平行的部件之间传递和使用？`@State` 可以依靠 SwiftUI 框架完成 `View` 的自动订阅和刷新，但这是有条件的：对于 `@State` 修饰的属性的访问，只能发生在 `body`或者 `body` 所调用的方法中。你不能在外部改变 `@State` 的值，它的所有相关操作和状态改变都应该是和当前 `View` 挂钩的。如果你需要在多个 `View` 中共享数据，`@State` 可能不是很好的选择；如果还需要在 `View`外部操作数据，那么 `@State` 甚至就不是可选项了。

2、状态对应的数据结构是否足够简单？对于像是单个的 `Bool` 或者 `String`，`@State` 可以迅速对应。含有少数几个成员变量的值类型，也许使用 `@State` 也还不错。但是对于更复杂的情况，例如含有很多属性和方法的类型，可能其中只有很少几个属性需要触发 UI 更新，也可能各个属性之间彼此有关联，那么我们应该选择引用类型和更灵活的可自定义方式。



#### BindableObject和@ObjectBinding

`ObservableObject`协议要求实现类型是class，它只有一个需要实现的属性：objectWillChange。在数据将要发生改变时，这个属性用来向外进行广播，它的订阅者（一般是View相关的逻辑）在收到通知后，对View进行刷新。

创建`ObservableOBject`后，事件在View里使用时，我们需要将它声明为@ObservedObject。这也是一个属性包装，它负责将具体管理数据的ObservableObject和当前的View关联起来。



类定义：

```swift
import Combine
import SwiftUI

class CalculatorModel: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var brain: CalculatorBrain = .left("0"){
        willSet {
            objectWillChange.send()
        }
    }
}
```

使用：

```swift
 @ObservedObject var model = CalculatorModel()
    
    var body: some View {
        
        VStack(spacing: 12) {
            Spacer()
            Text(model.brain.output)
                    .font(Font.system(size: 76))
                    .minimumScaleFactor(0.5)
                    .padding(.trailing,24)
                    .lineLimit(1)
                    .frame(
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .bottom)
            CalculatorButtonPad(brain: $model.brain)
                .padding(.bottom)
        }
    }
```



####使用@Published和自动生成

使用@Published可以自动完成上面的willSet的事情。

```swift
@Published var brain: CalculatorBrain = .left("0")
```

在ObservableObject中，如果没有定义objectWillChange,编译器会自动生成一个，并在被标记为@published的属性发生变更时，自动调用objectWillChange.send()。这样就省去了我们一个个添加willSet的麻烦。





#### ObservableObject

`Thread 1:Fatal error:Accessing State<Array<Array<Light>>> outside View.body`

我们违反了SwiftUI单一数据源的规范，导致SwiftUI在执行DSL解析时，跑的数据源是非自己所有的，因此我们要把lights这个数据源转移给ContentView。在解决这个问题前，我么还需要明确一点，GameManager是用来解决ContentView中逻辑太多导致代码臃肿的中间层，换句话说，我们要把ContentView中执行的操作都要通过这个中间层去解决，因此，我们需要用上Combine中的ObservableObject协议帮助完成单一数据源的规范，修改后的GameManager代码如下：

```swift
class Manager: ObservableObject {
    @Published var lights = [
        [Light(), Light(status: true), Light()],
        [Light(), Light(), Light()],
        [Light(), Light(), Light()],
    ]

    // ...
}
```

修改后的ContentView代码如下：

```swift
struct ContentView: View {    
    @ObservedObject var gameManager = Manager()

    // ...
}
```





#### @EnvironmentObject

SwiftUI中，View提供了environmentObject(_:)方法，来把ObservableObject的值与当前View层级及其子层级相绑定。在这个View的子层级中可使用@EnvirionmentObject来直接获取这个绑定的环境值。



可能一开始你会认为 `@EnvironmentObject` 和“臭名昭著”的单例很像：只要我们在 `View` 的层级上，不论何处都可以访问到这个环境对象。看似这会带来状态管理上的困难和混乱，但是 Swift 提供了清晰的状态变更和界面刷新的循环，如果我们能选择正确的设计和架构模式，完全可以避免这种风险。使用 `@EnvironmentObject` 的便捷性和避免大量不必要的属性传递，会为之后代码变更带来更多的好处。

参考：

1、[SwiftUI 的 DSL 语法分析](https://blog.csdn.net/olsQ93038o99S/article/details/92801988)

