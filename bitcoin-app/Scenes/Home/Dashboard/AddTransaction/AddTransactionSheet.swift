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
    
    @StateObject private var viewModel = AddTransactionViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                // Seletor de Tipo (Gasto vs Receita)
                Section {
                    Picker("Tipo", selection: $viewModel.transactionType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Campo de Valor
                Section {
                    HStack {
                        Text(Self.currencyFormatter.currencySymbol)
                            .font(.largeTitle)
                        
                        TextField("R$ 0.00", text: $viewModel.transaction.valueBRL)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .foregroundColor(viewModel.currencyColor)
                }
                
                // Detalhes Principais
                Section(header: Text("Detalhes")) {
                    TextField("Nome (ex: Conta de Luz)", text: $viewModel.transaction.name)
                    TextField("Descrição (opcional)", text: $viewModel.transaction.description)
                }
                
                // Categorias e Data
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
                
                // Recorrência e Lembretes
                Section(header: Text("Opções Adicionais")) {
                    Toggle("É uma transação recorrente?", isOn: $viewModel.isRecurring.animation())
                    
                    if viewModel.isRecurring {
                        Stepper("Repetir por \(viewModel.recurrenceMonths) meses", value: $viewModel.recurrenceMonths, in: 2...60)
                    }
                    
                    if viewModel.transactionType == .expense {
                        Toggle("Lembrar-me do vencimento", isOn: $viewModel.shouldRemind.animation())
                        
                        if viewModel.shouldRemind {
                            Stepper("Lembrar \(viewModel.reminderDays) dias antes", value: $viewModel.reminderDays, in: 1...30)
                        }
                    }
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
