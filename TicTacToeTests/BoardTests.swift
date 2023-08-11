//
//  Created by Peter Combee on 11/08/2023.
//

import XCTest

enum Sign {
    case x
}

struct Board {
    
    enum Row {
        case one
    }
    
    enum Col {
        case two
    }
    
    var state: [[Sign?]] = [
        [.none, .none, .none],
        [.none, .none, .none],
        [.none, .none, .none]
    ]
    
    func mark(row: Row, col: Col, withSign sign: Sign) -> Board {
        var copy = state
        copy[0][1] = .x
        return Board(state: copy)
    }
}

final class BoardTests: XCTestCase {

    func test_startsWithEmptyBoard() {
        XCTAssertEqual(Board().state, [
            [.none, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ])
    }
    
    func test_markSpotUpdatesState() {
        
        let board = Board()
        
        let newState = board.mark(row: .one, col: .two, withSign: .x)
     
        let expectedState: [[Sign?]] = [
            [.none, .x, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(newState.state, expectedState)
    }
}
