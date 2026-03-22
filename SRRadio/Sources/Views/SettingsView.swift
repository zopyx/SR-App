import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var defaultStationId: String = Station.defaultStationId

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("Startverhalten", comment: "Settings section for startup behavior"))) {
                    Picker(NSLocalizedString("Standard-Sender", comment: "Default station picker label"), selection: $defaultStationId) {
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
            .navigationTitle(NSLocalizedString("Einstellungen", comment: "Settings screen title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("Fertig", comment: "Done button")) {
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
