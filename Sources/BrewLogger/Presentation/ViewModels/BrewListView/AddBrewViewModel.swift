//
//  AddBrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import Foundation
import BrewLoggerDomain

@Observable
final class AddBrewViewModel {
    var newBrew = NewBrew()

    // String-backed inputs since TextField requires String bindings
    var doseInput: String = ""
    var yieldInput: String = ""
    var brewTimeInput: String = ""
    var ratingInput: String = ""
    
    var canSave: Bool { true }
    
}

extension AddBrewViewModel {
    // Allow user to fill in components of a new brew
    struct NewBrew {
        var coffee: Coffee? = nil
        var dose: Double? = nil
        var yield: Double? = nil
        var temperature: Double? = nil
        var brewTime: TimeInterval? = nil
        var method: BrewMethod? = nil
        var rating: Double? = nil
        var notes: String? = nil
    }
}
