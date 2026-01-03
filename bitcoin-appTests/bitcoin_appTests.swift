//
//  bitcoin_appTests.swift
//  bitcoin-appTests
//
//  Created by Felipe Augusto Silva on 11/10/25.
//

import XCTest
@testable import bitcoin_app
import Firebase

class HomeServiceTests: XCTestCase {
    
    var homeService: HomeService!
    var mockService: MockDatabaseService!
    
    // Variáveis para armazenar resultados esperados
    var expectedIncomeTotal: Double = 500.0
    var expectedExpenseTotal: Double = 200.0
    var expectedBalance: Double = 300.0
    
    override func setUp() {
        super.setUp()
        mockService = MockDatabaseService.shared
        homeService = HomeService(service: mockService)
    }
    
    override func tearDown() {
        homeService = nil
        mockService = nil
        super.tearDown()
    }
    
    // Teste para obter o resumo do usuário com sucesso
    func testGetUserOverview_Success() async throws {
        let passDate = Date.from(year: 2025, month: 11, day: 22)
        let currentDate = Date()
        let month = currentDate.getMonthAsInt()
        let year = currentDate.getYearAsInt()
        
        setupMockData(
            incomes: [
                createTransactionMock(type: .income, amount: "2000.0", month: month, year: year, isRecurring: 1, id: 1),
                createTransactionMock(type: .income, amount: "2000.0", month: 01, year: 2029, isRecurring: 1, id: 2),
                createTransactionMock(type: .income, amount: "2000.0", month: 11, year: 2025, isRecurring: 1, id: 3)
            ],
            expenses: [
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 1)
            ],
            recurring: [
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 1),
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 2)
            ]
        )
        
        let result = try await homeService.getUserOverview(month: month, year: year)
        
        XCTAssertEqual(result.incomeTotal, 2000.0)
        XCTAssertEqual(result.expenseTotal, 200.0)
        XCTAssertEqual(result.balance, 1800.0)
    }
    
    func testGetUserOverview_recurring() async throws {
        let futureDate = Date.from(year: 2030, month: 11, day: 22)
        let currentDate = Date()
        let month = currentDate.getMonthAsInt()
        let year = currentDate.getYearAsInt()
        
        setupMockData(
            incomes: [
                createTransactionMock(type: .income, amount: "2000.0", month: month, year: year, isRecurring: 1, id: 1)
            ],
            expenses: [
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 1)
            ],
            recurring: [
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 1),
                createTransactionMock(type: .expense, amount: "100.0", month: 11, year: 2030, isRecurring: 1, id: 2, date: futureDate)
            ]
        )
        
        let result = try await homeService.getUserOverview(month: month, year: year)
        
        XCTAssertEqual(result.incomeTotal, 2000.0)
        XCTAssertEqual(result.expenseTotal, 100.0)
        XCTAssertEqual(result.balance, 1900.0)
    }
    
    // Teste para criar uma transação com sucesso
    func testCreateTransaction_Success() {
        let data: [String: Any] = [
            "type": TransactionType.expense.rawValue,
            "name": "Novo Gasto",
            "description": "Descrição do gasto",
            "categoryId": "categoryId",
            "date": Date(),
            "amount": "100.0",
            "isRecurring": false,
            "recurrenceMonths": 1,
            "month": 12,
            "icon": "iconName",
            "year": 2025
        ]
        
        let expectation = self.expectation(description: "Transaction creation")
        
        homeService.createTransaction(data: data, collection: .expenses) { result in
            switch result {
            case .success(let documentId):
                XCTAssertNotNil(documentId)
            case .failure(let error):
                XCTFail("Expected success, but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetUserOverview_empty_previousMonth() async throws {
        let currentDate = Date()
        let month = currentDate.getMonthAsInt()
        let year = currentDate.getYearAsInt()
        
        setupMockData(
            incomes: [
                createTransactionMock(type: .income, amount: "2000.0", month: month, year: year, isRecurring: 1, id: 1),
                createTransactionMock(type: .income, amount: "2000.0", month: 01, year: 2029, isRecurring: 1, id: 2)
            ],
            expenses: [
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 1)
            ],
            recurring: [
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 1),
                createTransactionMock(type: .expense, amount: "100.0", month: month, year: year, isRecurring: 1, id: 2)
            ]
        )
        
        let result = try await homeService.getUserOverview(month: 12, year: 2025)
        
        XCTAssertEqual(result.incomeTotal, 0.0)
        XCTAssertEqual(result.expenseTotal, 0.0)
        XCTAssertEqual(result.balance, 0.0)
    }

    // Método para configurar dados de mock
    private func setupMockData(incomes: [[String: Any]], expenses: [[String: Any]], recurring: [[String: Any]]) {
        mockService.mockData[.incomes] = incomes
        mockService.mockData[.expenses] = expenses
        mockService.mockData[.recurring] = recurring
    }
    
    // Método para criar uma transação mock
    private func createTransactionMock(type: TransactionType, amount: String, month: Int, year: Int, isRecurring: Int = 0, id: Int? = nil, date: Date? = nil) -> [String: Any] {
        var transaction: [String: Any] = [
            "month": month,
            "year": year,
            "type": type.rawValue,
            "name": "Novo Gasto",
            "description": "Descrição do gasto",
            "categoryId": "credit_card",
            "date": Timestamp(date: date ?? Date()),
            "amount": amount,
            "isRecurring": isRecurring,
            "recurrenceMonths": 1,
            "icon": "iconName",
            "recurringEditable": true
        ]
        
        // Se um id for fornecido, adicione ao dicionário
        if let transactionId = id {
            transaction["id"] = transactionId
        }
        
        return transaction
    }
}

// Mock para o serviço de banco de dados
class MockDatabaseService: DatabaseServiceProtocol {
    static var shared = MockDatabaseService()
    var mockData: [Collections: [[String: Any]]] = [:]
    
    var debugMode: Bool = false
    var ids = ["1", "2", "3", "4", "5", "6"]
    var idToRepeat = ""
    
    func create(withDocumentId: String, collection: Collections, payload: [String : Any], completion: @escaping (Result<Void, Error>) -> Void) {
        // Simule o sucesso da criação
        completion(.success(()))
    }
    
    func create(collection: Collections, payload: [String : Any], completion: @escaping (Result<String, Error>) -> Void) {
        // Simule o sucesso da criação com um ID fictício
        completion(.success("newDocumentId"))
    }
    
    func deleteDocument(collection: Collections, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simule o sucesso da exclusão
        completion(.success(()))
    }
    
    func updateDocument(collection: Collections, documentId: String, updates: [String : Any], completion: @escaping (Result<Void, Error>) -> Void) {
        // Simule o sucesso da atualização
        completion(.success(()))
    }
    
    func fetch(collection: Collections, userId: String) async throws -> [String : Any] {
        // Simule a recuperação de dados
        return mockData[collection]?.reduce(into: [String: Any]()) { result, item in
            // Insira lógica para converter os itens em um dicionário apropriado
            let id = ids.first ?? "default"
            
            if let addedId = item["id"] as? Int {
                let strId = String(describing: addedId)
                result[strId] = item
                return
            }
            
            ids.removeAll(where: { $0 == id })
            result[id] = item
        } ?? [:]
    }
}
