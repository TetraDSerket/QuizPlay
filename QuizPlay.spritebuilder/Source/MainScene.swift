import Foundation
import Mixpanel

class MainScene: CCNode
{
    var mixpanel = Mixpanel.sharedInstance()
    var buttonsAvailable: Bool = true
    
    func didLoadFromCCB()
    {
        var audio: OALSimpleAudio = OALSimpleAudio.sharedInstance()
        audio.playBg("Audio/ObsidianMirror.wav", volume: 0.3, pan: 0.0, loop: true)
        //He Who Waits Behind The Wall: 47707152
        //Smashing: 87515813
        //Homestuck: 18853693
        //Indonesian: 1716014
    }
    
    func searchQuizletButton()
    {
        if(buttonsAvailable)
        {
            buttonsAvailable = false
            mixpanel.track("To Another Scene", properties: ["To Scene": "Search", "From Scene": "Main"])
            MiscMethods.toSearchSetScene()
        }
    }
    
    func viewDownloadsButton()
    {
        if(buttonsAvailable)
        {
            buttonsAvailable = false
            mixpanel.track("To Another Scene", properties: ["To Scene": "Download", "From Scene": "Main"])
            MiscMethods.toViewDownloadsScene()
        }
    }
    
    func toCreditsSceneButton()
    {
        if(buttonsAvailable)
        {
            buttonsAvailable = false
            mixpanel.track("To Another Scene", properties: ["To Scene": "Credits", "From Scene": "Main"])
            let creditsScene = CCBReader.loadAsScene("Credits")
            let transition = CCTransition(fadeWithDuration: 0.8)
            CCDirector.sharedDirector().presentScene(creditsScene, withTransition: transition)
        }
    }
    
    func openQuizlet()
    {
        let url = NSURL(fileURLWithPath: "https://quizlet.com/create-set")
        UIApplication.sharedApplication().openURL(url!)
    }
}
