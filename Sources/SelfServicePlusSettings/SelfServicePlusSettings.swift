import Foundation
import os

// MARK: - Configuration Keys
public struct SelfServicePlusConfigurationKeys {
    // UI Hiding Keys
    public static let hideConnectMenubar = "HideConnectMenubar"
    public static let hideSecurityDashboard = "HideSecurityDashboard"
    public static let hideApplicationsSection = "HideApplicationsSection"
    public static let hidePatchManagementSection = "HidePatchManagementSection"
    public static let hideRemoteAssistanceSection = "HideRemoteAssistanceSection"
    public static let hideDeviceComplianceSection = "HideDeviceComplianceSection"
    
    // Account Management Keys
    public static let enableSingleSignOn = "EnableSingleSignOn"
    public static let autoLogoutTimeInterval = "AutoLogoutTimeInterval"
    public static let requirePasswordOnLogin = "RequirePasswordOnLogin"
    public static let allowUserAccountCreation = "AllowUserAccountCreation"
    
    // Branding Keys
    public static let brandingName = "BrandingName"
    public static let brandingLogoURL = "BrandingLogoURL"
    public static let brandingThemeColor = "BrandingThemeColor"
    
    // Feature Keys
    public static let enableAdvancedFeatures = "EnableAdvancedFeatures"
    public static let enableBetaFeatures = "EnableBetaFeatures"
    public static let customMenuItems = "CustomMenuItems"
    public static let additionalCapabilities = "AdditionalCapabilities"
    
    // Analytics and Data Collection (Secret Keys)
    public static let disableAnalytics = "DisableAnalytics"
    public static let disableAllDataCollection = "DisableAllDataCollection"
    public static let disableSentryLogging = "DisableSentryLogging"
}

// MARK: - Configuration Source
public enum ConfigurationSource {
    case managed(UserDefaults)     // Managed via Jamf Pro/mobileconfig
    case nonManaged(URL)          // JSON configuration file
    case appGroup(UserDefaults)   // Shared App Group defaults
}

// MARK: - Configuration Error Types
public enum SelfServicePlusSettingsError: Error, LocalizedError {
    case invalidAppGroup
    case configurationFileNotFound(URL)
    case invalidConfigurationData
    case keyNotFound(String)
    case unsupportedValueType
    
    public var errorDescription: String? {
        switch self {
        case .invalidAppGroup:
            return "Could not access the shared App Group: group.com.jamf.selfserviceplus"
        case .configurationFileNotFound(let url):
            return "Configuration file not found at: \(url.path)"
        case .invalidConfigurationData:
            return "Configuration data is invalid or corrupted"
        case .keyNotFound(let key):
            return "Configuration key not found: \(key)"
        case .unsupportedValueType:
            return "Unsupported value type in configuration"
        }
    }
}

// MARK: - Settings Manager
@MainActor
public class SelfServicePlusSettingsManager {
    // MARK: - Public Properties
    public static let shared = SelfServicePlusSettingsManager()
    
    // MARK: - Private Properties
    private let appGroupIdentifier = "group.com.jamf.selfserviceplus"
    private let logger = Logger(subsystem: "com.jamf.selfserviceplus", category: "Settings")
    
    private var appGroupDefaults: UserDefaults?
    private var managedDefaults: UserDefaults
    private var jsonConfiguration: [String: Any]?
    
    // MARK: - Initialization
    private init() {
        // Initialize managed defaults (for mobileconfig)
        self.managedDefaults = UserDefaults.standard
        
        // Initialize App Group defaults
        self.appGroupDefaults = UserDefaults(suiteName: appGroupIdentifier)
        
        if appGroupDefaults == nil {
            logger.warning("Failed to initialize App Group UserDefaults for identifier: \(self.appGroupIdentifier)")
        }
        
        // Load JSON configuration if available
        loadJSONConfiguration()
    }
    
    // MARK: - Public Configuration Methods
    
