# this version
VERSION=10.0
HTDOCS=/Users/builder/htdocs

flutter pub get
flutter clean

# sed -i '' "s/DEBUG-VERSION/$VERSION-$BUILD_NUMBER/g" lib/version.dart

# APK
flutter build apk --release --build-name $VERSION --build-number $BUILD_NUMBER
cp build/app/outputs/apk/release/app-release.apk ${HTDOCS}/bibles/android/Bible-${BUILD_ID}-${BUILD_NUMBER}.apk
# resign with regular signature
~/Library/Android/sdk/build-tools/30.0.2/apksigner sign --ks ../tools/build/keystore --ks-key-alias "tecarta apps" --ks-pass pass:Secur1ty --key-pass pass:Secur1ty ${HTDOCS}/bibles/android/Bible-${BUILD_ID}-${BUILD_NUMBER}.apk
"../tools/build/makeIndex.sh" "Android Products" "${HTDOCS}/bibles/android"

# Android 
flutter build appbundle --build-name $VERSION --build-number $BUILD_NUMBER
echo python ~/tools/playstore/upload.py com.tecarta.TecartaBible build/app/outputs/bundle/release/app-release.aab
python ~/tools/playstore/upload.py com.tecarta.TecartaBible build/app/outputs/bundle/release/app-release.aab

# iOS
cd ios && pod install && cd ..
security -v unlock-keychain -p goph3rw00d ~/Library/Keychains/login.keychain
flutter build ios --release --build-name $VERSION --build-number $BUILD_NUMBER
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme "Runner" -sdk iphoneos -configuration "Release" archive -archivePath Runner.xcarchive -allowProvisioningUpdates
xcodebuild -project Runner.xcodeproj -exportArchive -archivePath Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath . -allowProvisioningUpdates
xcrun altool --upload-app -f Runner.ipa -t ios -u mike@tecarta.com -p nzqk-uoya-lzei-gjmn
cd ..
