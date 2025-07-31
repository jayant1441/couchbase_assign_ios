

import Foundation

struct ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private enum Constants {
        static let path = Bundle.main.path(forResource: "Config", ofType: "plist")
        static let capellaURLKey = "Remote Capella endpoint URL"
        static let authenticationKey = "Authentication"
        static let userNameKey = "User name"
        static let passwordKey = "Password"
    }

    
    private var configuration: ConfigModel?
    private init() { loadConfiguration() }
    func getConfiguration() -> ConfigModel? { configuration }
    private mutating func loadConfiguration() {
        guard let path = Constants.path,
              let dict = NSDictionary(contentsOfFile: path) as? [String:Any] else {
            ErrorManager.shared.showError(error: ConfigurationErrors.configFileMissing)
            return
        }
        configuration = parseConfiguration(dict)
    }
    private func parseConfiguration(_ dict: [String:Any]) -> ConfigModel? {
        guard let urlString = dict[Constants.capellaURLKey] as? String,
              let url = URL(string: urlString)
        else { ErrorManager.shared.showError(error: ConfigurationErrors.configError); return nil }
        guard let auth = dict[Constants.authenticationKey] as? [String:Any],
              let user = auth[Constants.userNameKey] as? String,
              let pass = auth[Constants.passwordKey] as? String,
              !user.isEmpty, !pass.isEmpty
        else { ErrorManager.shared.showError(error: ConfigurationErrors.configError); return nil }
        return ConfigModel(capellaEndpointURL: url, username: user, password: pass)
    }
}
