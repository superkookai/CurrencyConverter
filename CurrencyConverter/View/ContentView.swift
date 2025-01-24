//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Weerawut Chaiyasomboon on 24/1/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ContentViewModel()
    @FocusState private var baseAmountIsFocused: Bool
    @FocusState private var convertedAmountIsFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text(vm.errorMessage)
                        .foregroundStyle(.red)
                        .font(.system(size:18,weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                
                Text("Amount")
                    .font(.system(size: 15))
                TextField("", value: $vm.baseAmount, formatter: vm.numberFormatter)
                    .focused($baseAmountIsFocused)
                    .onSubmit {
                        vm.convert()
                        baseAmountIsFocused = false
                        convertedAmountIsFocused = false
                    }
                    .font(.system(size: 18,weight: .semibold))
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                    .overlay(alignment: .trailing) {
                        HStack {
                            vm.baseCurrency.image()
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(.circle)
                            
                            Menu {
                                ForEach(CurrencyChoice.allCases) { currencyChoice in
                                    Button {
                                        vm.baseCurrency = currencyChoice
                                        vm.convert()
                                    } label: {
                                        Text(currencyChoice.fetchMenuName())
                                    }
                                    
                                }
                            } label: {
                                Text(vm.baseCurrency.rawValue)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16,weight: .bold))
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16,weight: .bold))
                            }
                            
                        }
                        .padding(.trailing)
                    }
                
                HStack(alignment: .center) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 20,weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                Text("Convert To")
                    .font(.system(size: 15))
                TextField("", value: $vm.convertedAmount, formatter: vm.numberFormatter)
                    .focused($convertedAmountIsFocused)
                    .font(.system(size: 18,weight: .semibold))
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.clear)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                    .overlay(alignment: .trailing) {
                        HStack {
                            vm.convertedCurrency.image()
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(.circle)
                            
                            Menu {
                                ForEach(CurrencyChoice.allCases) { currencyChoice in
                                    Button {
                                        vm.convertedCurrency = currencyChoice
                                        vm.convert()
                                    } label: {
                                        Text(currencyChoice.fetchMenuName())
                                    }
                                    
                                }
                            } label: {
                                Text(vm.convertedCurrency.rawValue)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16,weight: .bold))
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.black)
                                    .font(.system(size: 16,weight: .bold))
                            }
                            
                        }
                        .padding(.trailing)
                    }
                
                HStack(alignment: .center) {
                    Text("1.00000 \(vm.baseCurrency.rawValue) = \(vm.conversionRate) \(vm.convertedCurrency.rawValue)")
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.top,25)
            }
            .padding()
            .task {
                await vm.fetchRates()
            }
            .onTapGesture {
                vm.convert()
                baseAmountIsFocused = false
                convertedAmountIsFocused = false
            }
            
            
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .tint(.white)
                        .controlSize(.extraLarge)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
