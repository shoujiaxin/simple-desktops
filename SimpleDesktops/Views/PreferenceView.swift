//
//  PreferenceView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct PreferenceView: View {
    @Binding var currentView: PopoverView.ViewState

    @Binding private var isAutoChangeOn: Bool
    @Binding private var selectedInterval: ChangeInterval

    @ObservedObject private var preferences: Preferences

    init(currentView: Binding<PopoverView.ViewState>, preferences: Preferences) {
        _currentView = currentView

        _preferences = ObservedObject(wrappedValue: preferences)

        _isAutoChangeOn = .init(get: {
            preferences.autoChange
        }, set: { isEnable in
            preferences.autoChange = isEnable
        })

        _selectedInterval = .init(get: {
            preferences.changeInterval
        }, set: { selected in
            preferences.changeInterval = selected
        })
    }

    var body: some View {
        VStack {
            Toggle(isOn: $isAutoChangeOn) {
                Picker("Change picture: ", selection: $selectedInterval) {
                    ForEach(preferences.eventChangeIntervals) { interval in
                        Text(interval.description)
                            .tag(interval)
                    }

                    Divider()

                    ForEach(preferences.timeChangeIntervals) { interval in
                        Text(interval.description)
                            .tag(interval)
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
                Button(action: {
                    withAnimation(.easeInOut) {
                        currentView = .preview
                    }
                }) {
                    Text("Done")
                }
                .buttonStyle(CapsuledButtonStyle(size: CGSize(width: 120, height: 40)))

                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    Text("Quit")
                }
                .buttonStyle(CapsuledButtonStyle(size: CGSize(width: 120, height: 40)))
            }
            .padding(buttonPadding)
        }
    }

    // MARK: - Draw Constants

    private let intervalPickerWidth: CGFloat = 300
    private let pickerPadding: CGFloat = 24
    private let buttonPadding: CGFloat = 12
    private let buttonSpacing: CGFloat = 24

    private let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(currentView: .constant(.preference), preferences: Preferences())
            .frame(width: 400)
    }
}
