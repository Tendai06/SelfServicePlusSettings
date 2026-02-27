# Self Service+ Settings Library

A unified configuration management library for Self Service+ that supports both managed (Jamf Pro) and non-managed deployments.

## Overview

The Self Service+ Settings library provides a centralized way to manage configuration across the unified Self Service+ app and its individual capabilities (Caribou, CatDog, Hoplon). It supports multiple configuration sources with a clear priority hierarchy and uses a shared App Group for cross-process communication.

## Features

- **Unified Configuration API**: Single interface for all Self Service+ settings
- **Multiple Configuration Sources**: Support for managed (Jamf Pro/mobileconfig), non-managed (JSON), and App Group storage
- **Type-Safe Access**: Strongly-typed methods for all configuration values
- **Shared App Group**: Uses `group.com.jamf.selfserviceplus` for inter-process communication
- **Priority-Based Loading**: Intelligent fallback system across configuration sources
- **Comprehensive Logging**: Built-in logging for debugging and monitoring
- **Error Handling**: Robust error handling with descriptive error messages

## Installation

### Swift Package Manager

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "path/to/SelfServicePlusSettings", branch: "main")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version/branch
4. Add to your target

## Configuration Sources Priority

The library checks configuration sources in this order (highest to lowest priority):

1. **App Group UserDefaults** (`group.com.jamf.selfserviceplus`)
2. **Managed Configuration** (mobileconfig via Jamf Pro)
3. **JSON Configuration** (local JSON file)
4. **Default Values** (hardcoded fallbacks)

## Usage

### Basic Usage

```swift
import SelfServicePlusSettings

// Get the shared settings manager instance
let settings = SelfServicePlusSettingsManager.shared

// Check UI hiding settings
if settings.shouldHideConnectMenubar() {
    // Hide the connect menubar
}

if settings.shouldHideSecurityDashboard() {
    // Hide the security dashboard
}

// Get branding information
if let brandingName = settings.getBrandingName() {
    // Use custom branding name
}

// Check feature flags
if settings.areAdvancedFeaturesEnabled() {
    // Enable advanced features
}

// Check analytics settings
if settings.isAnalyticsDisabled() {
    // Disable analytics tracking
}
```

### Configuration Management

#### Managed Deployment (Jamf Pro)

For managed deployments, deploy settings via Jamf Pro using a mobileconfig profile targeting the shared App Group:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.ManagedClient.preferences</string>
            <key>PayloadIdentifier</key>
            <string>group.com.jamf.selfserviceplus</string>
            <key>PayloadUUID</key>
            <string>YOUR_UUID_HERE</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadDisplayName</key>
            <string>Self Service+ Settings</string>
            
            <!-- Configuration Values -->
            <key>HideConnectMenubar</key>
            <false/>
            <key>HideSecurityDashboard</key>
            <false/>
            <key>BrandingName</key>
            <string>Acme Corporation Self Service</string>
            <key>EnableAdvancedFeatures</key>
            <true/>
        </dict>
    </array>
    <!-- Additional payload configuration -->
</dict>
</plist>
```

#### Non-Managed Deployment (JSON)

For non-managed deployments, create a JSON configuration file:

```swift
// Load from custom location
let customURL = URL(fileURLWithPath: "/path/to/config.json")
SelfServicePlusSettingsManager.shared.loadJSONConfiguration(from: customURL)

// Or place at default location: ~/Documents/SelfServicePlusSettings.json
SelfServicePlusSettingsManager.shared.reloadConfiguration()
```

See `SelfServicePlusSettings.example.json` for a complete configuration example.

### Available Configuration Keys

#### UI Hiding Settings
- `HideConnectMenubar`: Hide the Connect menubar item
- `HideSecurityDashboard`: Hide the Security Dashboard section
- `HideApplicationsSection`: Hide the Applications section
- `HidePatchManagementSection`: Hide the Patch Management section
- `HideRemoteAssistanceSection`: Hide the Remote Assistance section
- `HideDeviceComplianceSection`: Hide the Device Compliance section

#### Account Management
- `EnableSingleSignOn`: Enable single sign-on functionality
- `AutoLogoutTimeInterval`: Automatic logout timeout (seconds)
- `RequirePasswordOnLogin`: Require password for login
- `AllowUserAccountCreation`: Allow users to create accounts

#### Branding
- `BrandingName`: Custom application name
- `BrandingLogoURL`: URL to custom logo image
- `BrandingThemeColor`: Custom theme color (hex format)

#### Feature Controls
- `EnableAdvancedFeatures`: Enable advanced feature set
- `EnableBetaFeatures`: Enable beta/experimental features
- `CustomMenuItems`: Array of custom menu items
- `AdditionalCapabilities`: Array of additional capability identifiers

#### Analytics and Data Collection (Secret Keys)
- `DisableAnalytics`: Disable all analytics tracking
- `DisableAllDataCollection`: Disable all data collection
- `DisableSentryLogging`: Disable Sentry error reporting

### Advanced Usage

#### Generic Value Access

```swift
let settings = SelfServicePlusSettingsManager.shared

