//
//  Created by Peter Combee on 12/08/2023.
//

import XCTest

enum Player {
    case o
    case x
    
    fileprivate var sign: Sign { self == .o ? .o : .x }
    fileprivate var opponent: Player { self == .o ? .x : .o }
}

struct Turn {
    let player: Player
    fileprivate let _mark: (Row, Col) -> Turn?
    
    func mark(row: Row, col: Col) -> Turn? {
        _mark(row, col)
    }
}

struct Game {
    
    private let onBoardStateChange: (Board) -> Void
     
    init(onBoardStateChange: @escaping (Board) -> Void) {
        self.onBoardStateChange = onBoardStateChange
    }
    
    func start(with currentBoard: Board) -> Turn {
        onBoardStateChange(currentBoard)
        let startingPlayer = Player.o
        return makeTurn(for: startingPlayer, currentBoard: currentBoard)
    }
        
    private func makeTurn(for player: Player, currentBoard: Board) -> Turn {
        return Turn(player: player, _mark: { row, col in
            makeMove(currentBoard: currentBoard, player: player, row: row, col: col)
        })
    }

    private func makeMove(currentBoard: Board, player: Player, row: Row, col: Col) -> Turn? {
        guard currentBoard.state[row.rawValue][col.rawValue] == .none else { return nil }
        let boardAfterMove = currentBoard.mark(row: row, col: col, withSign: player.sign)
        onBoardStateChange(boardAfterMove)
        return makeTurn(for: player.opponent, currentBoard: boardAfterMove)
    }
}

final class GameTests: XCTestCase {
    
    func test_startsGameForPlayerO() {
        let game = Game(onBoardStateChange: { _ in })
        
        let turn1 = game.start(with: .emptyBoard())
        XCTAssertEqual(turn1.player, .o)
    }

    func test_alternatesPlayerForEachTurn() {
        let game = Game(onBoardStateChange: { _ in })
        
        let turn1 = game.start(with: .emptyBoard())
        XCTAssertEqual(turn1.player, .o)

        let turn2 = turn1.mark(row: .one, col: .one)
        XCTAssertEqual(turn2?.player, .x)

        let turn3 = turn2?.mark(row: .one, col: .two)
        XCTAssertEqual(turn3?.player, .o)

        let turn4 = turn3?.mark(row: .one, col: .three)
        XCTAssertEqual(turn4?.player, .x)
    }
    
    func test_startGameNotifiesHandlerWithInitialBoardState() {
        var capturedBoard: Board?
        let game = Game(onBoardStateChange: { capturedBoard = $0 })
        
        XCTAssertNil(capturedBoard)
        
        let emptyBoard = Board.emptyBoard()
        _ = game.start(with: emptyBoard)
        
        XCTAssertEqual(capturedBoard?.state, emptyBoard.state)
    }
    
    func test_takingTurnsUpdatesBoard() {
        var capturedBoard: Board?
        let game = Game(onBoardStateChange: { capturedBoard = $0 })
        
        let turn1 = game.start(with: .emptyBoard())
        
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

    func test_makingMoveDoesNotOverrideAlreadySignedDoesNotOverrideBoard() {
        var capturedBoard: Board?
        let game = Game(onBoardStateChange: { capturedBoard = $0 })
        _ = game.start(with: .emptyBoard())
            .mark(row: .one, col: .one)?
            .mark(row: .one, col: .one)
        
        let expectedBoardStateAfterFirstTurn: [[Sign?]] = [
            [.o, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]

        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
    }
}
