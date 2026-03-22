import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var defaultStationId: String = Station.defaultStationId
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Startverhalten")) {
                    Picker("Standard-Sender", selection: $defaultStationId) {
                        ForEach(Station.all) { station in
                            Text(station.name)
                                .tag(station.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: defaultStationId) { newId in
                        Station.saveDefaultStation(id: newId)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
