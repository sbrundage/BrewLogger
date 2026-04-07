//
//  CoreDataStore.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import CoreData

public final class CoreDataStore<Model: NSManagedObject> {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = []
    ) throws -> [Model] {
        let request = NSFetchRequest<Model>(entityName: String(describing: Model.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return try context.fetch(request)
    }
    
    func fetchOne(id: String) throws -> Model? {
        let request = NSFetchRequest<Model>(entityName: String(describing: Model.self))
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first
    }

    func insert(_ configure: (Model) -> Void) throws {
        let model = Model(context: context)
        configure(model)
        try context.save()
    }

    func delete(id: String) throws {
        let request = NSFetchRequest<Model>(entityName: String(describing: Model.self))
        request.predicate = NSPredicate(format: "id == %@", id)
        guard let model = try context.fetch(request).first else { return }
        context.delete(model)
        try context.save()
    }

    func update(id: String, configure: (Model) -> Void) throws {
        let request = NSFetchRequest<Model>(entityName: String(describing: Model.self))
        request.predicate = NSPredicate(format: "id == %@", id)
        guard let model = try context.fetch(request).first else { return }
        configure(model)
        try context.save()
    }
}
