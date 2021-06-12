# AsynchronousConcurrency

Swift5.5新出的异步并发是一个很好的功能，但是只能在该版本使用，这个只能在三四年之后说再见了。
为了尝试提前用上异步并发，也参考了`AwaitKit`这个库，觉得可能不支持异步并发，还有线程死锁的问题。就索性自己
写一个简单的库，这样自己用起来自己改动十分的容易

目前只是做了一下简单的测试但是并不保证功能按照理想中进行，毕竟还没到发布0.1.0版本。

## 我们设置代码为线程同步

```swift
FutureAsync<Int> {
    let future1 = Future<Int> { handle in
        print("future1 \(Thread.current)")
        let start = Date().timeIntervalSince1970
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("future1 \(Date().timeIntervalSince1970 - start)")
            handle(1)
        }
    }
    let future2 = Future<Int> { handle in
        print("future2 \(Thread.current)")
        let start = Date().timeIntervalSince1970
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            print("future2 \(Date().timeIntervalSince1970 - start)")
            handle(2)
        }
    }
    if let value1 = try? future1.await(), let value2 = try? future2.await()  {
        print("future1 value \(value1)")
        print("future2 value \(value2)")
    }
    return FutureAsyncValue.void
}.await()
```
打印结果如下

```shell
future1 <NSThread: 0x600001405540>{number = 6, name = (null)}
future1 3.298741102218628
future2 <NSThread: 0x600001444940>{number = 7, name = (null)}
future2 5.466420888900757
total 8.765803098678589
future1 value 1
future2 value 2
```
我们可以看出来创建两个线程，线程是按照顺序执行的，任务时间等于两个异步任务之和

## 我们创建一个异步并发执行

```swift
FutureAsync<Int> {
    let future1 = Future<Int> { handle in
        print("future1 \(Thread.current)")
        let start = Date().timeIntervalSince1970
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("future1 \(Date().timeIntervalSince1970 - start)")
            handle(1)
        }
    }
    let future2 = Future<Int> { handle in
        print("future2 \(Thread.current)")
        let start = Date().timeIntervalSince1970
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            print("future2 \(Date().timeIntervalSince1970 - start)")
            handle(2)
        }
    }
    let start = Date().timeIntervalSince1970
    FutureList([future1,future2]).await()
    if let value1 = try? future1.get(), let value2 = try? future2.get()  {
        print("total \(Date().timeIntervalSince1970 - start)")
        print("future1 value \(value1)")
        print("future2 value \(value2)")
    }
    return FutureAsyncValue.void
}.await()
```
打印结果如下
```shell
future2 <NSThread: 0x6000035d0400>{number = 7, name = (null)}
future1 <NSThread: 0x6000035a7600>{number = 3, name = (null)}
future1 3.0001778602600098
future2 5.482822895050049
total 5.48375391960144
future1 value 1
future2 value 2

```
我们看到存在两个线程，同时执行的，总时间为最大执行时间。

## 怎么将网络请求转换为异步任务呢？
```swift
let future = Future<Data> { handle in
    AF.request("https://httpbin.org/get").response { response in
        handle(response.data)
    }
}
```



## 比如Swift异步的经典例子

```swift
func processImageData1(completionBlock: (_ result: Image) -> Void) {
loadWebResource("dataprofile.txt") { dataResource in
    loadWebResource("imagedata.dat") { imageResource in
        decodeImage(dataResource, imageResource) { imageTmp in
            dewarpAndCleanupImage(imageTmp) { imageResult in
                completionBlock(imageResult)
                }
            }
        }
    }
}

processImageData1 { image in
    display(image)
}
```
现在用这个库怎么写

```swift
FutureAsync<UIImage> {
    let dataResource = try! loadWebResource("dataprofile.txt")
    let imageResource = try! loadWebResource("imagedata.dat")
    /// 并发
    FutureList([dataResource,imageResource]).await()
    let imageTmp = decodeImage(try! dataResource.get(), try! imageResource.get())
    let imageResult = dewarpAndCleanupImage(imageTmp)
    return .value(imageResult)
    
}.then { image in
    display(image)
}
```

现在就是这么简单
