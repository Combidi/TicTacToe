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
    fileprivate let _mark: (Spot) -> Void
        
    func mark(_ spot: Spot) {
        _mark(spot)
    }
}

private extension Board {
    func spotIsNotMarked(_ spot: Spot) -> Bool {
        state[spot.row.rawValue][spot.index.rawValue] == .none
    }
    
    func numberOfSpotsMarkedWith(_ mark: Mark) -> Int {
        state
            .flatMap { $0 }
            .compactMap { $0 }
            .filter { $0 == mark }
            .count
    }
}

struct Game {
    
    private let onBoardStateChange: (Board) -> Void
    private let onNextTurn: (Turn) -> Void
    private let didEndWithWinner: (Player) -> Void
    
    init(
        onBoardStateChange: @escaping (Board) -> Void,
        onNextTurn: @escaping (Turn) -> Void,
        didEndWithWinner: @escaping (Player) -> Void
    ) {
        self.onBoardStateChange = onBoardStateChange
        self.onNextTurn = onNextTurn
        self.didEndWithWinner = didEndWithWinner
    }
    
    private func determineNextPlayer(for currentBoard: Board) -> Player {
        let markCountForPlayerX = currentBoard.numberOfSpotsMarkedWith(.x)
        let markCountForPlayerO = currentBoard.numberOfSpotsMarkedWith(.o)
                
        if markCountForPlayerX < markCountForPlayerO {
            return .x
        } else {
            return .o
        }
    }
    
    func start(with currentBoard: Board) {
        onBoardStateChange(currentBoard)
        let startingPlayer = determineNextPlayer(for: currentBoard)
        let nextTurn = makeTurn(for: startingPlayer, currentBoard: currentBoard)
        onNextTurn(nextTurn)
    }
    
    private func makeTurn(for player: Player, currentBoard: Board) -> Turn {
        Turn(player: player, _mark: { spot in
            makeMove(forPlayer: player, attemptingToMark: spot, onCurrentBoard: currentBoard)
        })
    }
    
    private func makeMove(
        forPlayer player: Player,
        attemptingToMark spot: Spot,
        onCurrentBoard currentBoard: Board
    ) {
        guard currentBoard.spotIsNotMarked(spot) else {
            let retry = makeTurn(for: player, currentBoard: currentBoard)
            return onNextTurn(retry)
        }
        let boardAfterMove = currentBoard.mark(spot, with: player.mark)
        onBoardStateChange(boardAfterMove)
        if boardAfterMove.state == [
            [.o, .o, .o],
            [.x, .x, .none],
            [.none, .none, .none]
        ] {
            return didEndWithWinner(.x)
        }
        let nextTurn = makeTurn(for: player.opponent, currentBoard: boardAfterMove)
        onNextTurn(nextTurn)
    }
}

final class GameTests: XCTestCase {
    
    func test_startWithEmptyBoard_startsGameForPlayerO() throws {
        var capturedTurns = [Turn]()
        let game = makeSUT(onNextTurn: { capturedTurns.append($0) })
    
        game.start(with: .emptyBoard())
        
        let firstTurn = try XCTUnwrap(capturedTurns.first)
        XCTAssertEqual(firstTurn.player, .o)
    }
    
    func test_startGameWithNonEmptyBoard_resumesGameForCorrectPlayer() throws {
        let samples: [(nonEmptyBoard: Board, expectedPlayerOnTurn: Player)] = [
            (Board(state: [[.o, .none, .none], [.none, .none, .none], [.none, .none, .none]]), .x),
            (Board(state: [[.o, .x, .none], [.none, .none, .none], [.none, .none, .none]]), .o),
            (Board(state: [[.none, .none, .none], [.none, .x, .none], [.o, .none, .x]]), .o),
            (Board(state: [[.none, .o, .none], [.none, .x, .o], [.o, .none, .x]]), .x)
        ]
        
        try samples.enumerated().forEach { index, sample in
            var capturedTurns = [Turn]()
            let game = makeSUT(onNextTurn: { capturedTurns.append($0) })
            
            game.start(with: sample.nonEmptyBoard)
            
            let firstTurn = try XCTUnwrap(capturedTurns.first, "for sample at index: \(index)")
            XCTAssertEqual(firstTurn.player, sample.expectedPlayerOnTurn, "for sample at index: \(index)")
        }
    }
    
