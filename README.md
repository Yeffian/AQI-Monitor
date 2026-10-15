## AQI Monitor

A simple Swift-based toolbar application that displays information about the air quality in the users current location.

![Demo](./screenshot.jpg)

With all the haze and rapidly rising AQI stuff going on, thought this might be a useful little tool to have right on my toolbar instead of having to fight through websites.

This project uses [Open Meteo API Weather API](https://open-meteo.com) for all AQI information.


### Setup and Installation

Unzip the aqi_monitor file from the [Releases](https://github.com/Yeffian/AQI-Monitor/releases/tag/v1.0.0) tab into your Applications folder.

Once it has been unzipped, remove the quarantine tag so your Mac can open the file:
```
  xattr -dr com.apple.quarantine /Applications/aqi_monitor.app
```

Alternatively, try to open the app once, let it get blocked, and then set the app to Open Anyways in your System Settings.

This application only runs on macOS 13 or later.