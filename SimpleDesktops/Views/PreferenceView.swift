//
//  PreferenceView.swift
//  Simple Desktops
//
//  Created by Jiaxin Shou on 2021/1/15.
//

import SwiftUI

struct PreferenceView: View {
    @Binding var currentView: PopoverView.ViewState

    @State private var isAutoChangeOn: Bool = true
    @State private var selectedInterval: Int = 1

    var body: some View {
        VStack {
            Toggle(isOn: $isAutoChangeOn) {
                Picker(selection: $selectedInterval, label: Text("Change picture: ")) {
                    /*@START_MENU_TOKEN@*/Text("1").tag(1)/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("2").tag(2)/*@END_MENU_TOKEN@*/
                }
                .frame(width: intervalPickerWidth)
                .disabled(!isAutoChangeOn)
            }
            .padding()

            Spacer()

            CapsuleButton("Done") {
                withAnimation(.easeInOut) {
                    currentView = .preview
                }
            }
            .padding(imageButtonPadding)
        }
    }

    // MARK: - Draw Constants

    private let intervalPickerWidth: CGFloat = 240
    private let imageButtonPadding: CGFloat = 12
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(currentView: .constant(.preference))
            .previewLayout(.fixed(width: 400, height: 358))
    }
}
