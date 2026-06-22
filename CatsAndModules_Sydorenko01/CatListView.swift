import SwiftUI
import UIKit
import FirebasePerformance
import FirebaseCrashlytics

struct CatListView: View {
    @StateObject private var viewModel = CatListViewModel()
    @StateObject private var consent = CrashConsent()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(ContentMode.title)
                .navigationDestination(for: DisplayCat.self) { cat in
                    CatDetailView(cat: cat)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        crashMenu
                    }
                }
        }
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
        .alert("Allow crash reporting?", isPresented: $consent.shouldAsk) {
            Button("Allow") { consent.resolve(granted: true) }
            Button("Don’t allow", role: .cancel) { consent.resolve(granted: false) }
        } message: {
            Text("We collect crash diagnostics to make the app more stable. You can change this only by reinstalling the app.")
        }
    }

    private var crashMenu: some View {
        Menu {
            Button("Crash: fatalError", role: .destructive) { CrashKit.fatalErrorCrash() }
            Button("Crash: index out of range", role: .destructive) { CrashKit.outOfRangeCrash() }
            Button("Crash: force unwrap nil", role: .destructive) { CrashKit.forceUnwrapCrash() }
        } label: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading cats…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let cats):
            List(cats) { cat in
                NavigationLink(value: cat) {
                    CatRow(cat: cat)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    CrashLog.tap(on: cat)
                })
            }
            .listStyle(.plain)
            .refreshable { await viewModel.load() }
        case .failed(let message):
            ErrorView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }
}

private struct CatRow: View {
    let cat: DisplayCat

    var body: some View {
        HStack(spacing: 12) {
            TracedAsyncImage(url: cat.imageURL)
                .frame(width: 64, height: 64)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(cat.name)
                    .font(.headline)
                Text(cat.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct TracedAsyncImage: View {
    let url: URL
    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
            } else if failed {
                Image(systemName: "photo").foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        image = nil
        failed = false
        let trace = Performance.startTrace(name: "load_cat_image")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            trace?.setValue(Int64(data.count), forMetric: "image_bytes")
            trace?.setValue("success", forAttribute: "result")
            trace?.stop()
            if let ui = UIImage(data: data) {
                image = ui
            } else {
                failed = true
            }
        } catch {
            trace?.setValue("failed", forAttribute: "result")
            trace?.stop()
            failed = true
        }
    }
}

private struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
            Text("Couldn’t load cats")
                .font(.headline)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum CrashLog {
    static func tap(on cat: DisplayCat) {
        let c = Crashlytics.crashlytics()
        c.log("Tapped row: \(cat.name) [\(cat.id)]")
        c.setCustomValue(cat.id, forKey: "last_tapped_cat_id")
        c.setCustomValue(cat.name, forKey: "last_tapped_cat_name")

        let count = UserDefaults.standard.integer(forKey: "taps_count") + 1
        UserDefaults.standard.set(count, forKey: "taps_count")
        c.setCustomValue(count, forKey: "total_taps")
    }
}

enum CrashKit {
    static func fatalErrorCrash() {
        Crashlytics.crashlytics().log("User triggered crash: fatalError")
        fatalError("Test crash: fatalError")
    }

    static func outOfRangeCrash() {
        Crashlytics.crashlytics().log("User triggered crash: index out of range")
        let empty: [Int] = []
        _ = empty[5]
    }

    static func forceUnwrapCrash() {
        Crashlytics.crashlytics().log("User triggered crash: force unwrap nil")
        let value: String? = nil
        _ = value!.count
    }
}

final class CrashConsent: ObservableObject {
    private let askedKey = "crash_consent_asked"
    private let grantedKey = "crash_consent_granted"

    @Published var shouldAsk: Bool

    init() {
        let asked = UserDefaults.standard.bool(forKey: askedKey)
        shouldAsk = !asked

        if asked {
            let granted = UserDefaults.standard.bool(forKey: grantedKey)
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(granted)
        } else {
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        }
    }

    func resolve(granted: Bool) {
        UserDefaults.standard.set(true, forKey: askedKey)
        UserDefaults.standard.set(granted, forKey: grantedKey)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(granted)
        shouldAsk = false
    }
}

#Preview {
    CatListView()
}
