# Jujupot App ![version]
https://github.com/DominicFung/jujupot-app/blob/master/assets/icon/icon.png

<img src="https://github.com/DominicFung/jujupot-app/blob/master/assets/icon/icon.png?raw=true" align="right" style="border-radius: 25px; margin-left: 30px;"
     alt="Loggistical.ly logo by Dom Fung" width="150" height="150">

This is a demo for the Hommie.io Platform! We enable makers (woodworkers / furniture makers / hobbyist) to integrate IOT while keeping their own branding! No more directing your customers to Philips Hue Smart light app - bring your own brand to the game.

[version]:       https://img.shields.io/badge/version-0.1-green

## Getting hommieoconfiguration.dart
Go to the [Hommie.io Makers Portal](https://makers.hommie.io)

Click on "Download .dart file"

<p align="center">
<img src="https://github.com/DominicFung/jujupot-app/blob/master/readme-assets/Screen%20Shot%202022-01-28.png?raw=true" align="center"
     alt="Screenshot of Logistical.ly" width="830" height="390">
</p>

move the file to the `lib` folder.

<br>

## Generating icons:
add the icon to ```assets\icon\icon.png```

run:
```
flutter pub run flutter_launcher_icons:main
```

## Run in release

To Install the app in "release" mode (without the mac tether):
```
flutter run --release
```