import SwiftUI

struct ContentView: View {
    @State private var showScanner = false
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                // App icon button for scanning
                Button(action: { showScanner = true }, label: {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.accentColor)
                        Text("Scan a Cheque")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 24).fill(Color(.secondarySystemBackground)))
                    .shadow(radius: 8)
                })
                .accessibilityIdentifier("scan_cheque_icon_button")
                Spacer()
            }
        }
        .sheet(isPresented: $showScanner) {
            ChequeScannerScreen()
        }
    }
}

#Preview {
    ContentView()
}
