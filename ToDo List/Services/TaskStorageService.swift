import Foundation
import CoreData

final class TaskStorageService {
    static let shared = TaskStorageService()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo_List")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData load error: \(error)") }
        }
        return container
    }()
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {}

    func fetchTasks(search: String? = nil) -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        if let search = search, !search.isEmpty {
            request.predicate = NSPredicate(format: "todo CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", search, search)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toTask() }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    func addTask(_ task: Task) {
        let entity = TaskEntity(context: context)
        entity.id = Int64(task.id)
        entity.todo = task.todo
        entity.completed = task.completed
        entity.userId = Int64(task.userId)
        entity.date = task.date
        entity.taskDescription = task.description
        saveContext()
    }

    func updateTask(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        do {
            if let entity = try context.fetch(request).first {
                entity.todo = task.todo
                entity.completed = task.completed
                entity.userId = Int64(task.userId)
                entity.date = task.date
                entity.taskDescription = task.description
                saveContext()
            }
        } catch { print("Update error: \(error)") }
    }

    func deleteTask(id: Int) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                saveContext()
            }
        } catch { print("Delete error: \(error)") }
    }

    func saveContext() {
        if context.hasChanges {
            do { try context.save() }
            catch { print("Save error: \(error)") }
        }
    }

    func generateNewId() -> Int {
        let tasks = fetchTasks()
        return (tasks.map { $0.id }.max() ?? 0) + 1
    }
}

extension TaskEntity {
    func toTask() -> Task {
        Task(
            id: Int(self.id),
            todo: self.todo ?? "",
            completed: self.completed,
            userId: Int(self.userId),
            date: self.date,
            description: self.taskDescription
        )
    }
}
