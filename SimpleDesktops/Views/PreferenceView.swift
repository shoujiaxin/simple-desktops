//
//  PreferenceView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct PreferenceView: View {
    @ObservedObject var preferences: Preferences

    @Binding var currentView: PopoverView.ViewState

    @Binding private var isAutoChangeOn: Bool
    @Binding private var selectedInterval: Int

    init(preferences: Preferences, currentView: Binding<PopoverView.ViewState>) {
        _preferences = ObservedObject(initialValue: preferences)

        _currentView = currentView

        _isAutoChangeOn = .init(get: {
            preferences.autoChange
        }, set: { isEnable in
            preferences.setAutoChange(isEnable)
        })

        _selectedInterval = .init(get: {
            preferences.changeInterval
        }, set: { selectedTag in
            preferences.selectChangeInterval(at: selectedTag)
        })
    }

    var body: some View {
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""

        VStack {
            Toggle(isOn: $isAutoChangeOn) {
                Picker(selection: $selectedInterval, label: Text("Change picture: ")) {
                    ForEach(preferences.allChangeIntervals) { interval in
                        Text(interval.description)
                            .tag(interval.rawValue)
                    }
                }
                .frame(width: intervalPickerWidth)
                .disabled(!isAutoChangeOn)
            }
            .padding(.vertical, pickerPadding)

            Text("Version \(versionNumber) (\(buildNumber))")
                .font(.callout)
                .foregroundColor(.secondary)

            HStack(spacing: buttonSpacing) {
                CapsuleButton("Done", size: CGSize(width: 120, height: 40)) {
                    withAnimation(.easeInOut) {
                        currentView = .preview
                    }
                }

                CapsuleButton("Quit", size: CGSize(width: 120, height: 40)) {
                    NSApp.terminate(nil)
                }
            }
            .padding(buttonPadding)
        }
    }

    // MARK: - Draw Constants

    private let intervalPickerWidth: CGFloat = 240
    private let pickerPadding: CGFloat = 24
    private let buttonPadding: CGFloat = 12
    private let buttonSpacing: CGFloat = 24
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(preferences: Preferences(), currentView: .constant(.preference))
            .frame(width: 400)
    }
}
