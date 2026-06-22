import Foundation
import Networking
import FirebasePerformance
import FirebaseCrashlytics

@MainActor
final class CatListViewModel: ObservableObject {

    enum State {
        case idle
        case loading
        case loaded([DisplayCat])
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let service: CatService

    init(service: CatService? = nil) {
        self.service = service ?? CatAPIClient(host: ContentMode.apiHost)
    }

    func load() async {
        state = .loading

        let trace = Performance.startTrace(name: "fetch_cats")
        Crashlytics.crashlytics().log("Loading cats from API…")

        do {
            let cats = try await service.getCats(limit: 20)

            trace?.setValue(Int64(cats.count), forMetric: "cats_count")
            trace?.setValue("success", forAttribute: "result")
            trace?.stop()

            let display = cats.map { DisplayCat(cat: $0, name: RandomNames.name(for: $0.id)) }
            state = .loaded(display)

            Crashlytics.crashlytics().setCustomValue(cats.count, forKey: "cats_loaded_count")
        } catch {
            trace?.setValue("failed", forAttribute: "result")
            trace?.stop()

            Crashlytics.crashlytics().log("Failed to load cats: \(error.localizedDescription)")
            Crashlytics.crashlytics().record(error: error)
            state = .failed(error.localizedDescription)
        }
    }
}

enum ContentMode {
    static var value: String {
        (Bundle.main.object(forInfoDictionaryKey: "ContentType") as? String)?
            .uppercased() ?? "CATS"
    }

    static var isDogs: Bool { value == "DOGS" }

    static var apiHost: String { isDogs ? "api.thedogapi.com" : "api.thecatapi.com" }

    static var title: String { isDogs ? "Dogs" : "Cats" }
}
