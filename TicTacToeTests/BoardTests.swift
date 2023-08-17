//
//  Created by Peter Combee on 11/08/2023.
//

import XCTest

enum Mark {
    case x, o
}

enum Row: Int {
    case one = 0, two, three
}

enum Index: Int {
    case one = 0, two, three
}

struct Spot {
    let row: Row
    let index: Index
}

struct Board {
        
    static func emptyBoard() -> Board {
        Board(state: [
            [.none, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ])
    }

    private init(state: [[Mark?]]) {
        self.state = state
    }
    
    let state: [[Mark?]]
    
    func mark(_ spot: Spot, with mark: Mark) -> Board {
        var copy = state
        copy[spot.row.rawValue][spot.index.rawValue] = mark
        return Board(state: copy)
    }
}

final class BoardTests: XCTestCase {

    func test_startsWithEmptyBoard() {
        XCTAssertEqual(Board.emptyBoard().state, [
            [.none, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ])
    }
    
    func test_markSpotUpdatesState() {
        
        let board = Board.emptyBoard()
        
        let firstMove = board.mark(Spot(row: .one, index: .two), with: .x)
     
        let expectedStateAfterFirstMove: [[Mark?]] = [
            [.none, .x, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(firstMove.state, expectedStateAfterFirstMove)
        
        let secondMove = firstMove.mark(Spot(row: .two, index: .one), with: .o)

        let expectedStateAfterSecondMove: [[Mark?]] = [
            [.none, .x, .none],
            [.o, .none, .none],
            [.none, .none, .none]
        ]

        XCTAssertEqual(secondMove.state, expectedStateAfterSecondMove)
        
        let thirdMove = secondMove.mark(Spot(row: .three, index: .three), with: .x)
        
        let expectedStateAfterThirdMove: [[Mark?]] = [
            [.none, .x, .none],
            [.o, .none, .none],
            [.none, .none, .x]
        ]

        XCTAssertEqual(thirdMove.state, expectedStateAfterThirdMove)
    }
}
