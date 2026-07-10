//
//  BrewTimerTextField.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import SwiftUI

struct BrewTimerTextField: View {
    @State private var viewModel = ViewModel()

    private let buttonSize: CGFloat = 28

    let placeholder: String
    let focus: FocusState<SaveBrewView.Field?>.Binding
    let focusField: SaveBrewView.Field

    @Binding var brewTime: String

    private var timerBinding: Binding<String> {
        Binding(
            get: { viewModel.time > 0 ? viewModel.formatted(viewModel.time) : brewTime },
            set: { brewTime = $0 }
        )
    }

    var body: some View {
        HStack {
            TextField(placeholder, text: timerBinding)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused(focus, equals: focusField)
                .disabled(viewModel.isRunning)

            Spacer()

            // Start / Pause
            Button {
                if viewModel.isRunning { viewModel.pause() } else { viewModel.start() }
            } label: {
                Image(systemName: viewModel.isRunning ? "pause.circle" : "play.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
                    .tint(BrandColors.accent)
            }
            .buttonStyle(.borderless)
            .padding(.trailing)

            // Reset Timer
            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
                    .tint(BrandColors.accent)
            }
            .buttonStyle(.borderless)
        } //: HStack
        .onChange(of: viewModel.brewTimeString) { _, newValue in
            brewTime = newValue
        }
        .onDisappear {
            viewModel.pause()
        }
    }
}

#Preview {
    @Previewable @State var brewTime = ""
    @Previewable @FocusState var focus: SaveBrewView.Field?
    BrewTimerTextField(
        placeholder: "Brew Time",
        focus: $focus,
        focusField: .brewTime,
        brewTime: $brewTime
    )
}
