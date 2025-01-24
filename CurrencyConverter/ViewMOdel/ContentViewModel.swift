//
//  ContentViewModel.swift
//  CurrencyConverter
//
//  Created by Weerawut Chaiyasomboon on 24/1/2568 BE.
//

import Foundation

//@MainActor same as
//DispatchQueue.main.async {
//
//}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var baseAmount: Double = 1.0
    @Published var convertedAmount: Double = 1.0
    @Published var baseCurrency: CurrencyChoice = .Usa
    @Published var convertedCurrency: CurrencyChoice = .Euro
    @Published var rates: [String:Double] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter
    }
    
    var conversionRate: Double {
        if let baseExchangeRate = self.rates[self.baseCurrency.rawValue],
           let convertExchangeRate = self.rates[self.convertedCurrency.rawValue] {
            return convertExchangeRate / baseExchangeRate
        }
        return 1
    }
    
    func fetchRates() async {
        isLoading = true
        
        let endPoint = "https://openexchangerates.org/api/latest.json?app_id=\(apiId)"
        guard let url = URL(string: endPoint) else {
            errorMessage = "Could not fetch rates"
            print("URL Error")
            return
        }
        let request = URLRequest(url: url)
        
        do {
            let (data,response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Could not fetch rates"
                print("Response Error")
                return
            }
            
            let decoder = JSONDecoder()
            let wrapRates = try decoder.decode(WrapRates.self, from: data)
            self.rates = wrapRates.rates
        } catch {
            errorMessage = "Could not fetch rates"
            print("Error fetching: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func convert() {
        if let baseExchangeRate = self.rates[self.baseCurrency.rawValue],
           let convertExchangeRate = self.rates[self.convertedCurrency.rawValue] {
            self.convertedAmount = (convertExchangeRate/baseExchangeRate) * self.baseAmount
        }
    }
}
