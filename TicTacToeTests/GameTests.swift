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
    func start() -> Turn {
        Turn(player: .o)
    }
}

final class GameTests: XCTestCase {
    
    func test_startsGameForPlayerO() {
        let game = Game()
        
        let turn1 = game.start()
        
        XCTAssertEqual(turn1.player, .o)
    }
}
