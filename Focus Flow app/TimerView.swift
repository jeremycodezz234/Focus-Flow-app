import SwiftUI
import UserNotifications
import Combine

struct TimerView: View {
    
    // MARK: - Timer
    
    @State private var timeRemaining = 1500
    @State private var totalTime = 1500
    @State private var isRunning = false
    
    // MARK: - Custom Time
    
    @State private var customMinutes = ""
    
    // MARK: - Stats
    
    @State private var sessionsCompleted = 0
    @State private var focusMinutes = 0
    
    // MARK: - Message
    
    @State private var feedbackMessage = "Ready to focus?"
    
    // MARK: - Timer
    
    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        
        ZStack {
            
    
            
            VStack(spacing: 30) {
                
                Spacer()
                
                // MARK: - Title
                
                Text("Focus Flow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // MARK: - Stats
                
                HStack(spacing: 40) {
                    
                    VStack {
                        
                        Text("\(sessionsCompleted)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Sessions")
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        
                        Text("\(focusMinutes)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Minutes")
                            .foregroundColor(.gray)
                    }
                }
                
                // MARK: - Timer Circle
                
                ZStack {
                    
                    Circle()
                        .stroke(
                            Color.gray.opacity(0.2),
                            lineWidth: 15
                        )
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 250, height: 250)
                        .animation(
                            .easeInOut,
                            value: progress
                        )
                    
                    VStack(spacing: 10) {
                        
                        Text(formatTime(timeRemaining))
                            .font(
                                .system(
                                    size: 42,
                                    weight: .bold
                                )
                            )
                        
                        Text(
                            isRunning
                            ? "Focusing..."
                            : "Paused"
                        )
                        .foregroundColor(.gray)
                    }
                }
                
                // MARK: - Feedback
                
                Text(feedbackMessage)
                    .foregroundColor(.gray)
                
                // MARK: - Preset Buttons
                
                HStack(spacing: 12) {
                    
                    presetButton(minutes: 25)
                    presetButton(minutes: 45)
                    presetButton(minutes: 60)
                }
                
                // MARK: - Custom Time
                
                VStack(spacing: 12) {
                    
                    TextField(
                        "Enter custom minutes",
                        text: $customMinutes
                    )
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 5
                    )
                    .padding(.horizontal)
                    
                    Button(action: {
                        setCustomTime()
                    }) {
                        
                        Text("Set Custom Time")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Controls
                
                HStack(spacing: 20) {
                    
                    // Start / Pause
                    
                    Button(action: {
                        isRunning.toggle()
                    }) {
                        
                        Text(
                            isRunning
                            ? "Pause"
                            : "Start"
                        )
                        .fontWeight(.semibold)
                        .frame(width: 130, height: 50)
                        .background(
                            isRunning
                            ? Color.orange
                            : Color.green
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Reset
                    
                    Button(action: {
                        resetTimer()
                    }) {
                        
                        Text("Reset")
                            .fontWeight(.semibold)
                            .frame(width: 130, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            requestNotifications()
        }
        .onReceive(timer) { _ in
            
            guard isRunning else { return }
            
            if timeRemaining > 0 {
                
                timeRemaining -= 1
                
            } else {
                
                completeSession()
            }
        }
    }
    
    // MARK: - Progress
    
    var progress: CGFloat {
        
        if totalTime == 0 {
            return 0
        }
        
        return CGFloat(timeRemaining)
        / CGFloat(totalTime)
    }
    
    // MARK: - Format Time
    
    func formatTime(_ seconds: Int) -> String {
        
        let minutes = seconds / 60
        let seconds = seconds % 60
        
        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }
    
    // MARK: - Preset Button
    
    func presetButton(
        minutes: Int
    ) -> some View {
        
        Button(action: {
            
            let seconds = minutes * 60
            
            totalTime = seconds
            timeRemaining = seconds
            
            feedbackMessage =
            "\(minutes) minute timer selected."
            
        }) {
            
            Text("\(minutes)m")
                .fontWeight(.medium)
                .frame(width: 70, height: 40)
                .background(Color.white)
                .foregroundColor(.blue)
                .cornerRadius(10)
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 4
                )
        }
    }
    
    // MARK: - Custom Time
    
    func setCustomTime() {
        
        guard let minutes = Int(customMinutes),
              minutes > 0 else {
            
            feedbackMessage =
            "Please enter a valid number."
            
            return
        }
        
        let seconds = minutes * 60
        
        totalTime = seconds
        timeRemaining = seconds
        
        feedbackMessage =
        "Custom timer set for \(minutes) minutes."
    }
    
    // MARK: - Complete Session
    
    func completeSession() {
        
        isRunning = false
        
        sessionsCompleted += 1
        
        focusMinutes += totalTime / 60
        
        feedbackMessage =
        "Session complete. Nice work 🔥"
        
        sendNotification()
        
        // Auto reset
        
        timeRemaining = totalTime
    }
    
    // MARK: - Reset
    
    func resetTimer() {
        
        isRunning = false
        
        timeRemaining = totalTime
        
        feedbackMessage = "Timer reset."
    }
    
    // MARK: - Notifications
    
    func requestNotifications() {
        
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound]
            ) { _, _ in }
    }
    
    func sendNotification() {
        
        let content =
        UNMutableNotificationContent()
        
        content.title =
        "Focus Session Complete"
        
        content.body =
        "Good job staying focused."
        
        content.sound = .default
        
        let request =
        UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current()
            .add(request)
    }
}
