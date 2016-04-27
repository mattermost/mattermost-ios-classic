# Mattermost iOS Application 

Note: The iOS app is being upgraded to work with the Mattermost 3.0 server. If you want the latest version compatible with the 2.x server, please compile from the 2.0 release branch. 

iOS application for use with Mattermost server 2.0 and higher (http://www.mattermost.org/download/) 

A reference implementation of this iOS application [is available on iTunes as "Mattermost"](https://itunes.apple.com/us/app/mattermost/id984966508?ls=1&mt=8) 

#### Supported Platforms 

- iOS 9+ iPhone, iPad and iPod Touch devices

#### Requirements for Deployment 

1. Understanding of [Mattermost push notifications](http://docs.mattermost.com/administration/config-settings.html#push-notification-settings). 
2. Experience compiling and deploying iOS applications either to iTunes or an Enterprise App Store 
3. An Apple Developer account and appropriate Apple devices to compiled, test and deploy the application

#### Installation 

1. Install [Mattermost 2.0 or higher](http://www.mattermost.org/download/).
2. Compile and deploy this iOS application to your Enterprise AppStore or publicly.
3. Install [the latest stable release of the Mattermost Push Notifications Server](https://github.com/mattermost/push-proxy) using the private and public keys generated for your iOS application from step 2.
4. In the Mattermost Platform Server go to **System Console** > **Email Settings** > **Push Notifications Server** and add the web address of the Mattermost Push Notifications Server. Set **System Console** > **Send Push Notifications** to `true`.
5. On your iOS device, download and install your app and enter the **Team URL** and credentials based on a team set up on your Mattermost Platform Server


