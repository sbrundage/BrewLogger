//
//  BrewDetailsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/13/26.
//

import SwiftUI
import BrewLoggerDomain
import BrewLoggerApplication

struct BrewDetailsView: View {
    @State private var viewModel: ViewModel
    @State private var showEditSheet = false
        
    init(brew: Brew) {
        self.viewModel = ViewModel(brew: brew)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                brewInfo
                
                if let roastInfo = viewModel.brew.coffee.roastInfo {
                    roastInfoView(roast: roastInfo)
                }
                
                if let notes = viewModel.brew.notes {
                    VStack(alignment: .leading) {
                        Text("Notes:")
                            .fontWeight(.semibold)
                        Text(notes)
                    } //: VStack
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } //: VStack
            .padding(.horizontal)
        }
        .navigationTitle(viewModel.brew.coffee.name)
        .scrollIndicators(.hidden)
        .navigationDestination(isPresented: $showEditSheet, destination: {
            SaveBrewView(brewToEdit: viewModel.brew) {
                viewModel.refetchBrew()
            }
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
    }
    
    private var brewInfo: some View {
        VStack(alignment: .leading) {
            Text("Brew Info")
                .font(.headline)
            
            StatRow(stats: [
                .init(label: "Grind Size", value: viewModel.brew.grindSize.tens),
                .init(label: "Time", value: "\(viewModel.brew.brewTime.tens)s"),
                .init(label: "Yield", value: "\(viewModel.brew.yield.tens)  g")
            ])
            
            let stats: [StatRow.Stat] = [
                viewModel.brew.rating.map { .init(label: "Rating", value: $0.tens) },
                viewModel.brew.brewTemp.map { .init(label: "Temp", value: "\($0)") },
                .init(label: "Method", value: viewModel.brew.method.title)
            ].compactMap { $0 }
            
            StatRow(stats: stats)
        } //: VStack
    }
    
    private func roastInfoView(roast: RoastInfo) -> some View {
        let stats: [StatRow.Stat] = [
            roast.date.map { .init(label: "Roast Date", value: $0.shortFormatted) },
            roast.roaster.map { .init(label: "Roaster", value: $0) },
            roast.roastLevel.map { .init(label: "Roast Level", value: $0.title) }
        ].compactMap { $0 }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Roast Info")
                .font(.headline)

            StatRow(stats: stats)
        }
    }
}

extension BrewDetailsView {
    @MainActor @Observable
    final class ViewModel {
        private let fetchBrew: FetchBrewUseCase
        
        private(set) var brew: Brew
        
        init(
            repository: BrewRepository = RepositoryFactory.dev.brew,
            brew: Brew
        ) {
            self.fetchBrew = FetchBrewUseCase(repository: repository)
            self.brew = brew
        }
        
        func refetchBrew() {
            do {
                guard let updatedBrew = try fetchBrew.execute(brewId: brew.id) else {
                    // TODO: Handle error
                    return
                }
                self.brew = updatedBrew
            } catch {
                // TODO: Handle error
            }
        }
    }
}

#Preview {
    NavigationStack {
        BrewDetailsView(brew: .preview)
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}
