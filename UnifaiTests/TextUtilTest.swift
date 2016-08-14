
import XCTest
@testable import Unifai

class TextUtilsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlaceholders() {
        let example = "@budget add <amount> to <category>"
        let positions = TextUtils.getPlaceholderPositionsInMessage(example)
        
        XCTAssert(positions.count > 0)
    }
    
    
}