// Get values with type safety and custom defaults
let customTimeout: TimeInterval = settings.getValue(for: "CustomTimeout", defaultValue: 300.0)
let debugMode: Bool = settings.getValue(for: "DebugMode", defaultValue: false)

// Check if a key exists in any configuration source
if settings.hasValue(for: "CustomFeatureFlag") {
    let featureEnabled: Bool = settings.getValue(for: "CustomFeatureFlag", defaultValue: false)
}
```

#### Bulk Settings Access

```swift
let settings = SelfServicePlusSettingsManager.shared

// Get all UI hiding settings at once
let uiSettings = settings.getAllUIHidingSettings()
for (key, hidden) in uiSettings {
    print("\\(key): \\(hidden)")
}

// Get all branding settings
let brandingSettings = settings.getAllBrandingSettings()
```

#### Configuration Source Debugging

```swift
let settings = SelfServicePlusSettingsManager.shared

// Check which configuration sources are available
let sources = settings.getConfigurationSources()
print("App Group available: \\(sources["appGroup"] ?? false)")
print("JSON config available: \\(sources["json"] ?? false)")
print("Managed config available: \\(sources["managed"] ?? false)")
```

## Integration Examples

### In the Unified Self Service+ App

```swift
import SelfServicePlusSettings
import SwiftUI

struct ContentView: View {
    private let settings = SelfServicePlusSettingsManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                // Conditionally show sections based on settings
                if !settings.shouldHideApplicationsSection() {
                    ApplicationsView()
                }
                
                if !settings.shouldHideSecurityDashboard() {
                    SecurityDashboardView()
                }
                
                if !settings.shouldHidePatchManagementSection() {
                    PatchManagementView()
                }
            }
            .navigationTitle(settings.getBrandingName() ?? "Self Service+")
        }
    }
}
```

### In Individual Capabilities (Caribou, CatDog, Hoplon)

```swift
import SelfServicePlusSettings

class CaribouManager {
    private let settings = SelfServicePlusSettingsManager.shared
    
    func initialize() {
        // Configure based on shared settings
        if settings.areAdvancedFeaturesEnabled() {
            enableAdvancedCaribouFeatures()
        }
        
        if settings.isAnalyticsDisabled() {
            disableAnalytics()
        }
        
        // Apply branding
        if let brandingName = settings.getBrandingName() {
            updateBranding(name: brandingName)
        }
    }
}
```

## Error Handling

The library provides comprehensive error handling:

```swift
enum SelfServicePlusSettingsError: Error {
    case invalidAppGroup
    case configurationFileNotFound(URL)
    case invalidConfigurationData
    case keyNotFound(String)
    case unsupportedValueType
}
```

## App Group Setup

To enable shared settings between processes, configure the App Group entitlement:

### Xcode Configuration
1. Select your target
2. Go to Signing & Capabilities
3. Add "App Groups" capability
4. Add the identifier: `group.com.jamf.selfserviceplus`

### Entitlements File
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.jamf.selfserviceplus</string>
</array>
```

## Testing

Run the test suite to verify functionality:

```bash
swift test
```

The test suite covers:
- Configuration source priority
- Type safety and default values
- JSON configuration loading
- Error handling
- Integration scenarios

## Best Practices

### For Application Developers
- Always use the shared instance: `SelfServicePlusSettingsManager.shared`
- Check settings at appropriate times (app launch, view appearance, etc.)
- Handle missing/default values gracefully
- Use type-safe access methods when available

### For System Administrators
- Use managed configuration (mobileconfig) for enterprise deployments
- Test configuration changes in a non-production environment
- Document any custom configuration keys used
- Monitor logs for configuration loading issues

### For DevOps Teams
- Include the JSON configuration schema in deployment documentation
- Validate JSON configuration files before deployment
- Use version control for configuration file changes
- Set up monitoring for configuration loading errors

## Troubleshooting

### Common Issues

**App Group not accessible:**
- Verify the App Group identifier is correctly configured
- Check entitlements are properly signed
- Ensure all apps use the same App Group identifier

**JSON configuration not loading:**
- Verify file exists at expected location
- Check JSON syntax is valid
- Review file permissions
- Check application logs for error messages

**Settings not updating:**
- Call `reloadConfiguration()` after making changes
- Verify configuration source priority
- Check that the correct configuration source is being updated

## Legacy Support

The library maintains backward compatibility with the previous `SettingsManager` class through a type alias:

```swift
// Both work identically
let newManager = SelfServicePlusSettingsManager.shared
let legacyManager = SettingsManager.shared
```

## Contributing

When adding new configuration keys:

1. Add the key constant to `SelfServicePlusConfigurationKeys`
2. Add a type-safe accessor method to `SelfServicePlusSettingsManager`
3. Update the example JSON configuration
4. Add appropriate tests
5. Update this documentation

## License

[License information here]