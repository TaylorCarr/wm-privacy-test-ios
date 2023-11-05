# FeatureFlagging
`FeatureFlagging` is a Swift Package library containing feature flagging functionality for determining feature availability for iOS users. This library may be added directly to an Xcode project or may be added as a dependency within a separate Swift Package.

## Publishing a new version from GitHub

From the main page of this repository, go to the [Releases](https://github.com/turnercode/prism-feature-flagging-ios/releases) tab. Click on the **Draft a new release** button.

In the "Tag version" field, type a version number for your release. Versions are based on Git tags. Use a tag that fits within semantic versioning. Use the drop-down menu to select the branch that contains the version you want to release. **Optional:** Type a title and description for your release. If you're ready to publicize your release, click **Publish release**. To work on the release later, click **Save draft**.

## Adding as dependency to Xcode project

To add `FeatureFlagging` as a dependency to your Xcode project, select `File` > `Swift Packages` > `Add Package Dependency` and enter its repository URL. You can also navigate to your target’s `General` pane, and in the “Frameworks, Libraries, and Embedded Content” section, click the + button. In the “Choose frameworks and libraries to add” dialog, select `Add Other`, and choose `Add Package Dependency`.

Once Xcode has verified the URL actually refers to a Swift package you can define the rules on what version of the package you want to import. You can either specify which version you want to use by choosing the version option which will refer to the releases of the package. Or you can choose a specific branch of the repository or even a specific commit. After pressing **Next**, Xcode will resolve the package and present you with the choice of products of the package you want to add. After pressing **Finish**, Xcode will add the package to your project and it will appear in the project navigator.

## Adding as a dependency to another Swift Package

To add `FeatureFlagging` as a dependency to another Swift Package, open that other Swift Package's `Package.swift` manifest file. Each package has a name and a list of targets. Your executable has a regular target and a test target. The regular target is your executable or library, whereas the test target is a test suite.

Before you update it, your other package's `Package.swift` file should look like the following:
```
// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
        
  ],
  targets: [
    .target(
        name: "MyPackage",
        dependencies: []),
    .testTarget(
        name: "MyPackageTests",
        dependencies: ["MyPackage"]),
  ]
)
```

To add `FeatureFlagging` as a dependency, you need three pieces of information: the URL of this repository, the version number to add, and the name (i.e., `FeatureFlagging`). Add the following line to your manifest within the dependencies array:


`.package(url: "https://github.com/turnercode/prism-feature-flagging-ios.git", from: "[version]")`

Next, add the package name `FeatureFlagging` to the list of named dependencies in your package's target:

```
.target(
    name: "MyPackage",
    dependencies: ["FeatureFlagging"]),
```
Your updated `Package.swift` file should look as follows:
```
// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(url: "https://github.com/turnercode/prism-feature-flagging-ios.git", 
        from: "[version]")
  ],
  targets: [
    .target(
        name: "MyPackage",
        dependencies: ["FeatureFlagging"]),
    .testTarget(
        name: "MyPackageTests",
        dependencies: ["MyPackage"]),
  ]
)
```
Save your updated file, and use your package as desired.
