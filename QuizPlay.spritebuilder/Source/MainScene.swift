import Foundation

class MainScene: CCNode
{
    override func onEnter()
    {
        //WebHelper.getQuizletData()
    }
    
    func playButton()
    {
        let flappyScene = CCBReader.loadAsScene("GameplayFlappy")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(flappyScene, withTransition: transition)
    }
    
    func playPlatformButton()
    {
//        let platformScene = CCBReader.loadAsScene("GameplayPlatform")
//        let transition = CCTransition(fadeWithDuration: 0.8)
//        CCDirector.sharedDirector().presentScene(platformScene, withTransition: transition)
    }

}
