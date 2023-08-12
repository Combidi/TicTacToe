//
//  Created by Peter Combee on 12/08/2023.
//

import XCTest

enum Player {
    case o
}

struct Turn {
    let player: Player
    let _mark: (Row, Col) -> Void
    
    func mark(row: Row, col: Col) {
        _mark(row, col)
    }
}

struct Game {
    
    private let onBoardStateChange: (Board) -> Void
     
    init(onBoardStateChange: @escaping (Board) -> Void) {
        self.onBoardStateChange = onBoardStateChange
    }
    
    func start() -> Turn {
        let emptyBoard = Board()
        onBoardStateChange(emptyBoard)
        return Turn(player: .o, _mark: { row, col in
            onBoardStateChange(emptyBoard.mark(row: row, col: col, withSign: .o))
        })
    }
}

final class GameTests: XCTestCase {
    
    func test_startsGameForPlayerO() {
        let game = Game(onBoardStateChange: { _ in })
        
        let turn1 = game.start()
        
        XCTAssertEqual(turn1.player, .o)
    }
    
    func test_startGameNotifiesHandlerWithInitialBoardState() {
        var capturedBoard: Board?
        let game = Game(onBoardStateChange: { capturedBoard = $0 })

        XCTAssertNil(capturedBoard)

        _ = game.start()

        let emptyBoard = Board()
        XCTAssertEqual(capturedBoard?.state, emptyBoard.state)
    }
    
    func test_takingFirstTurnUpdatesBoard() {
        var capturedBoard: Board?
        let game = Game(onBoardStateChange: { capturedBoard = $0 })
        let turn1 = game.start()

        turn1.mark(row: .one, col: .two)
        
        let expectedBoardState: [[Sign?]] = [
            [.none, .o, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardState)
    }
}