    func test_alternatesPlayerForEachTurn() {
        var capturedTurns = [Turn]()
        let game = makeSUT(onNextTurn: { capturedTurns.append($0) })
        game.start(with: .emptyBoard())
        
        XCTAssertEqual(capturedTurns[0].player, .o)

        capturedTurns[0].mark(Spot(row: .one, index: .one))
        
        XCTAssertEqual(capturedTurns[1].player, .x)

        capturedTurns[1].mark(Spot(row: .one, index: .two))

        XCTAssertEqual(capturedTurns[2].player, .o)

        capturedTurns[2].mark(Spot(row: .one, index: .three))
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
        
        capturedTurns[0].mark(Spot(row: .one, index: .two))
        
        let expectedBoardStateAfterFirstTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterFirstTurn)
        
        capturedTurns[1].mark(Spot(row: .two, index: .three))
        
        let expectedBoardStateAfterSecondTurn: [[Mark?]] = [
            [.none, .o, .none],
            [.none, .none, .x],
            [.none, .none, .none]
        ]
        
        XCTAssertEqual(capturedBoard?.state, expectedBoardStateAfterSecondTurn)
        
        capturedTurns[2].mark(Spot(row: .three, index: .one))
        
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
        
        capturedTurns[0].mark(Spot(row: .one, index: .one))
        capturedTurns[1].mark(Spot(row: .one, index: .one))

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

        capturedTurns[0].mark(Spot(row: .two, index: .two))
        
        XCTAssertEqual(capturedTurns[1].player, .x)

        capturedTurns[1].mark(Spot(row: .two, index: .two))
        
        XCTAssertEqual(capturedTurns[2].player, .x)
    }
    
    func test_makingWinningMoveEndsGameWithWinningPlayer() {
        var capturedTurns = [Turn]()
        var capturedWinner: Player?
        let game = makeSUT(
            onNextTurn: { capturedTurns.append($0) },
            didEndWithWinner: { capturedWinner = $0 }
        )
        game.start(with: .emptyBoard())
        XCTAssertEqual(capturedTurns[0].player, .o)

        capturedTurns[0].mark(Spot(row: .one, index: .one))

        XCTAssertNil(capturedWinner)
        
        capturedTurns[1].mark(Spot(row: .two, index: .one))
        
        XCTAssertNil(capturedWinner)
        
        capturedTurns[2].mark(Spot(row: .one, index: .two))

        XCTAssertNil(capturedWinner)
        
        capturedTurns[3].mark(Spot(row: .two, index: .two))
        
        XCTAssertNil(capturedWinner)

        capturedTurns[4].mark(Spot(row: .one, index: .three))
        
        XCTAssertEqual(capturedWinner, .x)
    }
    
    func test_makingWinningMoveDoesNotNotifyHandlerWithNextTurn() {
        var capturedTurns = [Turn]()
        let game = makeSUT(
            onNextTurn: { capturedTurns.append($0) }
        )
        game.start(with: .emptyBoard())

        capturedTurns[0].mark(Spot(row: .one, index: .one))
        capturedTurns[1].mark(Spot(row: .two, index: .one))
        capturedTurns[2].mark(Spot(row: .one, index: .two))
        capturedTurns[3].mark(Spot(row: .two, index: .two))
        capturedTurns[4].mark(Spot(row: .one, index: .three))
        
        XCTAssertEqual(capturedTurns.count, 5)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        onBoardStateChange: @escaping (Board) -> Void = { _ in },
        onNextTurn: @escaping (Turn) -> Void = { _ in },
        didEndWithWinner: @escaping (Player) -> Void = { _ in }
    ) -> Game {
        Game(
            onBoardStateChange: onBoardStateChange,
            onNextTurn: onNextTurn,
            didEndWithWinner: didEndWithWinner
        )
    }
}
