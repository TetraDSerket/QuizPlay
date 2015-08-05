import Foundation
import Mixpanel

class MainScene: CCNode
{
    var mixpanel = Mixpanel.sharedInstance()
    
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
        mixpanel.track("To Another Scene", properties: ["To Scene": "Search", "From Scene": "Main"])
        MiscMethods.toSearchSetScene()
    }
    
    func viewDownloadsButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Download", "From Scene": "Main"])
        MiscMethods.toViewDownloadsScene()
    }
}
