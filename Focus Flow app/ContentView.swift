import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                Spacer()
                
                
                Text("FocusFlow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Stay focused. Study smarter.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                
                NavigationLink(destination: TimerView()) {
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
}

#Preview {
    ContentView()
}
