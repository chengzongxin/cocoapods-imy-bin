
#### 制作所有依赖库为静态库

```shell
xcodebuild GCC_PREPROCESSOR_DEFINITIONS='$(inherited)'  ARCHS='arm64' OTHER_CFLAGS='-fembed-bitcode -Qunused-arguments' CONFIGURATION_BUILD_DIR=/Users/joe.cheng/cocoapods-imy-bin/Demo-build-temp/bin-archive/Demo/build-arm64 clean build -configuration Debug -target Demo -project ./Pods/Pods.xcodeproj 2>&1

xcodebuild GCC_PREPROCESSOR_DEFINITIONS='$(inherited)'  -sdk iphonesimulator ARCHS='x86_64'  CONFIGURATION_BUILD_DIR=/Users/joe.cheng/cocoapods-imy-bin/Demo-build-temp/bin-archive/Demo/build-x86_64 clean build -configuration Debug -target Demo -project ./Pods/Pods.xcodeproj 2>&1

lipo -create -output ios/AFNetworking.framework/Versions/A/AFNetworking build-arm64/libAFNetworking.a build-x86_64/libAFNetworking.a
```



#### 上传文件

```shell
curl http://localhost:8080/frameworks -F "name=Aspects" -F "version=1.4.1" -F "annotate=Aspects_1.4.1_log" -F "file=@bin-zip/bin_Aspects_1.4.1.zip"
```

#### 删除文件

```shell
curl -v -X DELETE http://localhost:8080/frameworks/THKBusinessViewKit/0.1.0
```


