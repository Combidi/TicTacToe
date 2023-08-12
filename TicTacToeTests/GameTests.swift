//
//  Created by Peter Combee on 12/08/2023.
//

import XCTest

enum Player {
    case o
    case x
}

struct Turn {
    let player: Player
    let _mark: (Row, Col) -> Turn?
    
    func mark(row: Row, col: Col) -> Turn? {
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
            let boardAfterFirstTurn = emptyBoard.mark(row: row, col: col, withSign: .o)
            onBoardStateChange(boardAfterFirstTurn)
            return Turn(player: .x, _mark: { row, col in
                let boardAfterSecondTurn = boardAfterFirstTurn.mark(row: row, col: col, withSign: .x)
                onBoardStateChange(boardAfterSecondTurn)
                return nil
            })
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
    
    func test_takingTurnsUpdatesBoard() {
        var capturedBoard: Board?
        let game = Game(onBoardStateChange: { capturedBoard = $0 })
        
        let turn1 = game.start()
        
        let turn2 = turn1.mark(row: .one, col: .two)
        
        let expectedBoardStateAfterFirstTurn: [[Sign?]] = [
            [.none, .o, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
    
        
        _ = turn2?.mark(row: .two, col: .three)
        
        let expectedBoardStateAfterSecondTurn: [[Sign?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterSecondTurn)
    }
}
