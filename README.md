# Async
将 dispatch_async 的回调转成串行。

在 iOS/Mac 编程中，经常使用 Grand Central Dispatch，它的语法使用回调。如：

```Swift
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
    print("This is run on the background queue")
  
  let result = "hello, World"
    dispatch_async(dispatch_get_main_queue(), {
        print("This is run on the main queue, after the previous block")
    print(result)
    })
})
```
这样就会产生一系列嵌套，当嵌套太多的时候代码就会混乱。Async 将这些回调嵌套，转换成串行。上面代码使用 Async 可以改写成：

``` Swift
Async.background {
    print("This is run on the background queue")
    return "hello, World"
}.main { (result : String) in
    print("This is run on the main queue, after the previous block")
    print(result)
}
```
再举一个例子：

``` Swift
Async.background {
    print("background 1")
    return (10, 10)
    
}.main { (a : Int, b : Int) in
    print("main 1")
    let result = a + b
    return result
    
}.delay(1.0, dispatch_get_global_queue(0, 0)) { (result: Int) in
    print("background 2")
    return "finish: \(result)"
    
}.main { (str: String) in
    print("main 2")
    print(str)
}
```

上述代码，表示现在后台执行，返回（10， 10), 之后回到主线程，在延迟 1 秒在后台执行，再回到主线程。上面例子可以看到，前一个 block 的返回值就是后面的 block 的参数。

### 安装
只有一个小文件，Async.swift，直接将其包含到工程中。










