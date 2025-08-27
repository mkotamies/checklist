import SwiftUI

struct ContentView: View {
    let engine = ChecklistEngine()

    var body: some View {
        VStack(spacing: 16) {
            Text("Checklist iOS")
                .font(.largeTitle)
                .bold()
            Text(engine.welcomeMessage(arguments: []))
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
