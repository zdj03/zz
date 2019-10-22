import UIKit

/*----------------------不透明类型---------------------*/
/*
protocol Shape {
    func draw() -> String
}

struct Triangle: Shape {
    var size: Int
    func draw() -> String {
        var result = [String]()
        for length in 1...size{
            result.append(String(repeating: "*", count: length))
        }
        return result.joined(separator: "\n")
    }
}
let smallTriangle = Triangle(size: 3)
//print(smallTriangle.draw())


struct FlippedShape<T: Shape>: Shape {
    var shape: T
    func draw() -> String {
        let lines = shape.draw().split(separator: "\n")
        return lines.reversed().joined(separator: "\n")
    }
}
let flippedTriangle = FlippedShape(shape: smallTriangle)
//print(flippedTriangle.draw())

struct JoinedShape<T: Shape, U:Shape>: Shape {
    var top: T
    var bottom: U
    func draw() -> String {
        return top.draw() + "\n" + bottom.draw()
    }
}
let joinedTriangles = JoinedShape(top: smallTriangle, bottom: flippedTriangle)
//print(joinedTriangles.draw())


//返回一个不透明的类型
struct Square: Shape {
    var size: Int
    func draw() -> String {
        let line = String(repeating: "*", count: size)
        let result = Array<String>(repeating: line, count: size)
        return result.joined(separator: "\n")
    }
}


//`some`:返回一个遵循了Shape协议的类型，而不需要指定具体的类型，
func makeTrapezoid()-> some Shape {
    let top = Triangle(size: 2)
    let middle = Square(size: 2)
    let bottom = FlippedShape(shape: top)
    let trapezoid = JoinedShape(top: top,
                                bottom: JoinedShape(top: middle, bottom: bottom))
    return trapezoid
}
let trapezoid = makeTrapezoid()
print(trapezoid.draw())
*/


/*----------------------------ARC-------------------------*/
/**
 弱引用：若引用的对象可能为nil时，可设置为weak
 若引用的对象不会为nil时，设置为unowned
 */

//demo0:使用weak,apartment的属性tenant可能为nil
/*
class Person{
    let name: String
    init(name: String) {
        self.name = name
    }
     var apartment: Apartment?
    deinit{
    print("\(name) is being deinitilized")
    }
}
class Apartment {
    let unit: String
    init(unit: String) {
        self.unit = unit
    }
    weak var tenant: Person?
    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}*/
//var john: Person?
//var unit4A: Apartment?
//john = Person(name: "John Appleseed")
//unit4A = Apartment(unit: "4A")
//john!.apartment = unit4A
//unit4A!.tenant = john
//john = nil
//unit4A = nil

//demo0:使用unowned，card的属性customer不可能为nil
/*class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit {
        print("\(name) is being deinitialized")
    }
}

class CreditCard{
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer:Customer) {
        self.number = number
        self.customer = customer
    }
    deinit{
    print("Card #\(number) is being deinitialized")
    }
}*/
//var john: Customer?
//john = Customer(name: "John Appleseed")
//john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)
//john = nil

//demo2:country和city都不可能为nil:在这种场景中，两个属性都必须有值，并且初始化完成后永远不会为 nil 。在这种场景中，需要一个类使用无主属性，而另外一个类使用隐式展开的可选属性。
/* Country的属性capitalCity声明为隐士展开的可选属性，那么它有个默认值nil，在name完成设置值后，country的初始化过程就完成了，country的初始化器就能引用并传递隐式的self，这时city的初始化器就能将self作为参数传递，
 
 注意：city的属性country声明为unowned
 
 以上意义在于：通过一条语句创建country和city实例，而不产生循环引用，并且capitalcity的属性能被直接访问，而不需要通过感叹号展开它的可选值
*
*
 */
/*
class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}
class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}*/
//var country = Country(name: "Canada", capitalName: "Ottawa")
//print("\(country.name)'s capital city is called \(country.capitalCity.name)")


//demo3:闭包的循环强引用,定义捕获列表，打破循环引用,此处闭包和self总是同时释放，所以定义为unowned，如果不是self，而是其他变量如delegate，因为delegate可能为nil，所以可能定义为weak
/*class HTMLElement {
    let name: String
    let text: String?
    
    lazy var asHTML: ()->String = {
        
        [unowned self] in
        
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name)>"
        }
    }
    
    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }
    
    deinit {
        print("\(name) is being deinitialized")
    }
}
var heading: HTMLElement? = HTMLElement(name: "h1")
let defaultText = "some default text"
//heading.asHTML = {
//    return "<\(heading.name)>\(heading.text ?? defaultText)</\(heading.name)>"
//}
print(heading!.asHTML())
heading = nil
*/



/*---------------------------------内存安全性--------------------------*/

//报错：Simultaneous accesses to 0x10ea3b060, but modification requires exclusive access.
//stepSize同时在修改和访问同一块内存，产生了冲突
var stepSize = 1
func increment(_ number: inout Int) {
    number += stepSize
}
var copyOfStepSize = stepSize
increment(&copyOfStepSize)
stepSize = copyOfStepSize


/*--------------------------------高级运算符---------------------------*/

var potentialOverflow = Int16.max
potentialOverflow = potentialOverflow &+ 1

struct Vector2D {
    var x = 0.0, y = 0.0
}
extension Vector2D {
    static func +(left: Vector2D, right: Vector2D) -> Vector2D{
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }
}
let vector = Vector2D(x: 3.0, y: 1.0)
let anotherVector = Vector2D(x: 2.0, y: 4.0)
let combinedVector = vector + anotherVector
extension Vector2D{
    static prefix func -(vector: Vector2D) -> Vector2D {
        return Vector2D(x: -vector.x, y: -vector.y)
    }
}
let positive = Vector2D(x: 3.0, y: 4.0)
let negative = -positive

extension Vector2D {
    static func +=(left: inout Vector2D, right: Vector2D) {
        left = left + right
    }
}
var original = Vector2D(x: 1.0, y: 2.0)
let vectorToAdd = Vector2D(x: 3.0, y: 4.0)
original += vectorToAdd

extension Vector2D: Equatable {
    static func ==(left: Vector2D, right:Vector2D) -> Bool {
        return (left.x == right.x) && (left.y == right.y)
    }
}


//自定义运算符
prefix operator +++
extension Vector2D {
    static prefix  func +++ (vector: inout Vector2D) -> Vector2D {
        vector += vector
        return vector
    }
}
var toBeDoubled = Vector2D(x: 1.0, y: 4.0)
let afterDoubling = +++toBeDoubled

//自定义中缀运算符的优先级和结核性
precedencegroup precedence{ associativity: left
                            higherThan: AdditionPrecedence
                        }
infix operator +- : precedence
extension Vector2D {
    static func +-(left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y - right.y)
    }
}
