import Foundation
import CouchbaseLiteSwift
import Combine

class DatabaseManager {
    static let shared = DatabaseManager()
    var replicator: Replicator?
    var database: Database?
    var collection: Collection?
    var lastQuery: Query?
    var lastQueryToken: ListenerToken?
    private let queryUpdatesSubject = CurrentValueSubject<[Note], Never>([])
    var notesPublisher: AnyPublisher<[Note], Never> { queryUpdatesSubject.eraseToAnyPublisher() }

    private init() {
        Database.log.console.level = .info
        initializeDatabase()
    }

    private func initializeDatabase() {
        do {
            database = try Database(name: "notes-assignment")
            
            collection = try database?.createCollection(name: "_default", scope: "_default")
            
            let indexConfig = FullTextIndexConfiguration(["title"], language: "en")
            try collection?.createIndex(withName: "titleIndex", config: indexConfig)
            try getStartedWithReplication(replication: true)
            queryElements()
        } catch {
            fatalError("Error initializing database: \(error)")
        }
    }

    private func startListeningForChanges(query: Query) {
        lastQuery = query
        lastQueryToken = query.addChangeListener { [weak self] change in
            guard let self = self, let results = change.results else { 
                return 
            }
            var arr: [Note] = []
            for result in results {
                let dict = result.toDictionary()
                
                if let noteData = dict["_default"] as? [String: Any],
                   let title = noteData["title"] as? String,
                   let content = noteData["content"] as? String,
                   let typeField = noteData["type"] as? String,
                   typeField == "note" {
                    
                    let noteId: Int
                    if let id = noteData["id"] as? Int {
                        noteId = id
                    } else if let id = noteData["id"] as? NSNumber {
                        noteId = id.intValue
                    } else {
                        continue
                    }
                    
                    let timestamp: Double
                    if let ts = noteData["createdAt"] as? Double {
                        timestamp = ts
                    } else if let tsString = noteData["createdAt"] as? String,
                              let ts = Double(tsString) {
                        timestamp = ts
                    } else {
                        continue
                    }
                    
                    arr.append(
                        Note(
                            id: noteId,
                            title: title,
                            content: content,
                            createdAt: Date(timeIntervalSince1970: timestamp)
                        )
                    )
                }
            }
            
            self.queryUpdatesSubject.send(arr)
        }
    }

    private func stopListeningForChanges() {
        if let token = lastQueryToken {
            lastQuery?.removeChangeListener(withToken: token)
        }
    }

    func queryElements(descending: Bool = false, textSearch: String? = nil) {
        guard let db = database else {
            return
        }
        stopListeningForChanges()
        let parameters = Parameters()
        parameters.setString("note", forName: "type")
        let orderDirection = descending ? "DESC" : "ASC"

        var sql = "SELECT * FROM _default._default WHERE type = $type"
        if let search = textSearch {
            parameters.setString("\(search)*", forName: "match")
            sql += " AND MATCH(titleIndex, $match)"
        }
        sql += " ORDER BY createdAt \(orderDirection)"

        do {
            let query = try db.createQuery(sql)
            query.parameters = parameters

            let results = try query.execute()

            startListeningForChanges(query: query)
        } catch {
            print("eror quering notes")
        }
    }

    func addNewElement(_ note: Note) {
        guard let coll = try? database?.collection(name: "_default", scope: "_default") else {
            return
        }
        do {
            let doc = MutableDocument()
            
            doc.setString("note", forKey: "type")
            doc.setInt(note.id, forKey: "id")
            doc.setString(note.title, forKey: "title")
            doc.setString(note.content, forKey: "content")
            doc.setDouble(note.createdAt.timeIntervalSince1970, forKey: "createdAt")

            try coll.save(document: doc)
        } catch {
            ErrorManager.shared.showError(error: ErrorModel(title: "Save Error", message: "Failed to save note: \(error.localizedDescription)", closable: true))
        }
    }

    func updateExistingElement(_ note: Note) {
        guard let db = database,
              let coll = try? db.collection(name: "_default", scope: "_default") else { return }
        do {
            let query = try db.createQuery("SELECT META().id FROM _default._default WHERE type = 'note' AND id = \(note.id)")
            let results = try query.execute()
            for res in results {
                let props = res.toDictionary()
                if let docID = props["id"] as? String,
                   let mutableDoc = try coll.document(id: docID)?.toMutable() {
                
                    mutableDoc.setString("note", forKey: "type")
                    mutableDoc.setInt(note.id, forKey: "id")
                    mutableDoc.setString(note.title, forKey: "title")
                    mutableDoc.setString(note.content, forKey: "content")
                    mutableDoc.setDouble(note.createdAt.timeIntervalSince1970, forKey: "createdAt")
                    try coll.save(document: mutableDoc)
                }
            }
        } catch {
            ErrorManager.shared.showError(error: ErrorModel(title: "Update Error", message: "Failed to update note: \(error.localizedDescription)", closable: true))
        }
    }

    func deleteElement(_ note: Note) {
        guard let db = database,
              let coll = try? db.collection(name: "_default", scope: "_default") else { return }
        do {
            let query = try db.createQuery("SELECT META().id FROM _default._default WHERE type = 'note' AND id = \(note.id)")
            let results = try query.execute()
            for res in results {
                let props = res.toDictionary()
                if let docID = props["id"] as? String,
                   let doc = try? coll.document(id: docID) {
                    try coll.delete(document: doc)
                }
            }
        } catch {
            print("note deleting error")
        }
    }

    func deleteElementWithName(_ name: String) {
        guard let db = database,
              let coll = try? db.collection(name: "_default", scope: "_default") else { return }
        do {
            let query = try db.createQuery("SELECT META().id FROM _default._default WHERE type = 'note' AND title = $title")
            query.parameters?.setString(name, forName: "title")
            let results = try query.execute()
            for res in results {
                let props = res.toDictionary()
                if let docID = props["id"] as? String,
                   let doc = try? coll.document(id: docID) {
                    try coll.delete(document: doc)
                }
            }
        } catch {
            print("note deleting with name error")
        }
    }

    private func getStartedWithReplication(replication: Bool) throws {
        guard let config = ConfigurationManager.shared.getConfiguration() else {
            ErrorManager.shared.showError(error: ConfigurationErrors.configError)
            return
        }
        if replication {
            guard let coll = collection else { 
                return 
            }
            
            let target = URLEndpoint(url: config.capellaEndpointURL)
            var replConfig = ReplicatorConfiguration(target: target)
            
            replConfig.replicatorType = .pushAndPull
            replConfig.continuous = true
            
            
            replConfig.heartbeat = 60
            replConfig.maxAttempts = 15
            replConfig.maxAttemptWaitTime = 180
            
            replConfig.authenticator = BasicAuthenticator(username: config.username, password: config.password)
            
            replConfig.addCollection(coll)
            
            replicator = Replicator(config: replConfig)
            
            replicator?.addChangeListener { [weak self] change in
                if let error = change.status.error {
                   
                    if let nsError = error as NSError? {
                        if nsError.userInfo[NSUnderlyingErrorKey] is NSError {
                            print("error in replicator")
                        }
                    }
                    
                    ErrorManager.shared.showError(error: ErrorModel(
                        title: "Sync Error", 
                        message: "Failed to sync with Capella: \(error.localizedDescription)", 
                        closable: true
                    ))
                }
            }
            
            replicator?.start()
        }
    }
}
