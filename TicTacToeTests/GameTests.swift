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
    
    func test_startsGameForPlayerO() throws {
        var capturedTurns = [Turn]()
        let game = makeSUT(onNextTurn: { capturedTurns.append($0) })
    
        game.start(with: .emptyBoard())
        
        let firstTurn = try XCTUnwrap(capturedTurns.first)
        XCTAssertEqual(firstTurn.player, .o)
    }
    
    func test_alternatesPlayerForEachTurn() {
        var capturedTurns = [Turn]()
        let game = makeSUT(onNextTurn: { capturedTurns.append($0) })
        game.start(with: .emptyBoard())
        
        XCTAssertEqual(capturedTurns[0].player, .o)

        capturedTurns[0].mark(row: .one, col: .one)
        
        XCTAssertEqual(capturedTurns[1].player, .x)

        capturedTurns[1].mark(row: .one, col: .two)

        XCTAssertEqual(capturedTurns[2].player, .o)

        capturedTurns[2].mark(row: .one, col: .three)
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
        var capturedTurns = [Turn]()
        let game = makeSUT(
            onBoardStateChange: { capturedBoard = $0 },
            onNextTurn: { capturedTurns.append($0) }
        )
        game.start(with: .emptyBoard())
        
        capturedTurns[0].mark(row: .one, col: .two)
        
        let expectedBoardStateAfterFirstTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
        
        capturedTurns[1].mark(row: .two, col: .three)
        
        let expectedBoardStateAfterSecondTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterSecondTurn)
        
        capturedTurns[2].mark(row: .three, col: .one)
        
        let expectedBoardStateAfterThirdTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.o, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterThirdTurn)
    }
    
    func test_moveAttemptToMarkAnAlreadyTakenSpotOnTheBoard_doesNotOverrideExistingMark() {
        var capturedBoard: Board?
        var capturedTurns = [Turn]()
        let game = makeSUT(
            onBoardStateChange: { capturedBoard = $0 },
            onNextTurn: { capturedTurns.append($0) }
        )
        game.start(with: .emptyBoard())
        
        capturedTurns[0].mark(row: .one, col: .one)
        capturedTurns[1].mark(row: .one, col: .one)

        let expectedBoardStateAfterFirstTurn: [[Mark?]] = [
            [.o, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
    }
    
    func test_moveAttemptToMarkAnAlreadyTakenSpotOnTheBoard_doesNotAlternatePlayer() {
        var capturedTurns = [Turn]()
        let game = makeSUT(onNextTurn: { capturedTurns.append($0) })
        game.start(with: .emptyBoard())
        XCTAssertEqual(capturedTurns[0].player, .o)

        capturedTurns[0].mark(row: .two, col: .two)
        
        XCTAssertEqual(capturedTurns[1].player, .x)

        capturedTurns[1].mark(row: .two, col: .two)
        
        XCTAssertEqual(capturedTurns[2].player, .x)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        onBoardStateChange: @escaping (Board) -> Void = { _ in },
        onNextTurn: @escaping (Turn) -> Void = { _ in }
    ) -> Game {
        Game(onBoardStateChange: onBoardStateChange, onNextTurn: onNextTurn)
    }
}
