# this version
VERSION=10.0
HTDOCS=/Users/builder/htdocs


function invalidate {
    label=$(date +"%Y-%m-%d-%H:%M:%S")

    batch='
        {
            "Paths": {
                "Quantity": '1',
                "Items": [ "/index.html" ]
            },
            "CallerReference": "'$label'"
        }';

    eval aws cloudfront create-invalidation --distribution-id E7OQ1EA5XKM4X --invalidation-batch "'"$batch"'"
}

flutter pub get
flutter clean

sed -i '' "s/DEBUG-VERSION/$VERSION-$BUILD_NUMBER/g" lib/version.dart

if [ -e build ]; then
    rm -rf build
fi

# web
echo "building website..."
# flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=true
flutter build web 

sed -i '' "s/main.dart./main.dart.${BUILD_NUMBER}./g" build/web/index.html
sed -i '' "s/flutter_service_worker./flutter_service_worker.${BUILD_NUMBER}./g" build/web/index.html
sed -i '' "s/sourceMappingURL=main.dart./sourceMappingURL=main.dart.${BUILD_NUMBER}./g" build/web/main.dart.js

mv build/web/main.dart.js build/web/main.dart.$BUILD_NUMBER.js
mv build/web/main.dart.js.map build/web/main.dart.$BUILD_NUMBER.js.map
mv build/web/flutter_service_worker.js build/web/flutter_service_worker.$BUILD_NUMBER.js

pushd build/web

for entry in *
do
   if [[ -d  $entry ]]; then
      echo "copying $entry"
      aws s3 cp --recursive --cache-control="max-age=2592000" --acl="public-read" "./$entry" "s3://tecarta-tb10-tecarta-com/$entry/"
   elif [[ "$entry" == "index.html" ]]; then
      aws s3 cp --cache-control="max-age=300" --acl="public-read" "./$entry" s3://tecarta-tb10-tecarta-com/
      aws s3 cp --cache-control="max-age=300" --acl="public-read" "./$entry" s3://tecarta-tb10-tecarta-com/index-${BUILD_NUMBER}.html
   else
      aws s3 cp --cache-control="max-age=2592000" --acl="public-read" "./$entry" s3://tecarta-tb10-tecarta-com/
   fi
done

popd

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
xcrun altool --upload-app -f "Tecarta Bible.ipa" -t ios -u mike@tecarta.com -p nzqk-uoya-lzei-gjmn
cd ..
