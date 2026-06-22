import SwiftUI

struct CatDetailView: View {
    let cat: DisplayCat

    var body: some View {
        AsyncImage(url: cat.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure:
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                    Text("Couldn’t load image")
                        .foregroundStyle(.secondary)
                }
            default:
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(cat.name)
        .navigationBarTitleDisplayMode(.inline)
        Button("Crash") {
          fatalError("Crash was triggered")
        }
    }
}
