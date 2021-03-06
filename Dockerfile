FROM debian:jessie

ENV ANDROID_COMPILE_SDK "23"
ENV ANDROID_BUILD_TOOLS "23.0.1"
#ENV ANDROID_SDK_TOOLS "26.1.1"
#ENV SDK_LINK https://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS}-linux.tgz
ENV SDK_LINK "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ENV SDK_HASH "444e22ce8ca0f67353bda4b85175ed3731cae3ffa695ca18119cbacef1c1bea0"

ENV ANDROID_HOME=$PWD/android-sdk-linux
ENV PATH=$PATH:$PWD/android-sdk-linux/platform-tools/

RUN apt-get update && apt-get install -y curl

RUN echo 'deb http://http.debian.net/debian jessie-backports main' >> /etc/apt/sources.list
RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh

RUN apt-get update
RUN apt-get install -t jessie-backports -y openjdk-8-jdk
RUN apt-get install -y nodejs \
                       sudo \
                       wget \
                       tar \
                       unzip \
                       lib32stdc++6 \
                       lib32z1 \
    && apt-get clean

RUN npm install -g react-native-cli yarn && npm cache clean -g

RUN wget --progress=bar:force:noscroll --output-document=android-sdk.zip $SDK_LINK && \
    echo "$SDK_HASH android-sdk.zip" | sha256sum --quiet --check || ( echo 'Corrupt or malicious download, aborting' ; exit 1 ) && \
    #tar --extract --gzip --file=android-sdk.zip && \
    unzip android-sdk.zip -d $ANDROID_HOME && \
    rm android-sdk.zip -fr

RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses && \
    $ANDROID_HOME/tools/bin/sdkmanager  "build-tools;23.0.2" \
                                        "build-tools;25.0.2" \
                                        "cmake;3.6.4111459"  \
                                        "ndk-bundle"         \
                                        "platform-tools" \
                                        "platforms;android-23" \
                                        "build-tools;23.0.1" \
                                        "build-tools;26.0.2" \
                                        "extras;android;m2repository" \
                                        "extras;google;m2repository" \
                                        --verbose 

ENV ANDROID_NDK $ANDROID_HOME/ndk-bundle
