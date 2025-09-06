# iOS App Files

## Required File

Place your iOS app bundle here with the exact name:

**`MyApp.app`** (directory/bundle)

## How to Add Your iOS App

1. **Build your iOS app** or download from CI/CD
2. **Copy the app bundle** to this directory:
   ```bash
   cp -r /path/to/your/MyApp.app apps/ios/
   ```
3. **Verify placement**:
   ```bash
   ls -la apps/ios/MyApp.app
   ```

## Expected Structure

```
apps/ios/
├── README.md              # This file
└── MyApp.app/            # Your iOS app bundle (REQUIRED)
    ├── Info.plist
    ├── MyApp              # Binary
    └── ... (other app files)
```

## App Configuration

This app bundle will be used by Maestro as configured in `maestro.yaml`:

```yaml
app:
  ios:
    appId: "com.scopex.scopexmobile"
    appPath: "apps/ios/MyApp.app"
```

## Important Notes

- **Bundle Type**: Must be a `.app` bundle (directory), not an `.ipa` file
- **Simulator Build**: Ensure it's built for iOS Simulator (x86_64/arm64)
- **Exact Name**: The bundle must be named exactly `MyApp.app`

## Troubleshooting

- **File not found**: Ensure the app bundle is named exactly `MyApp.app`
- **Wrong location**: The app bundle must be directly in `apps/ios/` directory
- **Invalid bundle**: Make sure it's a `.app` bundle, not an `.ipa` archive
- **Architecture**: Verify it's built for iOS Simulator

Run `./setup.sh --check-only` to verify your iOS app is properly placed.
