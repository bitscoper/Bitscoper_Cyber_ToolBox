## Name

`dart run rename setAppName --targets linux --value "Bitscoper_Cyber_ToolBox"`

`dart run rename setAppName --targets android,macos,ios,windows,web --value "Bitscoper Cyber ToolBox"`

## ID

`dart run rename setBundleId --targets linux,android,macos,ios,windows,web --value "bitscoper.bitscoper_cyber_toolbox"`

## Icon

`dart run flutter_launcher_icons`

## Splash Screen

`dart run flutter_native_splash:create`

## Android Keystore

`keytool -genkey -v -keystore ~/Laboratory/Bitscoper\ Cyber\ ToolBox/KeyStore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias Bitscoper_Cyber_ToolBox`

`base64 ~/Laboratory/Bitscoper\ Cyber\ ToolBox/KeyStore.jks > ~/Laboratory/Bitscoper\ Cyber\ ToolBox/KeyStore.b64`
