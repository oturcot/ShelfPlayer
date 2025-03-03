//
//  Defaults.swift
//  iOS
//
//  Created by Rasmus Krämer on 02.02.24.
//

import Foundation
import Defaults
import SPFoundation
import SPNetwork

public extension Defaults.Keys {
    static let lockSeekBar = Key<Bool>("lockSeekBar", default: false)
    static let enableChapterTrack = Key<Bool>("enableChapterTrack", default: true)
    
    static let endPlaybackTimeout = Key<TimeInterval>("endPlaybackTimeout", default: 10)
    
    static let smartRewind = Key<Bool>("smartRewind", default: false)
    static let deleteFinishedDownloads = Key<Bool>("deleteFinishedDownloads", default: false)
    
    static let queueNextEpisodes = Key<Bool>("queueNextEpisodes", default: true)
    static let queueNextAudiobooksInSeries = Key<Bool>("queueNextAudiobooksInSeries", default: false)
    
    static let sleepTimerFadeOut = Key<Bool>("sleepTimerFadeOut", default: true)
    static let extendSleepTimerOnPlay = Key<Bool>("extendSleepTimerOnPlay", default: true)
}
