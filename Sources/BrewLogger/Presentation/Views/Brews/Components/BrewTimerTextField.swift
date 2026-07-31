//
//  BrewTimerTextField.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import SwiftUI

struct BrewTimerTextField: View {
    @State private var viewModel = ViewModel()

    private let buttonSize: CGFloat = 32

    let placeholder: String
    let focus: FocusState<SaveBrewView.Field?>.Binding
    let focusField: SaveBrewView.Field

    @Binding var brewTime: String
    @Binding var stoppedAt: Date?

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
            
            // Reset Timer
            if viewModel.showResetButton {
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
                .padding(.trailing, 24)
                .animation(.easeInOut, value: viewModel.showResetButton)
            }

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
        } //: HStack
        .onChange(of: viewModel.brewTimeString) { _, newValue in
            brewTime = newValue
        }
        .onChange(of: viewModel.stoppedAt) { _, newValue in
            stoppedAt = newValue
        }
        .onDisappear {
            viewModel.pause()
        }
    }
}

#Preview {
    @Previewable @State var brewTime = ""
    @Previewable @State var stoppedAt: Date?
    @Previewable @FocusState var focus: SaveBrewView.Field?
    BrewTimerTextField(
        placeholder: "Brew Time",
        focus: $focus,
        focusField: .brewTime,
        brewTime: $brewTime,
        stoppedAt: $stoppedAt
    )
}
