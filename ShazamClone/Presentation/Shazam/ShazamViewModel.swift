//
//  ShazamViewModel.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//
import Foundation
import AVKit
import ShazamKit

class ShazamViewModel: NSObject, ObservableObject {
    private var session = SHSession()
    private let audioEngine = AVAudioEngine()
    @Published var viewState: ViewState = .initial

    override init() {
        super.init()
        session.delegate = self
    }

    func showInfo() {
        self.viewState = .infoAlert
    }

    func startListening() {
        let audioSession = AVAudioSession.sharedInstance()

        switch audioSession.recordPermission {
        case .undetermined:
            requestRecordPermission(audioSession: audioSession)
        case .denied:
            viewState = .recordPermissionSettingsAlert
        case .granted:
            DispatchQueue.global(qos: .background).async {
                self.proceedWithRecording()
            }
        @unknown default:
            requestRecordPermission(audioSession: audioSession)
        }
    }

    func stopListening() {
        stopRecording()
    }

    private func requestRecordPermission(audioSession: AVAudioSession) {
        audioSession.requestRecordPermission { [weak self] status in
            DispatchQueue.main.async {
                if status {
                    DispatchQueue.global(qos: .background).async {
                        self?.proceedWithRecording()
                    }
                } else {
                    print("Permission denied")
                }
            }
        }
    }

    private func proceedWithRecording() {
        DispatchQueue.main.async {
            self.viewState = .recordingInProgress
        }

        if audioEngine.isRunning {
            stopRecording()
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)

        inputNode.removeTap(onBus: .zero)
        inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            print("Current Recording at: \(time)")
            self?.session.matchStreamingBuffer(buffer, at: time)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func stopRecording() {
        audioEngine.stop()
    }
}

extension ShazamViewModel: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let firstMatch = match.mediaItems.first else {
            return
        }
        stopRecording()

        let song = Song(
            title: firstMatch.title ?? "",
            artist: firstMatch.artist ?? "",
            genres: firstMatch.genres,
            artworkUrl: firstMatch.artworkURL,
            appleMusicUrl: firstMatch.appleMusicURL
        )
        DispatchQueue.main.async {
            self.viewState = .result(song: song)
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print(error?.localizedDescription ?? "")
        stopRecording()
        DispatchQueue.main.async {
            self.viewState = .noResult
        }
    }
}

extension ShazamViewModel {
    enum ViewState {
        case initial
        case recordingInProgress
        case infoAlert
        case recordPermissionSettingsAlert
        case noResult
        case result(song: Song)
    }
}
