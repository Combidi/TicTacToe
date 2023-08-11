//
//  Created by Peter Combee on 11/08/2023.
//

import XCTest

enum Sign {
    case x, o
}

struct Board {
    
    enum Row: Int {
        case one = 0, two
    }
    
    enum Col: Int {
        case one = 0, two
    }
    
    var state: [[Sign?]] = [
        [.none, .none, .none],
        [.none, .none, .none],
        [.none, .none, .none]
    ]
    
    func mark(row: Row, col: Col, withSign sign: Sign) -> Board {
        var copy = state
        copy[row.rawValue][col.rawValue] = sign
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
        
        let firstMove = board.mark(row: .one, col: .two, withSign: .x)
     
        let expectedStateAfterFirstMove: [[Sign?]] = [
            [.none, .x, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(firstMove.state, expectedStateAfterFirstMove)
        
        let secondMove = firstMove.mark(row: .two, col: .one, withSign: .o)

        let expectedStateAfterSecondMove: [[Sign?]] = [
            [.none, .x, .none],
            [.o, .none, .none],
            [.none, .none, .none]
        ]

        XCTAssertEqual(secondMove.state, expectedStateAfterSecondMove)
    }
}
