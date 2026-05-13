import Foundation
import FirebaseDatabase
import SwiftyJSON

final class DatabaseFunctions {

    func log(message: String) {
        #if DEBUG
        print("DatabaseFunctions:", message)
        #endif
    }

    func log(message: DataSnapshot) {
        #if DEBUG
        print(
            "DatabaseFunctions snapshot key:",
            message.key,
            "value:", String(
                describing: message.value
            )
        )
        #endif
    }

    func readOnceFromFirebaseAndReturnString(pathToValue: String, completion: @escaping (String) -> Void) {
        let ref = Self.reference(forPath: pathToValue)
        ref.observeSingleEvent(of: .value) { snapshot in
            let text = Self.stringValue(from: snapshot.value)
            DispatchQueue.main.async {
                completion(text)
            }
        }
    }

    func readOnceFromFirebaseAndReturnJSON(pathToValue: String, completion: @escaping ([String: JSON]) -> Void) {
        let ref = Self.reference(forPath: pathToValue)
        ref.observeSingleEvent(of: .value) { snapshot in
            let json = Self.jsonDictionary(from: snapshot.value)
            DispatchQueue.main.async {
                completion(json)
            }
        }
    }

    private static func reference(forPath path: String) -> DatabaseReference {
        path.split(separator: "/").map(String.init).reduce(Database.database().reference()) { $0.child($1) }
    }

    private static func stringValue(from value: Any?) -> String {
        guard let value else { return "" }
        if let string = value as? String { return string }
        if let number = value as? NSNumber { return number.stringValue }
        return ""
    }

    private static func jsonDictionary(from value: Any?) -> [String: JSON] {
        guard let value else { return [:] }
        if let dict = value as? [String: Any] {
            return dict.mapValues { JSON($0) }
        }
        return [:]
    }
}
