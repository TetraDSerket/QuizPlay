import Foundation

class MainScene: CCNode
{
    var quizWords = Dictionary<String, String>()
    weak var playFlappyButton: CCButton!
    
    func didLoadFromCCB()
    {
        //He Who Waits Behind The Wall: 47707152
        //Smashing: 87515813
        //Homestuck: 18853693
        //Indonesian: 1716014
        WebHelper.getQuizletFlashcardData(setNumber: "87515813",resolve: dealWithQuizWordsLoaded)
    }
    
    func dealWithQuizWordsLoaded(quizWords: Dictionary<String, String>) -> Void
    {
        println(quizWords)
        self.quizWords = quizWords
        if(quizWords != Dictionary<String, String>())
        {
            self.playFlappyButton.visible = true
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
