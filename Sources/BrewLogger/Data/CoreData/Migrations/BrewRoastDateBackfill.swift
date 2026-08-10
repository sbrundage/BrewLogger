//
//  BrewRoastDateBackfill.swift
//  BrewLogger
//

import CoreData

public enum BrewRoastDateBackfill {
    private static let key = "didBackfillBrewRoastDates_v1"

    public static func runIfNeeded(in context: NSManagedObjectContext) {
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        do {
            try run(in: context)
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            // Leave the flag unset so it retries next launch.
        }
    }

    // One-time: freeze each nil-roastDate brew from its coffee, so later roast-date edits can't rewrite old brews.
    static func run(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<BrewModel>(entityName: "BrewModel")
        request.predicate = NSPredicate(format: "roastDate == nil")
        let brews = try context.fetch(request)
        for brew in brews where brew.coffee?.roastDate != nil {
            brew.roastDate = brew.coffee?.roastDate
        }
        try context.save()
    }
}
