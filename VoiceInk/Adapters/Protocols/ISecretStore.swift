import Foundation

public protocol ISecretStore: AnyObject {
    /// Persist a secret value for the given key. Returns true on success.
    @discardableResult func save(key: String, value: String) -> Bool
    func load(key: String) -> String?
    func delete(key: String)
}
