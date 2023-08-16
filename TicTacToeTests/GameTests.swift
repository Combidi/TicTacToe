//
//  Created by Peter Combee on 12/08/2023.
//

import XCTest

enum Player {
    case o
    case x
    
    fileprivate var mark: Mark { self == .o ? .o : .x }
    fileprivate var opponent: Player { self == .o ? .x : .o }
}

struct Turn {
    let player: Player
    fileprivate let _mark: (Row, Col) -> Void
    
    func mark(row: Row, col: Col) {
        _mark(row, col)
    }
}

struct Game {
    
    private let onBoardStateChange: (Board) -> Void
    private let onNextTurn: (Turn) -> Void
    
    init(onBoardStateChange: @escaping (Board) -> Void, onNextTurn: @escaping (Turn) -> Void) {
        self.onBoardStateChange = onBoardStateChange
        self.onNextTurn = onNextTurn
    }
    
    func start(with currentBoard: Board) {
        onBoardStateChange(currentBoard)
        let startingPlayer = Player.o
        let nextTurn = makeTurn(for: startingPlayer, currentBoard: currentBoard)
        onNextTurn(nextTurn)
    }
    
    private func makeTurn(for player: Player, currentBoard: Board) -> Turn {
        return Turn(player: player, _mark: { row, col in
            makeMove(currentBoard: currentBoard, player: player, row: row, col: col)
        })
    }
    
    private func makeMove(currentBoard: Board, player: Player, row: Row, col: Col) {
        guard currentBoard.state[row.rawValue][col.rawValue] == .none else {
            let retry = makeTurn(for: player, currentBoard: currentBoard)
            return onNextTurn(retry)
        }
        let boardAfterMove = currentBoard.mark(row: row, col: col, withMark: player.mark)
        onBoardStateChange(boardAfterMove)
        let nextTurn = makeTurn(for: player.opponent, currentBoard: boardAfterMove)
        onNextTurn(nextTurn)
    }
}

final class GameTests: XCTestCase {
    
    func test_startsGameForPlayerO() {
        var currentTurn: Turn?
        let game = makeSUT(onNextTurn: { currentTurn = $0 })
    
        game.start(with: .emptyBoard())
        
        XCTAssertEqual(currentTurn?.player, .o)
    }
    
    func test_alternatesPlayerForEachTurn() {
        var currentTurn: Turn?
        let game = makeSUT(onNextTurn: { currentTurn = $0 })
        game.start(with: .emptyBoard())
        
        XCTAssertEqual(currentTurn?.player, .o)

        currentTurn?.mark(row: .one, col: .one)
        
        XCTAssertEqual(currentTurn?.player, .x)

        currentTurn?.mark(row: .one, col: .two)

        XCTAssertEqual(currentTurn?.player, .o)

        currentTurn?.mark(row: .one, col: .three)
    }
    
    func test_startGameNotifiesHandlerWithInitialBoardState() {
        var capturedBoard: Board?
        let game = makeSUT(onBoardStateChange: { capturedBoard = $0 })
        
        XCTAssertNil(capturedBoard)
        
        let emptyBoard = Board.emptyBoard()
        game.start(with: emptyBoard)
        
        XCTAssertEqual(capturedBoard?.state, emptyBoard.state)
    }
    
    func test_takingTurnsUpdatesBoard() {
        var capturedBoard: Board?
        var currentTurn: Turn?
        let game = makeSUT(
            onBoardStateChange: { capturedBoard = $0 },
            onNextTurn: { currentTurn = $0 }
        )
        game.start(with: .emptyBoard())
        
        currentTurn?.mark(row: .one, col: .two)
        
        let expectedBoardStateAfterFirstTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
        
        currentTurn?.mark(row: .two, col: .three)
        
        let expectedBoardStateAfterSecondTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterSecondTurn)
        
        currentTurn?.mark(row: .three, col: .one)
        
        let expectedBoardStateAfterThirdTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.o, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterThirdTurn)
    }
    
    func test_moveAttemptToMarkAnAlreadyTakenSpotOnTheBoard_doesNotOverrideExistingMark() {
        var capturedBoard: Board?
        var currentTurn: Turn?
        let game = makeSUT(
            onBoardStateChange: { capturedBoard = $0 },
            onNextTurn: { currentTurn = $0 }
        )
        game.start(with: .emptyBoard())
        
        currentTurn?.mark(row: .one, col: .one)
        currentTurn?.mark(row: .one, col: .one)
        
        let expectedBoardStateAfterFirstTurn: [[Mark?]] = [
            [.o, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
    }
    
    func test_moveAttemptToMarkAnAlreadyTakenSpotOnTheBoard_doesNotAlternatePlayer() {
        var currentTurn: Turn?
        let game = makeSUT(onNextTurn: { currentTurn = $0 })
        game.start(with: .emptyBoard())
        XCTAssertEqual(currentTurn?.player, .o)

        currentTurn?.mark(row: .two, col: .two)
        XCTAssertEqual(currentTurn?.player, .x)

        currentTurn?.mark(row: .two, col: .two)
        XCTAssertEqual(currentTurn?.player, .x)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        onBoardStateChange: @escaping (Board) -> Void = { _ in },
        onNextTurn: @escaping (Turn) -> Void = { _ in }
    ) -> Game {
        Game(onBoardStateChange: onBoardStateChange, onNextTurn: onNextTurn)
    }
}
