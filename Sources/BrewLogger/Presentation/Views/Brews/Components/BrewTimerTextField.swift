//
//  BrewTimerTextField.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import SwiftUI

struct BrewTimerTextField: View {
    @State private var isRunning: Bool = false
    @State private var time: Double = 0.0
    @State private var timerTask: Task<Void, Never>?
    @State private var startDate: Date = .now

    let placeholder: String
    let focus: FocusState<AddBrewView.Field?>.Binding
    let focusField: AddBrewView.Field

    @Binding var brewTime: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $brewTime)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .focused(focus, equals: focusField)
                .disabled(isRunning)

            Spacer()

            // Start / Stop
            Button {
                if isRunning { stopTimer() } else { startTimer() }
            } label: {
                Image(systemName: isRunning ? "stop.circle" : "play.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .tint(.cyan)
            }
            .buttonStyle(.borderless)
            .padding(.trailing)
            
            // Restart Timer
            Button {
                resetTimer()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .tint(.cyan)
            }
            .buttonStyle(.borderless)
        } //: HStack
        .onDisappear {
            stopTimer()
        }
    }
}

private extension BrewTimerTextField {
    func startTimer() {
        isRunning = true
        startDate = Date()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                time = Date().timeIntervalSince(startDate)
                brewTime = String(format: "%.1f", time)
            }
        }
    }

    func stopTimer() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        time = Date().timeIntervalSince(startDate)
        brewTime = String(format: "%.1f", time)
    }
    
    func resetTimer() {
        stopTimer()
        time = 0
        brewTime = ""
    }
    
    func updateBrewTime() {
        brewTime = String(format: "%.2f", time)
    }
}

#Preview {
    @Previewable @State var brewTime = ""
    @Previewable @FocusState var focus: AddBrewView.Field?
    BrewTimerTextField(placeholder: "Brew Time(s)", focus: $focus, focusField: .brewTime, brewTime: $brewTime)
}
