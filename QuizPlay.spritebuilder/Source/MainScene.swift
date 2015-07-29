import Foundation

class MainScene: CCNode
{
    var gameData: GameData!
    weak var playFlappyButton: CCButton!
    
    func didLoadFromCCB()
    {
        //He Who Waits Behind The Wall: 47707152
        //Smashing: 87515813
        //Homestuck: 18853693
        //Indonesian: 1716014
        WebHelper.getQuizletFlashcardData(setNumber: "87115813",resolve: dealWithQuizWordsLoaded)
    }
    
    func dealWithQuizWordsLoaded(gameData: GameData) -> Void
    {
        self.gameData = gameData
        if(gameData.quizWords != Dictionary<String, String>())
        {
            self.playFlappyButton.visible = true
        }
    }
    
    func playButton()
    {
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.gameData = gameData
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
    
    func viewDownloadsButton()
    {
        let viewDownloadsScene = CCBReader.loadAsScene("ViewDownloadsScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(viewDownloadsScene, withTransition: transition)
    }
    
    func playPlatformButton()
    {
//        let platformScene = CCBReader.loadAsScene("GameplayPlatform")
//        let transition = CCTransition(fadeWithDuration: 0.8)
//        CCDirector.sharedDirector().presentScene(platformScene, withTransition: transition)
    }

}
