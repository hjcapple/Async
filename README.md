## Async

在 iOS/Mac 编程中，经常使用 Grand Central Dispatch，它的语法使用回调。如：

```Swift
DispatchQueue.global().async {
    print("This is run on the background queue")
    let result = "hello, World"
    DispatchQueue.main.async {
        print("This is run on the main queue, after the previous block")
        print(result)
    }
}
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
    
}.delay(1.0, DispatchQueue.global()) { (result: Int) in
    print("background 2")
    return "finish: \(result)"
    
}.main { (str: String) in
    print("main 2")
    print(str)
}
```

上述代码，表示现在后台执行，返回（10， 10), 之后回到主线程，在延迟 1 秒在后台执行，再回到主线程。上面例子可以看到，前一个 block 的返回值就是后面的 block 的参数。

## 环境要求
* Swift 4.2+
* Xcode 9.0+
* iOS 8.0+ / macOS 10.10

## 安装

### Carthage

在您的 `Cartfile` 添加上这一行

```ogdl
github "hjcapple/Async" "HEAD"
```

运行命令 `carthage update` 生成 `Async.framework`，将其添加到工程中。

### 手动安装

下载代码，将 `Async.xcodeproj` 添加到工程当中。或者直接将 `Async/Async.swift` 这个文件添加到工程当中。

