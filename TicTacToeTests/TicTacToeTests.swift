//
//  Created by Peter Combee on 11/08/2023.
//

import XCTest

struct TicTacToe {
    let state: [[Bool?]] = [
        [.none, .none, .none],
        [.none, .none, .none],
        [.none, .none, .none]
    ]
}

final class TicTacToeTests: XCTestCase {

    func test_startsWithEmptyBoard() {
        
        let game = TicTacToe()
        
        XCTAssertEqual(TicTacToe().state, [
            [.none, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ])
    }
}
