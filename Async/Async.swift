import Foundation

public final class AsyncHolder<U> {
    private var _leftBlock: (@escaping ((U) -> Void)) -> Void
    private var _isFinish = true

    fileprivate init(_ block: @escaping (@escaping ((U) -> Void)) -> Void) {
        _leftBlock = block
    }

    deinit {
        if _isFinish {
            _leftBlock { _ in
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
                    let r = rightBlock(u)
                    complete(r)
                }
            }
        }
    }
}

public struct Async {
    
    @discardableResult
    public static func main<R>(_ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return async(DispatchQueue.main, rightBlock)
    }

    @discardableResult
    public static func background<R>(_ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return async(DispatchQueue.global(), rightBlock)
    }

    @discardableResult
    public static func async<R>(_ queue: DispatchQueue, _ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        let block: (@escaping ((R) -> Void)) -> Void = { complete in
            queue.async {
                let r = rightBlock()
                complete(r)
            }
        }
        return AsyncHolder<R>(block)
    }

    @discardableResult
    public static func main_delay<R>(_ time: Double, _ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        return delay(time, DispatchQueue.main, rightBlock)
    }

    @discardableResult
    public static func delay<R>(_ time: Double, _ queue: DispatchQueue, _ rightBlock: @escaping () -> R) -> AsyncHolder<R> {
        let block: (@escaping ((R) -> Void)) -> Void = { complete in
            queue.asyncAfter(deadline: .now() + time) {
                let r = rightBlock()
                complete(r)
            }
        }
        return AsyncHolder<R>(block)
    }
}

