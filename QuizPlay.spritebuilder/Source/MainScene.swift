import Foundation

class MainScene: CCNode
{
    func playButton()
    {
        let gameplayScene = CCBReader.loadAsScene("GameplayFlappy2")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: transition)
    }

}
