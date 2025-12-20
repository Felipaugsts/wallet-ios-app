//
//  FirestoreService.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 20/12/25.
//

import Foundation
import FirebaseFirestore

protocol DatabaseServiceProtocol {
    var debugMode: Bool { get set }

    func create(withDocumentId: String, collection: Collections, payload: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    func create(collection: Collections, payload: [String: Any], completion: @escaping (Result<String, Error>) -> Void)
    func deleteDocument(collection: Collections, documentId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateDocument(collection: Collections, documentId: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
    func fetch(collection: Collections, userId: String) async throws -> [String: Any]
}

class FirestoreService: DatabaseServiceProtocol {
    static let shared: DatabaseServiceProtocol = FirestoreService()
    
    var debugMode: Bool = false
    private let db = Firestore.firestore()
    
    func create(withDocumentId: String, collection: Collections, payload: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = db.collection(collection.rawValue).document(withDocumentId)

        docRef.setData(payload) { error in
            self.handleCompletion(error: error, operation: "create with documentId: \(withDocumentId)", updates: nil, completion: completion)
        }
    }
    
    func create(collection: Collections, payload: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        var documentReference: DocumentReference?
        
        documentReference = db.collection(collection.rawValue).addDocument(data: payload) { error in
            if let error = error {
                completion(.failure(error))
            } else if let documentId = documentReference?.documentID {
                completion(.success(documentId))
            } else {
                completion(.success(""))
            }
        }
    }

    func deleteDocument(collection: Collections, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection.rawValue)
            .document(documentId)
            .delete { [weak self] error in
                self?.handleCompletion(error: error, operation: "delete", updates: nil, completion: completion)
            }
    }
    
    // Método para atualizar um documento
    func updateDocument(collection: Collections, documentId: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection.rawValue)
            .document(documentId)
            .updateData(updates) { [weak self] error in
                self?.handleCompletion(error: error, operation: "update", updates: updates, completion: completion)
            }
    }
    
    func fetch(collection: Collections, userId: String) async throws -> [String: Any] {
        let snap = try await db.collection(collection.rawValue)
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        var combinedData: [String: Any] = [:]
        
        for document in snap.documents {
            let data = document.data()
            combinedData[document.documentID] = data
        }
        
        debugPrint("fetch results: \(String(describing: combinedData))")
        
        return combinedData
    }
    
    // Método auxiliar para lidar com as respostas das operações
    private func handleCompletion(error: Error?, operation: String, updates: [String: Any]?, completion: @escaping (Result<Void, Error>) -> Void) {
        if debugMode {
            displayDebuggerHelper()
        }
        
        if let error = error {
            debugPrint("\(operation.capitalized) failed: \(error.localizedDescription)")
            completion(.failure(error))
        } else {
            debugPrint("\(operation.capitalized) succeeded: \(String(describing: updates))")
            completion(.success(()))
        }
    }

    // MARK: - Private Methods
    
    private func displayDebuggerHelper() {
        print("Debug mode is on")
    }

    private func debugPrint(_ message: String) {
        if debugMode {
            print(message)
        }
    }
}

enum Collections {
    case expenses
    case incomes
    case recurring
    
    var rawValue: String {
        switch self {
        case .expenses:
            return "expenses"
        case .incomes:
            return "incomes"
        case .recurring:
            return "recurring"
        }
    }
}
