//
//  ShazamView.swift
//  ShazamClone
//
//  Created by Emmanuel Kehinde on 03/07/2021.
//
import Combine
import RippleView
import SwiftUI

struct ShazamView: View {
    @State private var shouldShowRippleView = false
    @State private var shouldShowRecordButton = false
    @State private var shouldShowInfoAlert = false
    @State private var shouldShowRecordPermissionAlert = false
    @State private var shouldShowNoResultView = false
    @State private var foundSong: Song!
    @State private var cancellables: Set<AnyCancellable> = []
    @EnvironmentObject private var shazamViewModel: ShazamViewModel
    
    var body: some View {
        ZStack {
            Color.white

            ZStack {
                VStack(spacing: 20) {
                    if shouldShowRippleView {
                        RippleView(
                            style: .solid,
                            rippleCount: 5,
                            tintColor: Color.blue,
                            timeIntervalBetweenRipples: 0.18
                        )
                        .padding(.horizontal, 48)
                    }

                    if shouldShowNoResultView {
                        NoResultView {
                            onRecordButtonTapped()
                        }
                    }

                    if shouldShowRecordButton {
                        recordButton
                            .alert(isPresented: $shouldShowRecordPermissionAlert, content: {
                                permissionAlert
                            })
                    }

                    if foundSong != nil {
                        VStack {
                            withAnimation(.easeInOut) {
                                SongDetailView(song: foundSong)
                            }
                            Spacer()
                            recordButton
                        }
                        .padding(.vertical, 64)
                    }

                }

                VStack {
                    HStack {
                        Spacer()
                        infoButton
                            .alert(isPresented: $shouldShowInfoAlert, content: {
                                infoAlert
                            })
                    }
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 32))

                    Spacer()
                }

                VStack {
                    Spacer()
                    footerText.padding(.bottom, 16)
                }
            }
            .padding(EdgeInsets(top: Constants.topInset, leading: 0, bottom: Constants.bottomInset, trailing: 0))
        }
        .onAppear(perform: {
            bindViewModel()
        })
        .onDisappear(perform: {
            shazamViewModel.stopListening()
        })
        .ignoresSafeArea()
    }

    private var infoAlert: Alert {
        Alert(
            title: Text("Shazam Clone"),
            message: Text("Tap the record button to listen to music around you"),
            dismissButton: .default(Text("OK"))
        )
    }

    private var permissionAlert: Alert {
        Alert(
            title: Text("Microphone access not allowed"),
            message: Text("Turn on microphone access to listen to music around you"),
            primaryButton: .default(
                Text("Go to Setting"),
                action: {
                    goToPermissionSettings()
                }
            ),
            secondaryButton: .cancel(Text("Close"))
        )
    }

    @ViewBuilder
    private var infoButton: some View {
        Button(action: {
            shazamViewModel.showInfo()
        }, label: {
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 20, height: 20, alignment: .center)
                .scaledToFit()
                .foregroundColor(Color.black.opacity(0.7))
        })

    }

    @ViewBuilder
    private var recordButton: some View {
        Button(action: {
            onRecordButtonTapped()
        }, label: {
            Image(systemName: "mic")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 100, height: 100, alignment: .center)
                .background(
                    Circle().fill(Color.blue)
                        .shadow(radius: 1)
                )
        })

    }

    @ViewBuilder
    private var footerText: some View {
        Text("Shazam Clone")
            .font(.footnote)
            .foregroundColor(Color.black.opacity(0.7))
    }

    private func bindViewModel() {
        shazamViewModel.$viewState.sink { viewState in
            switch viewState {
            case .initial:
                shouldShowRippleView = false
                shouldShowRecordButton = true
                shouldShowNoResultView = false
            case .recordingInProgress:
                shouldShowRecordButton = false
                shouldShowRippleView = true
                shouldShowNoResultView = false
                foundSong = nil
            case .infoAlert:
                shouldShowInfoAlert = true
            case .recordPermissionSettingsAlert:
                shouldShowRecordPermissionAlert = true
            case .noResult:
                shouldShowRippleView = false
                shouldShowNoResultView = true
                foundSong = nil
            case .result(let song):
                withAnimation {
                    foundSong = song
                }
                shouldShowRippleView = false
            }
        }.store(in: &cancellables)
    }

    private func onRecordButtonTapped() {
        shazamViewModel.startListening()
    }

    private func goToPermissionSettings() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    enum Constants {
        // Temporary hack for the iOS 15 weird top and bottom inset
        static let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        static let bottomInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 20
    }
}

struct ShazamView_Previews: PreviewProvider {
    static var previews: some View {
        ShazamView()
    }
}
