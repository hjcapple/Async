import UIKit
import Async

class ViewController: UIViewController {

    private func test0() {
        Async.background {
            print("This is run on the background queue")
            return "hello, World"
        }.main { (result: String) in
            print("This is run on the main queue, after the previous block")
            print(result)
        }
    }

    private func test1() {
        Async.background {
            print("background 1")
            return (10, 10)

        }.main { (a: Int, b: Int) in
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        test0()
        test1()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

