/*
 The MIT License (MIT)

 Copyright (c) 2017 HJC hjcapple@gmail.com

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

public final class AsyncHolder<U> {
    private var _leftBlock: (@escaping ((U) -> Void)) -> Void
    private var _isFinish = true

    fileprivate init(_ block: @escaping (@escaping ((U) -> Void)) -> Void) {
        _leftBlock = block
    }

    deinit {
        if _isFinish {
            _leftBlock() { _ in
            }
        }
    }

    @discardableResult
    public func main<R>(_ rightBlock: @escaping (U) -> R) -> AsyncHolder<R> {
        return async(DispatchQueue.main, rightBlock)
    }

    @discardableResult
    public func background<R>(_ rightBlock: @escaping (U) -> R) -> AsyncHolder<R> {
        return async(DispatchQueue.global(), rightBlock)
    }

    @discardableResult
    public func async<R>(_ queue: DispatchQueue, _ rightBlock: @escaping (U) -> R) -> AsyncHolder<R> {
        _isFinish = false
        let leftBlock = _leftBlock
        return AsyncHolder<R> { complete in
            leftBlock { u in
                queue.async {
                    let r = rightBlock(u)
                    complete(r)
                }
            }
        }
    }

    @discardableResult
    public func main_delay<R>(_ time: Double, _ rightBlock: @escaping (U) -> R) -> AsyncHolder<R> {
        return delay(time, DispatchQueue.main, rightBlock)
    }

    @discardableResult
    public func delay<R>(_ time: Double, _ queue: DispatchQueue, _ rightBlock: @escaping (U) -> R) -> AsyncHolder<R> {
        _isFinish = false
        let leftBlock = _leftBlock
        return AsyncHolder<R> { complete in
            leftBlock { u in
                queue.asyncAfter(deadline: .now() + time) {
                    complete(rightBlock(u))
                }
            }
        }
    }
}

public struct Async {

    private static func empty() -> AsyncHolder<Void> {
        return AsyncHolder<Void> { (complete: @escaping (() -> Void)) in
            complete()
        }
    }

    @discardableResult
    public static func main<R>(_ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return empty().main(rightBlock)
    }

    @discardableResult
    public static func background<R>(_ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return empty().background(rightBlock)
    }

    @discardableResult
    public static func async<R>(_ queue: DispatchQueue, _ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return empty().async(queue, rightBlock)
    }

    @discardableResult
    public static func main_delay<R>(_ time: Double, _ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return empty().main_delay(time, rightBlock)
    }

    @discardableResult
    public static func delay<R>(_ time: Double, _ queue: DispatchQueue, _ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return empty().delay(time, queue, rightBlock)
    }
}


