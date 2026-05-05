//
//  ContentView.swift
//  GuessTheFlagApp
//
//  Created by Abdullah Butt on 18/04/2026.
//

import SwiftUI

struct FlagImage: View {
    var country: String

    var body: some View {
        Image(country)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct ProminentTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundStyle(.blue)
    }
}

extension View {
    func prominentTitle() -> some View {
        modifier(ProminentTitle())
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var questionsAsked = 0
    @State private var selectedNumber: Int? = nil

    @State private var rotationAmounts = [0.0, 0.0, 0.0]
    @State private var opacityAmounts  = [1.0, 1.0, 1.0]
    @State private var shakeAmounts    = [0.0, 0.0, 0.0]

    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()

            VStack {
                Spacer()
                Text("Guess the Flag")
                    .prominentTitle()

                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .prominentTitle()
                    }

                    ForEach(0..<3) { number in
                        Button {
                            selectedNumber = number

                            withAnimation(.spring(duration: 0.5)) {
                                rotationAmounts[number] += 360
                            }

                            for i in 0..<3 where i != number {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    opacityAmounts[i] = 0.25
                                }
                                withAnimation(.easeInOut(duration: 0.06).repeatCount(6, autoreverses: true)) {
                                    shakeAmounts[i] = 10
                                }
                            }

                            flagTapped(number)
                        } label: {
                            FlagImage(country: countries[number])
                                .rotation3DEffect(
                                    .degrees(rotationAmounts[number]),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .opacity(opacityAmounts[number])
                                .offset(x: shakeAmounts[number])
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))

                Spacer()
                Spacer()
                Text("Score is \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(
                selectedNumber == nil || selectedNumber == correctAnswer
                ? "Your score is \(score)\nQuestion \(questionsAsked) of 8"
                : "Wrong ❌! That's the flag of \"\(countries[selectedNumber!])\".\nYour score is \(score)\nQuestion \(questionsAsked) of 8"
            )
        }
    }

    func flagTapped(_ number: Int) {
        if correctAnswer == number {
            scoreTitle = "Correct ✅"
            score += 1
        } else {
            scoreTitle = "Wrong"
        }
        questionsAsked += 1
        if questionsAsked == 8 {
            scoreTitle = "Game Over"
        }
        showingScore = true
    }

    private func resetGame() {
        score = 0
        questionsAsked = 0
        selectedNumber = nil
        rotationAmounts = [0.0, 0.0, 0.0]
        opacityAmounts  = [1.0, 1.0, 1.0]
        shakeAmounts    = [0.0, 0.0, 0.0]
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }

    func askQuestion() {
        if questionsAsked >= 8 {
            resetGame()
            return
        }
        selectedNumber = nil
        rotationAmounts = [0.0, 0.0, 0.0]
        opacityAmounts  = [1.0, 1.0, 1.0]
        shakeAmounts    = [0.0, 0.0, 0.0]
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
}

#Preview {
    ContentView()
}
