//
//  Created by Peter Combee on 12/08/2023.
//

import XCTest

enum Player {
    case o
}

struct Turn {
    let player: Player
}

struct Game {
    
    private let onBoardStateChange: (Board) -> Void
     
    init(onBoardStateChange: @escaping (Board) -> Void) {
        self.onBoardStateChange = onBoardStateChange
    }
    
    func start() -> Turn {
        onBoardStateChange(Board())
        return Turn(player: .o)
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
}
