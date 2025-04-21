
# Secure Privacy iOS SDK – Example App

## Overview

This repository demonstrates how to integrate the **Secure Privacy Consent Management SDK** into an iOS application. It provides a working SwiftUI-based implementation of the SDK, showcasing essential features such as consent collection, consent status checks, and package-specific consent validation.

For full SDK documentation, visit:  
[Secure Privacy iOS SDK Documentation](https://docs.secureprivacy.ai/guides/mobile/ios-sdk/)  
[Secure Privacy Website](https://secureprivacy.ai)

## Getting Started

### Obtain Your Application ID

To use the Secure Privacy SDK, you need an **Application ID**.  
Sign up for a **free trial** at [Secure Privacy](https://secureprivacy.ai) to get your **Application ID**.

### Installation

1. Add the following line to your Podfile:
```ruby
pod 'SecurePrivacyMobileConsent'
```
2. Run the following command:
```sh
pod install
```
3. Open the `.xcworkspace` file to launch your project with the integrated SDK.

### Running the Example App

1. Clone this repository:

   ```sh
   git clone https://github.com/secureprivacy/ios-sdk-example
   cd ios-sdk-example
   ```

2. Open the project in Xcode.
3. Build and run the app on a simulator or physical device.

## Features

- Consent Collection: Display consent banner for primary and secondary Application IDs.
- Consent Status Management: Retrieve and check user consent state.
- Package-Specific Consent: Verify if a specific package has consent.
- Event Listening: Track consent status changes.
- Session Management: Reset consent session and reinitialize the SDK.

## Usage

### Initialize the SDK

Call the following on view load:

```swift
let result = await SPConsentEngineFactory.initialise(
    key: SPAuthKey(
        applicationId: Config.primaryAppId,
        secondaryApplicationId: Config.secondaryAppId
    )
)
```

This returns an instance of `SPConsentEngine`.

### Show the Consent Banner

To show the **primary or secondary consent banner**:

```swift
let result = spConsentEngine.showConsentBanner(in: viewController)
```

### Retrieve Consent Status

```swift
let result = spConsentEngine.getConsentStatus(applicationId: selectedAppId)
```

Consent states include:
- **Collected**
- **Pending**
- **UpdateRequired**

### Check Package Consent

```swift
let result = spConsentEngine.getPackage(
    applicationId: selectedAppId,
    packageId: "com.google.ads.mediation:facebook"
)
```

Check `.enabled()` on the result to determine if consent is granted.

### Listen to Consent Events

Register an observer using:

```swift
spConsentEngine.addObserver(code: 1008, observer: self) { event in
    // Handle consent update
}
```

Remove the observer when not needed:

```swift
spConsentEngine.removeObserver(forCode: 1008)
```

### Clear the Consent Session

```swift
spConsentEngine.clearSession()
```

Call this when resetting user preferences or on logout.

### Get Unique Client ID

```swift
let clientId = spConsentEngine.getClientId(applicationId: selectedAppId).data
```

This ID can be used to track consent states in your backend.

## Support

For detailed documentation and additional guidance, visit:  
[Secure Privacy iOS SDK Documentation](https://docs.secureprivacy.ai/guides/mobile/ios-sdk/)

If you encounter any issues, reach out via our website:  
[Secure Privacy](https://secureprivacy.ai)

## License

This project is licensed under the MIT License.

