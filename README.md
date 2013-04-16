# WWDCAlert #

App that alerts you if the content of the [WWDC Webpage](https://developer.apple.com/wwdc/) changes.

## About ##

The idea of this app is derived from [@rmatta](https://twitter.com/rmatta)'s [WWDCAlertApp](https://github.com/rmatta/WWDCAlertApp). It periodically downloads the [WWDC Webpage](https://developer.apple.com/wwdc/) and compares it's content to the previously downloaded one. If it has changed a local notification gets triggered.

The following topics describe some basic points. In all those points the app differs to the one by Rahul.     

### Background Execution / Refresh Interval ###

The App uses the VOIP background mode. In it's keepalive handler it reloads the webpage and performs the comparison. It gets triggered by the system every 10 minutes.

VOIP apps get launched automatically after (re-)stating the iOS device or the app has been terminated due to memory pressure and memory has become available again.

### Notifications / Settings ###

In the settings app you can choose notification sounds or disable notifications at all. Two nearly 30 second long alarm sounds are included, both taken from [The Clock App](http://www.mecking.net/ios-apps/the-clock-app).

These Notifications can be configured:

- Content Change Notification   
  This is the important one. It is repeated up to
  60 times on a one minute interval until the app
  gets launched. Choose an annoying sound :-)
- App Not Running Notification   
  This one informs you that the app has not been
  running for more than 10 minutes. This should
  never happen. 
- Background Launch Notification   
  This is the least important notification. I
  recommend to set this to silent or disable it at
  all.

There is also an option to set the URL to check. The default is [https://developer.apple.com/wwdc/](https://developer.apple.com/wwdc/). The default will be restored if this is set to an empty string.

### System Resources / Memory Usage ###

To reduce the memory footprint, the webview gets removed when the app moves into the background.

In the background, the app will be suspended. Every 10 min it gets resumed to reload the html source of the webpage. No linked resources (Images, Scripts, Stylesheets) will be loaded. The system tries to awake the app at times when the radio (cellular or wifi) is already active to reduce battery usage. Other power consuming components like CoreLocation are not used.

Therefore the used system resources are very low.

## Build Instructions ##

You need Xcode, [Cocoapods](http://www.cocoapods.org/), and at least one iOS device.

1. Clone
2. Run "pod install"
3. Open "WWDCAlert.xcworkplace"
4. Run on the device

Don't even think about submitting it to the AppStore.

## License ##

The software is distributed under MIT license (see License.txt).

Don't blame me if you will not get a ticket for whatever reason :-)

## Contact ##

ADN: [@sptim](https://alpha.app.net/sptim) (English) or [@sptim_de](https://alpha.app.net/sptim_de) (German)