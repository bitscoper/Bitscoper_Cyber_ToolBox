`dart run rename setAppName --targets linux --value "Bitscoper_Cyber_ToolBox"`

`dart run rename setAppName --targets android,macos,ios,windows,web --value "Bitscoper Cyber ToolBox"`

`dart run rename setBundleId --targets linux,android,macos,ios,windows,web --value "bitscoper.bitsoper_cyber_toolbox"`

`dart run flutter_launcher_icons`

`dart run flutter_native_splash:create`

`keytool -genkey -v -keystore ~/Software\ Laboratory/Bitscoper\ Cyber\ ToolBox/KeyStore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias Bitscoper_Cyber_ToolBox`

`base64 ~/Software\ Laboratory/Bitscoper\ Cyber\ ToolBox/KeyStore.jks > ~/Software\ Laboratory/Bitscoper\ Cyber\ ToolBox/KeyStore.b64`