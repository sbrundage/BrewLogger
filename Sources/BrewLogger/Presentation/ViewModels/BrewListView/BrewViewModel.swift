//
//  BrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/9/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
class BrewViewModel {
    private let fetchBrews: FetchAllBrewsUseCase
    private let deleteBrew: DeleteBrewUseCase
    
    private(set) var brews: [Brew] = []
    private(set) var selectedSortOption: BrewSortOption = .newest {
        didSet { sortBrews() }
    }
    
    var searchText: String = ""
    var showAddBrewSheet: Bool = false
    
    init(
        repository: BrewRepository = RepositoryFactory.dev.brew
    ) {
        self.fetchBrews = FetchAllBrewsUseCase(repository: repository)
        self.deleteBrew = DeleteBrewUseCase(repository: repository)
    }
    
    func fetchAllBrews() {
        do {
            self.brews = try fetchBrews.execute(coffeeId: nil)
        } catch {
            // TODO: Handle error
            print("Failed to fetch brews: \(error)")
        }
    }
    
    func delete(_ brew: Brew) {
        do {
            try deleteBrew.execute(brewId: brew.id)
            brews.removeAll { $0.id == brew.id }
        } catch {
            // TODO: Handle error
            print("Failed to delete brew: \(error)")
        }
    }
    
    func updateSelectedSortOption(_ option: BrewSortOption) {
        self.selectedSortOption = option
    }
}

private extension BrewViewModel {
    func sortBrews() {
        switch selectedSortOption {
        case .highestRated:
            self.brews = brews.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
        case .newest:
            self.brews = brews.sorted { $0.date > $1.date }
        }
    }
}

