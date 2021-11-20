//
//  PreferenceView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import Kingfisher
import SwiftUI

struct PreferenceView: View {
    @Binding var currentView: PopoverView.ViewState

    @StateObject private var preferences = Preferences()

    @State private var cacheSize: Int64 = 0

    var body: some View {
        VStack(spacing: contentSpacing) {
            HStack {
                VStack(alignment: .trailing, spacing: contentSpacing) {
                    Toggle("Change picture: ", isOn: $preferences.autoChange)
                        .frame(height: intervalPickerHeight)

                    Text("Cache size: ")
                        .frame(height: intervalPickerHeight)
                }

                VStack(alignment: .leading, spacing: contentSpacing) {
                    Picker("", selection: $preferences.changeInterval) {
                        ForEach(ChangeInterval.timeChangeIntervals) { interval in
                            Text(LocalizedStringKey(interval.rawValue))
                                .tag(interval)
                        }

                        Divider()

                        ForEach(ChangeInterval.eventChangeIntervals) { interval in
                            Text(LocalizedStringKey(interval.rawValue))
                                .tag(interval)
                        }
                    }
                    .frame(width: intervalPickerWidth)
                    .labelsHidden()
                    .disabled(!preferences.autoChange)

                    HStack {
                        Text(ByteCountFormatter().string(fromByteCount: cacheSize))
                            .frame(height: intervalPickerHeight)
                            .onAppear(perform: getCacheSize)

                        Spacer()

                        Button {
                            KingfisherManager.shared.cache.clearCache(completion: getCacheSize)
                        } label: {
                            Text("Clear")
                        }
                    }
                    .frame(width: intervalPickerWidth)
                }
            }

            Text("Version \(versionNumber) (\(buildNumber))")
                .font(.callout)
                .foregroundColor(.secondary)

            HStack(spacing: buttonSpacing) {
                Button(action: transitToPreview) {
                    Text("Done")
                        .fontWeight(.semibold)
                }
                .buttonStyle(CapsuledButtonStyle(size: CGSize(width: buttonWidth,
                                                              height: buttonHeight)))

                Button(action: quit) {
                    Text("Quit")
                        .fontWeight(.semibold)
                }
                .buttonStyle(CapsuledButtonStyle(size: CGSize(width: buttonWidth,
                                                              height: buttonHeight)))
            }
        }
        .padding(.vertical, contentVerticalPadding)
    }

    // MARK: - Funstions

    private func getCacheSize() {
        KingfisherManager.shared.cache.calculateDiskStorageSize { result in
            if case let .success(size) = result {
                cacheSize = Int64(size)
            }
        }
    }

    private func transitToPreview() {
        withAnimation(.easeInOut) {
            currentView = .preview
        }
    }

    private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Constants

    private let intervalPickerWidth: CGFloat = 180
    private let intervalPickerHeight: CGFloat = 20
    private let buttonSpacing: CGFloat = 24
    private let buttonWidth: CGFloat = 120
    private let buttonHeight: CGFloat = 40
    private let contentSpacing: CGFloat = 20
    private let contentVerticalPadding: CGFloat = 20

    private let versionNumber = Bundle.main
        .object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(currentView: .constant(.preference))
            .frame(width: 400)
    }
}
