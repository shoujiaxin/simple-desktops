//
//  PreferenceView.swift
//  SimpleDesktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct PreferenceView: View {
    @Binding var currentView: PopoverView.ViewState

    @StateObject private var preferences = Preferences()

    var body: some View {
        VStack {
            Toggle(isOn: $preferences.autoChange) {
                Picker("Change picture: ", selection: $preferences.changeInterval) {
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
                .disabled(!preferences.autoChange)
            }
            .padding(.vertical, pickerPadding)

            Text("Version \(versionNumber) (\(buildNumber))")
                .font(.callout)
                .foregroundColor(.secondary)

            HStack(spacing: buttonSpacing) {
                Button(action: transitToPreview) {
                    Text("Done")
                }
                .buttonStyle(CapsuledButtonStyle(size: CGSize(width: buttonWidth, height: buttonHeight)))

                Button(action: quit) {
                    Text("Quit")
                }
                .buttonStyle(CapsuledButtonStyle(size: CGSize(width: buttonWidth, height: buttonHeight)))
            }
            .padding(buttonPadding)
        }
    }

    // MARK: - Funstions

    private func transitToPreview() {
        withAnimation(.easeInOut) {
            currentView = .preview
        }
    }

    private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Constants

    private let intervalPickerWidth: CGFloat = 300
    private let pickerPadding: CGFloat = 24
    private let buttonPadding: CGFloat = 12
    private let buttonSpacing: CGFloat = 24
    private let buttonWidth: CGFloat = 120
    private let buttonHeight: CGFloat = 40

    private let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(currentView: .constant(.preference))
            .frame(width: 400)
    }
}
