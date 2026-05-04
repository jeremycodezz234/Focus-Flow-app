//
//  TimerView.swift
//  Focus Flow app
//
//  Created by Jeremy J. Woetzel on 5/4/26.
//


import SwiftUI

struct TimerView: View {
    
    @State private var timeRemaining: Int = 1500
    @State private var totalTime: Int = 1500
    @State private var isRunning: Bool = false
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            
            Spacer()
            
            Text("Focus Session")
                .font(.title)
                .fontWeight(.semibold)
            
        
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 250, height: 250)
                    .animation(.easeInOut, value: progress)
                
                
                Text(formatTime(timeRemaining))
                    .font(.system(size: 40, weight: .bold))
            }
            
            
            Text("Stay focused")
                .foregroundColor(.gray)
            
            Spacer()
            
            
            HStack(spacing: 20) {
                
                Button(action: {
                    isRunning.toggle()
                }) {
                    Text(isRunning ? "Pause" : "Start")
                        .frame(width: 100, height: 50)
                        .background(isRunning ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    resetTimer()
                }) {
                    Text("End")
                        .frame(width: 100, height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    
    var progress: CGFloat {
        return CGFloat(timeRemaining) / CGFloat(totalTime)
    }
    
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
   
    func resetTimer() {
        isRunning = false
        timeRemaining = totalTime
    }
}

