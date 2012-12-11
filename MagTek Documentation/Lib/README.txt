Combined the iphonesimulator and iphoneos libraries into one using

lipo -create Release-iphoneos/libMTSCRA.a Release-iphonesimulator/libMTSCRA.a -output ./libMTSCRA.a