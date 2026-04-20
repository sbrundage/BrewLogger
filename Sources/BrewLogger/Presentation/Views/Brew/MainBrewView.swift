//
//  MainBrewView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 2/22/26.
//

import SwiftUI
import CoreData
import CoreLogger
import BrewLoggerApplication
import BrewLoggerDomain

// TODO: Remove this import, Presentation should not depend on Data
import BrewLoggerData

public struct MainBrewView: View {
//    @State private var brewViewModel = BrewViewModel()
    // TODO: Stub for preview?
    @State private var connectionManager = BleScaleConnectionManager()
    
    let persistenceController: PersistenceController
     
    public init(persistenceController: PersistenceController = .brewLogger) {
        self.persistenceController = persistenceController
    }
    
    public var body: some View {
        NavigationStack {
            BrewListView()
        } //: VStack
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(connectionManager)
        .onAppear { connectionManager.startConnecting() }
    }
}

#Preview {
    MainBrewView(persistenceController: .stubbedPreviewCoffees)
}