    /// Loads configuration from a JSON file (for non-managed deployments)
    public func loadJSONConfiguration(from url: URL? = nil) {
        let configURL = url ?? defaultJSONConfigurationURL()
        
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            logger.info("No JSON configuration file found at: \(configURL.path)")
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            if let config = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                jsonConfiguration = config
                logger.info("Successfully loaded JSON configuration from: \(configURL.path)")
            } else {
                logger.error("Invalid JSON configuration format")
            }
        } catch {
            logger.error("Failed to load JSON configuration: \(error.localizedDescription)")
        }
    }
    
    /// Reloads all configuration sources
    public func reloadConfiguration() {
        loadJSONConfiguration()
        logger.info("Configuration reloaded from all sources")
    }
    
    // MARK: - UI Hiding Settings
    
    public func shouldHideConnectMenubar() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.hideConnectMenubar, defaultValue: true)
    }
    
    public func shouldHideSecurityDashboard() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.hideSecurityDashboard, defaultValue: false)
    }
    
    public func shouldHideApplicationsSection() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.hideApplicationsSection, defaultValue: false)
    }
    
    public func shouldHidePatchManagementSection() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.hidePatchManagementSection, defaultValue: false)
    }
    
    public func shouldHideRemoteAssistanceSection() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.hideRemoteAssistanceSection, defaultValue: false)
    }
    
    public func shouldHideDeviceComplianceSection() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.hideDeviceComplianceSection, defaultValue: false)
    }
    
    // MARK: - Account Management Settings
    
    public func isSingleSignOnEnabled() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.enableSingleSignOn, defaultValue: false)
    }
    
    public func getAutoLogoutTimeInterval() -> TimeInterval {
        return getValue(for: SelfServicePlusConfigurationKeys.autoLogoutTimeInterval, defaultValue: 3600.0)
    }
    
    public func isPasswordRequiredOnLogin() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.requirePasswordOnLogin, defaultValue: true)
    }
    
    public func isUserAccountCreationAllowed() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.allowUserAccountCreation, defaultValue: true)
    }
    
    // MARK: - Branding Settings
    
    public func getBrandingName() -> String? {
        return getValue(for: SelfServicePlusConfigurationKeys.brandingName, defaultValue: nil)
    }
    
    public func getBrandingLogoURL() -> URL? {
        guard let urlString: String = getValue(for: SelfServicePlusConfigurationKeys.brandingLogoURL, defaultValue: nil) else {
            return nil
        }
        return URL(string: urlString)
    }
    
    public func getBrandingThemeColor() -> String? {
        return getValue(for: SelfServicePlusConfigurationKeys.brandingThemeColor, defaultValue: nil)
    }
    
    // MARK: - Feature Settings
    
    public func areAdvancedFeaturesEnabled() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.enableAdvancedFeatures, defaultValue: false)
    }
    
    public func areBetaFeaturesEnabled() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.enableBetaFeatures, defaultValue: false)
    }
    
    public func getCustomMenuItems() -> [[String: Any]] {
        return getValue(for: SelfServicePlusConfigurationKeys.customMenuItems, defaultValue: [])
    }
    
    public func getAdditionalCapabilities() -> [String] {
        return getValue(for: SelfServicePlusConfigurationKeys.additionalCapabilities, defaultValue: [])
    }
    
    // MARK: - Analytics and Data Collection Settings (Secret)
    
    public func isAnalyticsDisabled() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.disableAnalytics, defaultValue: false)
    }
    
    public func isAllDataCollectionDisabled() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.disableAllDataCollection, defaultValue: false)
    }
    
    public func isSentryLoggingDisabled() -> Bool {
        return getValue(for: SelfServicePlusConfigurationKeys.disableSentryLogging, defaultValue: false)
    }
    
    // MARK: - Generic Configuration Access
    
    /// Retrieves a configuration value with type safety and fallback logic
    public func getValue<T>(for key: String, defaultValue: T) -> T {
        // Priority order: App Group → Managed (mobileconfig) → JSON → Default
        
        // 1. Try App Group defaults first (highest priority for shared settings)
        if let appGroupValue = appGroupDefaults?.object(forKey: key) as? T {
            logger.debug("Retrieved '\(key)' from App Group: \(String(describing: appGroupValue))")
            return appGroupValue
        }
        
        // 2. Try managed defaults (mobileconfig)
        if let managedValue = managedDefaults.object(forKey: key) as? T {
            logger.debug("Retrieved '\(key)' from managed configuration: \(String(describing: managedValue))")
            return managedValue
        }
        
        // 3. Try JSON configuration
        if let jsonValue = jsonConfiguration?[key] as? T {
            logger.debug("Retrieved '\(key)' from JSON configuration: \(String(describing: jsonValue))")
            return jsonValue
        }
        
        // 4. Return default value
        logger.debug("Using default value for '\(key)': \(String(describing: defaultValue))")
        return defaultValue
    }
    
    /// Checks if a configuration key exists in any source
    public func hasValue(for key: String) -> Bool {
        return appGroupDefaults?.object(forKey: key) != nil ||
               managedDefaults.object(forKey: key) != nil ||
               jsonConfiguration?[key] != nil
    }
    
    /// Returns all available configuration sources for debugging
    public func getConfigurationSources() -> [String: Bool] {
        return [
            "appGroup": appGroupDefaults != nil,
            "managed": true,
            "json": jsonConfiguration != nil
        ]
    }
    
    // MARK: - Private Helper Methods
    
    private func defaultJSONConfigurationURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("SelfServicePlusSettings.json")
    }
    
    private func loadJSONConfiguration() {
        loadJSONConfiguration(from: nil)
    }
}

// MARK: - Legacy Support
public typealias SettingsManager = SelfServicePlusSettingsManager

// MARK: - Convenience Extensions
public extension SelfServicePlusSettingsManager {
    /// Returns a dictionary of all UI hiding settings for bulk operations
    func getAllUIHidingSettings() -> [String: Bool] {
        return [
            SelfServicePlusConfigurationKeys.hideConnectMenubar: shouldHideConnectMenubar(),
            SelfServicePlusConfigurationKeys.hideSecurityDashboard: shouldHideSecurityDashboard(),
            SelfServicePlusConfigurationKeys.hideApplicationsSection: shouldHideApplicationsSection(),
            SelfServicePlusConfigurationKeys.hidePatchManagementSection: shouldHidePatchManagementSection(),
            SelfServicePlusConfigurationKeys.hideRemoteAssistanceSection: shouldHideRemoteAssistanceSection(),
            SelfServicePlusConfigurationKeys.hideDeviceComplianceSection: shouldHideDeviceComplianceSection()
        ]
    }
    
    /// Returns a dictionary of all branding settings
    func getAllBrandingSettings() -> [String: Any?] {
        return [
            SelfServicePlusConfigurationKeys.brandingName: getBrandingName(),
            SelfServicePlusConfigurationKeys.brandingLogoURL: getBrandingLogoURL()?.absoluteString,
            SelfServicePlusConfigurationKeys.brandingThemeColor: getBrandingThemeColor()
        ]
    }
}
