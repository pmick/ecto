## Getting Started
1. [Install carthage](https://github.com/Carthage/Carthage#installing-carthage)
2. run `sh bootstrap.sh`

## Adding a Twitch API Client ID
1. Make a new app in the [twitch developer console](https://glass.twitch.tv/console) and get your client ID from the app management console
2. Click on the Twitch scheme in Xcode and hit edit scheme
3. Under Run/Arguments add a new Environment Variable named `API_CLIENT_ID` and the value being the client ID you copied from the twitch developer console
