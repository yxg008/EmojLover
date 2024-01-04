import SwiftUI

// Emoji item identifiable for list and grid
struct EmojiItem: Identifiable {
    let id: Int
    let emoji: String
}

// Live Emoji View
struct LiveEmojiView: View {
    @Binding var liveEmoji: String

    var body: some View {
        Text(liveEmoji)
            .font(.system(size: 80))
            .animation(.easeInOut(duration: 0.5), value: liveEmoji)
    }
}

// Full-Screen Emoji View
struct EmojiFullScreenView: View {
    let emojis: [String]
    @State var currentIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var backgroundColor: Color = .white

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .padding()
                    }
                }
                Spacer()
                Text(emojis[currentIndex])
                    .font(.system(size: 100))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.width < 0 && currentIndex < emojis.count - 1 {
                                // Swipe Left - Next Emoji
                                currentIndex += 1
                                updateBackgroundColor()
                            }
                            if value.translation.width > 0 && currentIndex > 0 {
                                // Swipe Right - Previous Emoji
                                currentIndex -= 1
                                updateBackgroundColor()
                            }
                        })
                Spacer()
            }
        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: updateBackgroundColor)
    }

    private func updateBackgroundColor() {
        let colors: [Color] = [.red, .green, .blue, .orange, .pink, .purple, .yellow]
        backgroundColor = colors[currentIndex % colors.count]
    }
}

// Main Content View
struct ContentView: View {
    @State private var emojis = ["😀", "🥰", "🐱", "🚀", "🌈", "🍕", "🏀", "🍀", "🎉", "🎈", "📚", "🎸", "🏖️"]
    @State private var selectedEmoji: EmojiItem?
    @State private var liveEmoji = "😀"

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Welcome to EmojLover!")
                        .font(.largeTitle)
                        .padding()

                    LiveEmojiView(liveEmoji: $liveEmoji)
                        .frame(height: 100)
                        .padding()
                        .onTapGesture {
                            liveEmoji = emojis.randomElement() ?? "😀"
                        }
                        .animation(.spring(), value: liveEmoji)

                    Text("Choose your Emoji:")
                        .font(.headline)
                        .padding([.leading, .top])

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(emojis.indices, id: \.self) { index in
                            Text(emojis[index])
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .onTapGesture {
                                    self.selectedEmoji = EmojiItem(id: index, emoji: emojis[index])
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🌟 EmojLover 🌟")
            .toolbar {
                EditButton()
            }
        }
        .fullScreenCover(item: $selectedEmoji) { emojiItem in
            EmojiFullScreenView(emojis: emojis, currentIndex: emojiItem.id)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            emojis.remove(atOffsets: offsets)
            if let selectedIndex = selectedEmoji?.id, offsets.contains(selectedIndex) {
                selectedEmoji = nil
            }
        }
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

