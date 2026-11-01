//
//  Speaker.swift
//  Red Pen
//
//  Created by Daniel Aguila on 10/30/26.
//

import AVFoundation

final class Speaker {
    static let shared = Speaker()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
    }
    
    func speak(_ text: String, language: String = "ko-KR") {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}
