import Foundation

class MainScene: CCNode
{
    func playButton()
    {
        let gameplayScene = CCBReader.loadAsScene("GameplaySling")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }

}
