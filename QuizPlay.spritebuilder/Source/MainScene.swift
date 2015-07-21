import Foundation

class MainScene: CCNode
{
    var quizWords = Dictionary<String, String>()
    weak var playFlappyButton: CCButton!
    
    func didLoadFromCCB()
    {
        WebHelper.getQuizletFlashcardData
        {
            (quizWords: Dictionary<String, String>) -> Void in
            println(quizWords)
            self.quizWords = quizWords
            if(quizWords != Dictionary<String, String>())
            {
                self.playFlappyButton.visible = true
            }
        }
    }
    
    func playButton()
    {
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.quizWords = quizWords
        scene.addChild(flappyScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func searchQuizletButton()
    {
        let searchSetScene = CCBReader.loadAsScene("SearchSetScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(searchSetScene, withTransition: transition)
    }
    
    func playPlatformButton()
    {
//        let platformScene = CCBReader.loadAsScene("GameplayPlatform")
//        let transition = CCTransition(fadeWithDuration: 0.8)
//        CCDirector.sharedDirector().presentScene(platformScene, withTransition: transition)
    }

}
