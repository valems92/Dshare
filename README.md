# Dshare

Prerequisites :
1. Download the latest config file form https://console.firebase.google.com/project/dshare-ac2cb/settings/general/ios:com.Dshare
2. Install cocaPods https://cocoapods.org/

Get Started :
1. git clone https://github.com/valems92/Dshare.git
2. open project in xCode: doubleclick on Dshare.xcworkspace file
3. cd Dshare/Dshare
4. pod install
5. replace config file (GoogleService-Info.plist) with the one you downloaded


When you do some changes and want to push it, please make sure you don't push the 'Dshare/Dshare.xcodeproj/project.pbxproj' file as well (After the 4 & 5 steps in the Get started, this file is marked as changed - I think it contains an unique ID of the config file for each of us)


Sometimes xcode can't see files that are physically exist, so you have to add them to your project at right click on the project -> Add Files To "Dshare"
