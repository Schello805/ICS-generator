import SwiftUI
import UniformTypeIdentifiers
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var viewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("defaultAlert") private var defaultAlert: String = ICSEvent.AlertTime.fifteenMinutes.rawValue
    @State private var showingResetAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Standard-Einstellungen")) {
                Picker("Standard-Erinnerung", selection: Binding(
                    get: { ICSEvent.AlertTime(rawValue: defaultAlert) ?? .fifteenMinutes },
                    set: { defaultAlert = $0.rawValue }
                )) {
                    ForEach(ICSEvent.AlertTime.allCases, id: \.self) { alertTime in
                        Text(alertTimeString(alertTime))
                            .tag(alertTime)
                    }
                }
            }
            
            Section {
                NavigationLink {
                    ICSValidatorView()
                } label: {
                    Label("ICS Validator", systemImage: "checkmark.shield")
                }
                
                NavigationLink {
                    ICSImportView(viewModel: viewModel)
                } label: {
                    Label("ICS importieren", systemImage: "square.and.arrow.down")
                }
            } header: {
                Text("Tools")
            }
            
            Section(header: Text("Daten")) {
                Button(role: .destructive, action: {
                    showingResetAlert = true
                }) {
                    Label("Alle Termine löschen", systemImage: "trash")
                }
            }
            
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Label("Über", systemImage: "info.circle")
                }
                
                Link(destination: URL(string: "https://github.com/Schello805/ICS-Generator")!) {
                    HStack {
                        Label("GitHub", systemImage: "link")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "mailto:info@schellenberger.biz")!) {
                    HStack {
                        Label("Support kontaktieren", systemImage: "envelope")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Info")
            }
            
            Section {
                Text(" 2024 Michael Schellenberger")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Einstellungen")
        .alert("Alle Termine löschen?", isPresented: $showingResetAlert) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                withAnimation {
                    viewModel.events.removeAll()
                    UserDefaults.standard.removeObject(forKey: "savedEvents")
                }
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
    
    private func alertTimeString(_ alertTime: ICSEvent.AlertTime) -> String {
        switch alertTime {
        case .none:
            return "Keine"
        case .atTime:
            return "Zum Startzeitpunkt"
        case .fiveMinutes:
            return "5 Minuten vorher"
        case .tenMinutes:
            return "10 Minuten vorher"
        case .fifteenMinutes:
            return "15 Minuten vorher"
        case .thirtyMinutes:
            return "30 Minuten vorher"
        case .oneHour:
            return "1 Stunde vorher"
        case .twoHours:
            return "2 Stunden vorher"
        case .oneDay:
            return "1 Tag vorher"
        case .twoDays:
            return "2 Tage vorher"
        case .oneWeek:
            return "1 Woche vorher"
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(EventViewModel())
        }
    }
}
