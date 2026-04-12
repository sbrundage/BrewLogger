//
//  BrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/9/26.
//

import Foundation
import BrewLoggerDomain
import BrewLoggerData
import CoreData

@MainActor @Observable
public class BrewViewModel {
//    private let repository: BrewRepository
    
    private(set) var brewLogs: [Brew] = []
    
    public init(
//        context: NSManagedObjectContext = PersistenceController.brewLogger.container.viewContext
    ) {
//        self.repository = CoreDataBrewRepository(
//            store: CoreDataBrewStore(context: context)
//        )
    }
}

