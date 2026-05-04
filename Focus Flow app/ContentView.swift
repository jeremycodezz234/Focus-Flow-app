import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(spacing: 40) {
            
            Spacer()
            
            // App Title
            Text("FocusFlow")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Subtitle
            Text("Stay focused. Study smarter.")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Start Button
            Button(action: {
            }) {
                Text("Start Session")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            
            Spacer()
            
        }
        .padding()
    }
}

