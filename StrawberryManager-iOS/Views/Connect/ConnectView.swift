// ConnectView.swift
// Initial connection screen

import SwiftUI

struct ConnectView: View {
    @EnvironmentObject var connectionViewModel: ConnectionViewModel
    @State private var password = ""
    @State private var showPasswordPrompt = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo placeholder
                Image(systemName: "server.rack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.tint)
                
                Text("Strawberry Manager")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Connection form
                VStack(spacing: 16) {
                    TextField("Server Address", text: $connectionViewModel.serverAddress)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    Button {
                        connectionViewModel.connect()
                    } label: {
                        if case .connecting = connectionViewModel.state {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Connect")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(connectionViewModel.serverAddress.isEmpty)
                    
                    // Error message
                    if let errorMessage = connectionViewModel.state.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: Binding(
                get: { connectionViewModel.state == .needsAuth },
                set: { if !$0 { password = "" } }
            )) {
                PasswordPromptView(password: $password) {
                    connectionViewModel.login(password: password)
                }
            }
        }
    }
}

struct PasswordPromptView: View {
    @Binding var password: String
    let onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Password", text: $password)
                        .onSubmit(onSubmit)
                } header: {
                    Text("Authentication Required")
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Login", action: onSubmit)
                        .disabled(password.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ConnectView()
        .environmentObject(ConnectionViewModel())
}
