import Foundation

/// macOS implementation of ISecretStore.
/// Delegates to the existing KeychainService, which handles iCloud sync and
/// graceful fallback to UserDefaults for local (unsigned) builds.
public final class KeychainSecretStore: ISecretStore {

    private let keychain = KeychainService.shared

    @discardableResult
    public func save(key: String, value: String) -> Bool {
        keychain.save(value, forKey: key)
    }

    public func load(key: String) -> String? {
        keychain.getString(forKey: key)
    }

    public func delete(key: String) {
        keychain.delete(forKey: key)
    }
}
