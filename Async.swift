/*
The MIT License (MIT)

Copyright (c) 2016 HJC hjcapple@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

public final class AsyncHolder<U>
{
    private var _leftBlock: (U->Void) -> Void
    private var _isFinish = true
    
    private init(_ block: (U->Void) -> Void)
    {
        _leftBlock = block
    }
    
    deinit
    {
        if _isFinish
        {
            _leftBlock() { _ in
            }
        }
    }
    
    public func main<R>(rightBlock: U->R) -> AsyncHolder<R>
    {
        return async(dispatch_get_main_queue(), rightBlock)
    }
    
    public func background<R>(rightBlock: U->R) -> AsyncHolder<R>
    {
        return async(dispatch_get_global_queue(0, 0), rightBlock)
    }
    
    public func async<R>(queue : dispatch_queue_t, _ rightBlock: U->R) -> AsyncHolder<R>
    {
        _isFinish = false
        let leftBlock = _leftBlock
        return AsyncHolder<R> { complete in
            leftBlock { u in
                dispatch_async(queue) {
                    complete(rightBlock(u))
                }
            }
        }
    }
    
    public func main_delay<R>(time: Double, _ rightBlock: U->R) -> AsyncHolder<R>
    {
        return delay(time, dispatch_get_main_queue(), rightBlock)
    }
    
    public func delay<R>(time: Double, _ queue: dispatch_queue_t, _ rightBlock: U->R) -> AsyncHolder<R>
    {
        _isFinish = false
        let leftBlock = _leftBlock
        return AsyncHolder<R> { complete in
            leftBlock { u in
                let t = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
                dispatch_after(t, queue) {
                    complete(rightBlock(u))
                }
            }
        }
    }
}

public struct Async
{
    private static func empty() -> AsyncHolder<Void>
    {
        return AsyncHolder<Void> { complete in
            complete()
        }
    }
    
    public static func main<R>(rightBlock: Void->R) -> AsyncHolder<R>
    {
        return empty().main(rightBlock)
    }
    
    public static func background<R>(rightBlock: Void->R) -> AsyncHolder<R>
    {
        return empty().background(rightBlock)
    }
    
    public static func async<R>(queue : dispatch_queue_t, _ rightBlock: Void->R) -> AsyncHolder<R>
    {
        return empty().async(queue, rightBlock)
    }
    
    public static func main_delay<R>(time: Double, _ rightBlock: Void->R) -> AsyncHolder<R>
    {
        return empty().main_delay(time, rightBlock)
    }
    
    public static func delay<R>(time: Double, _ queue: dispatch_queue_t, _ rightBlock: Void->R) -> AsyncHolder<R>
    {
        return empty().delay(time, queue, rightBlock)
    }
}


