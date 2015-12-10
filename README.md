# Mattermost iOS Application 

This iOS Application source code is meant to be used by organizations who self-host [Mattermost](http://www.mattermost.org/download/) as a team communication service. 

To properly encrypt push notifications from your Mattermost Platform Server to your Mattermost iOS Application a proxy, the [Mattermost Push Notification Server](https://github.com/mattermost/push-proxy), needs to be set up with a private key generated using your organization's Apple Developer account. 

#### Requirements 

1. Experience compiling and deploying iOS applications either to an enterprise App Store or publicly
2. An Apple Developer account and appropriate Apple devices to compiled and deploy the application

#### Installation 

1. Install [the latest stable release of the Mattermost Platform Server](http://www.mattermost.org/download/).
2. Compile and deploy this iOS application to your Enterprise AppStore or publicly.
3. Install [the latest stable release of the Mattermost Push Notifications Server](https://github.com/mattermost/push-proxy) using the private and public keys generated for your iOS application from step 2.
4. In the Mattermost Platform Server go to **System Console** > **Email Settings** > **Push Notifications Server** and add the web address of the Mattermost Push Notifications Server
5. On your iOS device, download and install your app and enter the **Team URL** and credentials based on a team set up on your Mattermost Platform Server


