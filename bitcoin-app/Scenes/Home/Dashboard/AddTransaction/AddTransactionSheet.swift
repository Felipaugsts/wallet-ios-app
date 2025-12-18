//
//  AddTransactionSheet.swift
//  bitcoin-app
//
//  Created by Felipe Augusto Silva on 13/12/25.
//

import SwiftUI

struct AddTransactionSheet: View {
    var editTransaction: ExpenseModel?
    var preSelectedValueType: TransactionType
    var preSelectedCategoryId: String
    weak var delegate: TransactionDelegate?
    
    @StateObject private var viewModel: AddTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(editTransaction: ExpenseModel?,
         preSelectedValueType: TransactionType,
         preSelectedCategoryId: String,
         delegate: TransactionDelegate?) {
        self.editTransaction = editTransaction
        self.preSelectedValueType = preSelectedValueType
        self.preSelectedCategoryId = preSelectedCategoryId
        self.delegate = delegate
        
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(transactionType: preSelectedValueType))
    }
    
    private static let currencyFormatter: NumberFormatter = {
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.locale = Locale(identifier: "pt_BR")
          formatter.minimumFractionDigits = 2
          formatter.maximumFractionDigits = 2
          return formatter
      }()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text(Self.currencyFormatter.currencySymbol)
                            .font(.largeTitle)
                        
                        TextField("R$ 0.00", text: $viewModel.transaction.valueBRL)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .onSubmit {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                    }
                    .foregroundColor(viewModel.currencyColor)
                }
                
                Section(header: Text("Detalhes")) {
                    TextField("Nome (ex: Conta de Luz)", text: $viewModel.transaction.name)
                    TextField("Descrição (opcional)", text: $viewModel.transaction.description)
                }
                
                Section {
                    Picker("Categoria", selection: $viewModel.transaction.selectedCategoryId) {
                        ForEach(viewModel.categories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }.tag(category.id)
                        }
                    }
                    
                    DatePicker(
                        viewModel.transactionType == .expense ? "Vencimento" : "Recebimento",
                        selection: $viewModel.transaction.dueDate,
                        displayedComponents: .date
                    )
                }
                
                Section(header: Text("Opções Adicionais")) {
                    Toggle("É uma transação recorrente?", isOn: $viewModel.isRecurring.animation())
                }
            }
            .shimmer(when: $viewModel.isLoading)
            .navigationTitle("Nova Transação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        viewModel.saveTransaction()
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .task(id: preSelectedValueType) {
                viewModel.transactionType = preSelectedValueType
                viewModel.populateTransaction(transaction: editTransaction)
                viewModel.isLoading = false
            }
            .onChange(of: viewModel.shouldUpdateTransactions) { _, _ in
                delegate?.updateTransactions(transaction: viewModel.transaction)
                self.dismiss()
            }
            .springLoadingBehavior(.automatic)
        }
        .tint(viewModel.currencyColor)
    }
}
