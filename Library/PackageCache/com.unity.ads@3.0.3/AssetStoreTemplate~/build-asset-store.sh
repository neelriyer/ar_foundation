#!/bin/bash

set -e

rsync --exclude '*.bak' -rv AssetStoreTemplate~/asset-store-template/ build
rsync --exclude '*.bak' -rv Plugins/ build/Assets/Plugins/

mcs -out:build/Assets/UnityAds/UnityEngine.Advertisements.Android.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll -sdk:2 -d:"ASSET_STORE;UNITY_ANDROID;UNITY_ADS" -recurse:Runtime/Advertisement/*.cs -target:library
mcs -out:build/Assets/UnityAds/UnityEngine.Advertisements.iOS.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll -sdk:2 -d:"ASSET_STORE;UNITY_IOS;UNITY_ADS" -recurse:Runtime/Advertisement/*.cs -target:library
mcs -out:build/Assets/UnityAds/UnityEngine.Advertisements.Editor.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll -sdk:2 -d:"ASSET_STORE;UNITY_EDITOR;UNITY_ADS" -recurse:Runtime/Advertisement/*.cs -target:library
mcs -out:build/Assets/UnityAds/UnityEngine.Advertisements.Unsupported.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll -sdk:2 -d:"ASSET_STORE;UNITY_ADS" -recurse:Runtime/Advertisement/*.cs -target:library

mcs -out:build/Assets/UnityAds/UnityEngine.Monetization.Android.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll,build/Assets/UnityAds/UnityEngine.Advertisements.Android.dll -sdk:2 -d:"ASSET_STORE;UNITY_ANDROID;UNITY_ADS" -recurse:Runtime/Monetization/*.cs -target:library
mcs -out:build/Assets/UnityAds/UnityEngine.Monetization.iOS.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll,build/Assets/UnityAds/UnityEngine.Advertisements.iOS.dll -sdk:2 -d:"ASSET_STORE;UNITY_IOS;UNITY_ADS" -recurse:Runtime/Monetization/*.cs -target:library
mcs -out:build/Assets/UnityAds/UnityEngine.Monetization.Editor.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll,build/Assets/UnityAds/UnityEngine.Advertisements.Editor.dll -sdk:2 -d:"ASSET_STORE;UNITY_EDITOR;UNITY_ADS" -recurse:Runtime/Monetization/*.cs -target:library
mcs -out:build/Assets/UnityAds/UnityEngine.Monetization.Unsupported.dll -r:/Applications/Unity/Unity.app/Contents/Managed/UnityEngine.dll,build/Assets/UnityAds/UnityEngine.Advertisements.Unsupported.dll -sdk:2 -d:"ASSET_STORE;UNITY_ADS" -recurse:Runtime/Monetization/*.cs -target:library

rm -rf temp
mkdir temp

for metaFile in `find build -name '*.meta'`; do
	guid=`grep guid $metaFile | grep -o "[a-z0-9]*$"`
	file=`echo $metaFile | sed s/.meta//`
	path=`echo $file | sed "s/build\///"`
	mkdir temp/$guid
	if [ ! -d $file ]; then
		cp $file temp/$guid/asset
	fi
	cp $metaFile temp/$guid/asset.meta
	echo $path > temp/$guid/pathname
done

tar czf AssetStoreTemplate~/UnityAds.unitypackage -C temp .
rm -rf temp

