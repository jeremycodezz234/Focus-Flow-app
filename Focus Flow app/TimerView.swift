import SwiftUI
import UserNotifications
import Combine

struct TimerView: View {

    @Environment(\.colorScheme) var colorScheme

    @State private var timeRemaining = 1500
    @State private var totalTime = 1500
    @State private var isRunning = false

    @State private var customMinutes = ""

    @State private var sessionsCompleted = 0
    @State private var focusMinutes = 0

    @State private var feedbackMessage = "Ready to focus?"

    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Adaptive Colors

    var primaryText: Color {
        colorScheme == .dark ? .white : .black
    }

    var secondaryText: Color {
        colorScheme == .dark
        ? .white.opacity(0.7)
        : .black.opacity(0.7)
    }

    var cardBackground: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.1)
        : Color.black.opacity(0.06)
    }

    var textFieldBackground: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.12)
        : Color.white
    }

    var backgroundGradient: LinearGradient {

        if colorScheme == .dark {

            return LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.09, blue: 0.18),
                    Color(red: 0.14, green: 0.15, blue: 0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        } else {

            return LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.95, blue: 1.0),
                    Color(red: 0.84, green: 0.88, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {

        ZStack {

            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 30) {

                Spacer()

                VStack(spacing: 8) {

                    Text("Focus Flow")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(primaryText)

                    Text("Stay productive and focused")
                        .foregroundColor(secondaryText)
                }

                HStack(spacing: 20) {

                    statCard(
                        value: "\(sessionsCompleted)",
                        title: "Sessions"
                    )

                    statCard(
                        value: "\(focusMinutes)",
                        title: "Minutes"
                    )
                }

                ZStack {

                    Circle()
                        .stroke(
                            secondaryText.opacity(0.2),
                            lineWidth: 18
                        )
                        .frame(width: 260, height: 260)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(
                                lineWidth: 18,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 260, height: 260)
                        .animation(
                            .linear(duration: 1),
                            value: progress
                        )

                    VStack(spacing: 10) {

                        Text(formatTime(timeRemaining))
                            .font(
                                .system(
                                    size: 52,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(primaryText)

                        Text(
                            isRunning
                            ? "Focusing..."
                            : "Paused"
                        )
                        .foregroundColor(secondaryText)
                    }
                }

                Text(feedbackMessage)
                    .foregroundColor(secondaryText)
                    .font(.headline)

                HStack(spacing: 15) {

                    presetButton(minutes: 25)
                    presetButton(minutes: 45)
                    presetButton(minutes: 60)
                }

                VStack(spacing: 15) {

                    TextField(
                        "Enter custom minutes",
                        text: $customMinutes
                    )
                    .padding()
                    .background(textFieldBackground)
                    .foregroundColor(primaryText)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                secondaryText.opacity(0.15),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal)

                    Button(action: {
                        setCustomTime()
                    }) {

                        Text("Set Custom Time")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.purple
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }

                HStack(spacing: 20) {

                    Button(action: {
                        isRunning.toggle()
                    }) {

                        HStack {

                            Image(
                                systemName:
                                    isRunning
                                    ? "pause.fill"
                                    : "play.fill"
                            )

                            Text(
                                isRunning
                                ? "Pause"
                                : "Start"
                            )
                            .fontWeight(.bold)
                        }
                        .frame(width: 140, height: 55)
                        .background(
                            isRunning
                            ? Color.orange
                            : Color.green
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }

                    Button(action: {
                        resetTimer()
                    }) {

                        HStack {

                            Image(systemName: "arrow.clockwise")

                            Text("Reset")
                                .fontWeight(.bold)
                        }
                        .frame(width: 140, height: 55)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(16)
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

            if timeRemaining > 1 {

                timeRemaining -= 1

            } else {

                timeRemaining = 0
                completeSession()
            }
        }
    }

    var progress: CGFloat {

        if totalTime == 0 {
            return 0
        }

        return CGFloat(timeRemaining)
        / CGFloat(totalTime)
    }

    func statCard(
        value: String,
        title: String
    ) -> some View {

        VStack(spacing: 8) {

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(primaryText)

            Text(title)
                .foregroundColor(secondaryText)
        }
        .frame(width: 140, height: 90)
        .background(cardBackground)
        .cornerRadius(20)
    }

    func formatTime(_ seconds: Int) -> String {

        let minutes = seconds / 60
        let seconds = seconds % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }

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
                .fontWeight(.bold)
                .frame(width: 80, height: 45)
                .background(cardBackground)
                .foregroundColor(primaryText)
                .cornerRadius(14)
        }
    }

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

    func completeSession() {

        isRunning = false

        sessionsCompleted += 1

        focusMinutes += totalTime / 60

        feedbackMessage =
        "Session complete 🔥"

        sendNotification()

        timeRemaining = totalTime
    }

    func resetTimer() {

        isRunning = false

        timeRemaining = totalTime

        feedbackMessage = "Timer reset."
    }

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
