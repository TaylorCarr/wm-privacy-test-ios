# Psm iOS

This repository houses the iOS SDK for Psm. This readme file is intended for the Psm development team on the development process for the Psm SDK. For a reference on how to use the SDK, please refer to the [docs](http://docs.wmcdp.io/docs/prism/ios/gettingstarted/) and the [reference app](https://github.com/turnercode/prism-ref-app-ios).

# General Contribution

When making changes to the `prism-ios` repo, please follow the following steps:

1. Checkout the develop branch: `git checkout develop`
2. Pull in the latest changes for the develop branch: `git pull`
3. Checkout a new branch with the format "CDP-<TICKET_NUM>/<SHORT_DESCRIPTION>": `git checkout -b CDP-1127/ExampleBranch`
4. Make the necessary code changes and please add any relevant unit and integration tests.
5. Create a pull request against the `develop` branch and once you get approvals, go ahead and merge.

# Managing Dependencies

1. When adding a dependency to the psm library, make sure you add the dependency in both the `Package.swift` and the `PrismiOS.podspec` files (for Swift Package Manager and Cocoapods support, respectively). 

# Creating a Release

1. When we are ready to create a release, we need to first upgrade the version numbers in code and the cocoapods file. Specfically, update the `PrsmLibrary.swift` and `PrismiOS.podspec` file.
2. Run the following command to make sure that the podspec changes are valid: `pod lib lint PrismiOS.podspec --sources=https://github.com/turnercode/prism-pod-specs.git --allow-warnings --configuration=Debug`
3. Create a pull request with the changes from step 1. Once approved, go ahead and merge.
4. After merging the changes, create a release by going to the the following link: https://github.com/turnercode/prism-ios/releases
5. Run the following to validate that the pod changes made are valid: `pod spec lint PrismiOS.podspec --sources=https://github.com/turnercode/prism-pod-specs.git --allow-warnings --configuration=Debug`
6. Finally, push the changes to the internal pod-spec repo: `pod repo push prism-pod-specs PrismiOS.podspec`
