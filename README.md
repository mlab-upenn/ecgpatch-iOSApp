ecgpatch-iOSApp
===============

Compiled Using XCode 4.3.2
Do not try to run this project on older versions as the Core Plot Api may not compile in older versions.
In order to run this project in Xcode,
Open ecgpatch-iOSApp->mlabProject3->mlabProject3.xcodeproj

This will open the Project in Xcode.
Use 'Run' button on the top left to run the app on desired target.
Running the App on iPad (iOS device) will require a valid certificate to be installed.

Folder Structure (when the project is opened):
Libs: Core Plot Library.
mlabProject->
1.Bluetooth: Core Bluetooth Files. This files contain the call backs and main functions for Core Bluetooth. They have not been implemented in detail.
2.Models: CoreData model files.
3.ViewControllers: .h and .m files for View Controllers
4.Views: all xibs
5:Supporting Files->Resources: Images and other data files.

Note: Make sure following frameworks are added to the project.
	CoreBluetooth,AVFoundation,Quartzcore,UIKit,Foundation,CoreData,CoreGraphics.
