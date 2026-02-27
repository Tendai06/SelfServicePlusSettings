import Foundation
@testable import SelfServicePlusSettings

// Simple verification script for SelfServicePlusSettings
// Run with: swift run VerifySelfServicePlusSettings

@MainActor
func verifySelfServicePlusSettings() {
    print("🚀 Starting Self Service+ Settings Verification...")
    
    let manager = SelfServicePlusSettingsManager.shared
    var testsPassed = 0
    var testsTotal = 0
    
    func assert(_ condition: Bool, _ message: String) {
        testsTotal += 1
        if condition {
            testsPassed += 1
            print("✅ \(message)")
        } else {
            print("❌ \(message)")
        }
    }
    
    // Test singleton pattern
    let manager2 = SelfServicePlusSettingsManager.shared
    assert(manager === manager2, "Singleton pattern works")
    
    // Test configuration keys exist
    assert(!SelfServicePlusConfigurationKeys.hideConnectMenubar.isEmpty, "Configuration keys are defined")
    assert(!SelfServicePlusConfigurationKeys.brandingName.isEmpty, "Branding keys are defined")
    assert(!SelfServicePlusConfigurationKeys.disableAnalytics.isEmpty, "Analytics keys are defined")
    
    // Test default values
    assert(manager.shouldHideConnectMenubar() == false, "Default UI hiding values are correct")
    assert(manager.shouldHideSecurityDashboard() == false, "Security dashboard default is correct")
    assert(manager.isSingleSignOnEnabled() == false, "SSO default is correct")
    assert(manager.getAutoLogoutTimeInterval() == 3600.0, "Auto logout default is correct")
    assert(manager.isPasswordRequiredOnLogin() == true, "Password requirement default is correct")
    assert(manager.areAdvancedFeaturesEnabled() == false, "Advanced features default is correct")
    assert(manager.isAnalyticsDisabled() == false, "Analytics disabled default is correct")
    
    // Test branding defaults
    assert(manager.getBrandingName() == nil, "Branding name default is nil")
    assert(manager.getBrandingLogoURL() == nil, "Branding logo default is nil")
    assert(manager.getBrandingThemeColor() == nil, "Branding theme default is nil")
    
    // Test generic getValue method
    let testString: String = manager.getValue(for: "NonExistentKey", defaultValue: "test")
    assert(testString == "test", "Generic getValue returns default for non-existent key")
    
    let testBool: Bool = manager.getValue(for: "NonExistentKey", defaultValue: true)
    assert(testBool == true, "Generic getValue works with Bool type")
    
    let testInt: Int = manager.getValue(for: "NonExistentKey", defaultValue: 42)
    assert(testInt == 42, "Generic getValue works with Int type")
    
    // Test hasValue for non-existent key
    assert(manager.hasValue(for: "NonExistentKey") == false, "hasValue returns false for non-existent key")
    
    // Test configuration sources
    let sources = manager.getConfigurationSources()
    assert(sources["managed"] == true, "Managed configuration source is available")
    
    // Test batch methods
    let uiSettings = manager.getAllUIHidingSettings()
    assert(uiSettings.count == 6, "All UI hiding settings are returned")
    assert(uiSettings.keys.contains(SelfServicePlusConfigurationKeys.hideConnectMenubar), "UI settings contain expected keys")
    
    let brandingSettings = manager.getAllBrandingSettings()
    assert(brandingSettings.count == 3, "All branding settings are returned")
    assert(brandingSettings.keys.contains(SelfServicePlusConfigurationKeys.brandingName), "Branding settings contain expected keys")
    
    // Test configuration reload (should not crash)
    manager.reloadConfiguration()
    assert(true, "Configuration reload completes without error")
    
    // Test JSON configuration loading with invalid file (should not crash)
    let nonExistentURL = URL(fileURLWithPath: "/tmp/non-existent-config.json")
    manager.loadJSONConfiguration(from: nonExistentURL)
    assert(true, "JSON configuration loading handles invalid files gracefully")
    
    // Test error descriptions
    let appGroupError = SelfServicePlusSettingsError.invalidAppGroup
    assert(appGroupError.errorDescription?.contains("App Group") == true, "Error descriptions are informative")
    
    let fileNotFoundError = SelfServicePlusSettingsError.configurationFileNotFound(URL(fileURLWithPath: "/test"))
    assert(fileNotFoundError.errorDescription?.contains("not found") == true, "File not found error is descriptive")
    
    // Test legacy support
    let legacyManager = SettingsManager.shared
    assert(manager === legacyManager, "Legacy SettingsManager type alias works")
    
    // Test array and complex type defaults
    assert(manager.getCustomMenuItems().isEmpty, "Custom menu items default to empty array")
    assert(manager.getAdditionalCapabilities().isEmpty, "Additional capabilities default to empty array")
    
    // Summary
    print("\n📊 Test Summary:")
    print("Total tests: \(testsTotal)")
    print("Passed: \(testsPassed)")
    print("Failed: \(testsTotal - testsPassed)")
    
    if testsPassed == testsTotal {
        print("🎉 All tests passed! Self Service+ Settings library is working correctly.")
    } else {
        print("⚠️  Some tests failed. Please review the implementation.")
    }
    
    // Demonstrate real usage
    print("\n🔧 Usage Demonstration:")
    print("Hide Connect Menubar: \(manager.shouldHideConnectMenubar())")
    print("Hide Security Dashboard: \(manager.shouldHideSecurityDashboard())")
    print("SSO Enabled: \(manager.isSingleSignOnEnabled())")
    print("Auto Logout Interval: \(manager.getAutoLogoutTimeInterval()) seconds")
    print("Branding Name: \(manager.getBrandingName() ?? "Default")")
    print("Advanced Features: \(manager.areAdvancedFeaturesEnabled())")
    print("Analytics Disabled: \(manager.isAnalyticsDisabled())")
    
    let availableSources = manager.getConfigurationSources()
    print("Configuration Sources: \(availableSources)")
}

// Entry point for verification
@main 
struct VerificationApp {
    @MainActor
    static func main() {
        verifySelfServicePlusSettings()
    }
}
