class aClass{
    var value = 1
}

var c1 = aClass()
var c2 = aClass()

var fSpec = { 
    [unowned c1, weak c2] in
    c1.value = 42
    if let c2o = c2 {
        c2o.value = 42
    }
}


fSpec()

