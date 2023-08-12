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
            makeMove(currentBoard: emptyBoard, player: .o, row: row, col: col)
        })
    }
    
    private func makeMove(currentBoard: Board, player: Player, row: Row, col: Col) -> Turn? {
        let sign: Sign = player == .o ? .o : .x
        let boardAfterMove = currentBoard.mark(row: row, col: col, withSign: sign)
        onBoardStateChange(boardAfterMove)
        return Turn(player: sign == .o ? .x : .o, _mark: { row, col in
            let nextPlayer: Player = player == .o ? .x : .o
            return makeMove(currentBoard: boardAfterMove, player: nextPlayer, row: row, col: col)
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
    
        
        let turn3 = turn2?.mark(row: .two, col: .three)
        
        let expectedBoardStateAfterSecondTurn: [[Sign?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterSecondTurn)
        
        _ = turn3?.mark(row: .three, col: .one)

        let expectedBoardStateAfterThirdTurn: [[Sign?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.o, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterThirdTurn)
    }
}
