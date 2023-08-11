//
//  Created by Peter Combee on 11/08/2023.
//

import XCTest

struct Board {
    let state: [[Bool?]] = [
        [.none, .none, .none],
        [.none, .none, .none],
        [.none, .none, .none]
    ]
}

final class BoardTests: XCTestCase {

    func test_startsWithEmptyBoard() {
        XCTAssertEqual(Board().state, [
            [.none, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ])
    }
}
