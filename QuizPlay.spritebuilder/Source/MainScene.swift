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
        //WebHelper.getQuizletFlashcardData(setNumber: "87115813",resolve: dealWithQuizWordsLoaded)
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
        MiscMethods.toGameplayScene(gameData)
    }
    
    func searchQuizletButton()
    {
        MiscMethods.toSearchSetScene()
    }
    
    func viewDownloadsButton()
    {
        MiscMethods.toViewDownloadsScene()
    }
    
    func playPlatformButton()
    {
//        let platformScene = CCBReader.loadAsScene("GameplayPlatform")
//        let transition = CCTransition(fadeWithDuration: 0.8)
//        CCDirector.sharedDirector().presentScene(platformScene, withTransition: transition)
    }

}
