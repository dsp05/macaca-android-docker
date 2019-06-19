FROM ubuntu:18.04

LABEL maintainer="dusongpei@gmail.com"

USER ubuntu

# Specially for SSH access and port redirection
# ENV ROOTPASSWORD macaca

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 80
EXPOSE 443

ENV DEBIAN_FRONTEND noninteractive

# kvm env
ENV RAM 2048
ENV SMP 1
ENV CPU qemu64
ENV DISK_DEVICE scsi
ENV IMAGE /data/disk-image
ENV IMAGE_FORMAT qcow2
ENV IMAGE_SIZE 10G
ENV IMAGE_CACHE none
ENV IMAGE_DISCARD unmap
ENV IMAGE_CREATE 0
ENV ISO_DOWNLOAD 0
ENV NETWORK tap
ENV VNC none
ENV VNC_IP ""
ENV VNC_ID 0
ENV VNC_PORT 5500
ENV VNC_SOCK /data/vnc.sock
ENV TCP_PORTS ""
ENV UDP_PORTS ""

WORKDIR /home/ubuntu

#COPY ./etc/apt/sources.list_backup /etc/apt/sources.list
#RUN apt update

RUN sudo apt-get update && \
    sudo apt-get install -y qemu-kvm qemu-utils bridge-utils dnsmasq uml-utilities iptables wget net-tools && \
    sudo apt-get install -y build-essential git vim make zip unzip curl wget bzip2 ssh openssh-server socat && \
    sudo apt-get install -y openjdk-8-jdk && \
    sudo apt-get install -y software-properties-common && \
    sudo apt-get install -y net-tools iputils-ping dnsutils && \
    sudo apt-get install -y python-dev python-pip  && \
    sudo apt-get install -y apt-utils usbutils locales udev && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean

# Install packages needed for android sdk tools
# RUN dpkg --add-architecture i386 && \
#     apt-get update && \
#     apt-get -y install libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386

# Java Environment Path
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:$PATH

# Install Android SDK Tools
ENV ANDROID_HOME=/usr/local/android-sdk-linux
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin
RUN curl -o sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux.zip -d $ANDROID_HOME > /dev/null

# Install NDK
ENV PATH=$PATH:$ANDROID_HOME/ndk-bundle
RUN yes | sdkmanager "ndk-bundle"

# Install platform tools
ENV PATH=$PATH:$ANDROID_HOME/platform-tools
RUN yes | sdkmanager "platform-tools"

# Install build tools
RUN yes | sdkmanager "build-tools;29.0.0"

# ENV ANDROID_NDK_HOME=$ANDROID_HOME/android-ndk-r14b
# ENV PATH=$PATH:$ANDROID_NDK_HOME
# RUN curl -o ndk-bundle.zip https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip && unzip ndk-bundle.zip -d $ANDROID_HOME > /dev/null

# Accept license
RUN yes | sdkmanager --licenses

# RUN mkdir "$ANDROID_HOME/licenses" || true
# RUN echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
# RUN echo -e "\d56f5187479451eabf01fb78af6dfcb131a6481e" >> "$ANDROID_HOME/licenses/android-sdk-license"
# RUN echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

# Install Android Build Tools and the required version of Android SDK
# You can create several versions of the Dockerfile if you need to test several versions
# RUN ( sleep 4 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --force -a --filter \
#     platform-tool,android-25,android-26,build-tools-25.0.2,build-tools-26.0.1,extra-android-support,extra-android-m2repository,extra-google-m2repository && \
#     echo "y" | android update adb

# RUN which adb
# RUN which android

# Install Gradle
ENV GRADLE_VERSION=5.4.1
ENV GRADLE_HOME=/usr/local/gradle-${GRADLE_VERSION}
ENV PATH=$GRADLE_HOME/bin:$PATH

RUN curl -o gradle-${GRADLE_VERSION}-all.zip -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip && unzip gradle-${GRADLE_VERSION}-all.zip -d /usr/local > /dev/null

# Install NodeJS
ENV NODE_VERSION=10.16.0
ENV PATH=$PATH:/opt/node-v${NODE_VERSION}-linux-x64/bin
RUN curl -o node-v${NODE_VERSION}-linux-x64.tar.xz https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz && tar -C /opt -Jxvf node-v${NODE_VERSION}-linux-x64.tar.xz > /dev/null

RUN npm install -g cnpm --registry=https://registry.npm.taobao.org
ENV CHROMEDRIVER_CDNURL=http://npm.taobao.org/mirrors/chromedriver/
RUN cnpm i -g macaca-cli
RUN cnpm i -g macaca-android
RUN cnpm i -g nosmoke
RUN macaca -v
RUN macaca doctor

# Run sshd
# RUN mkdir /var/run/sshd && \
#     echo "root:$ROOTPASSWORD" | chpasswd && \
#     sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#     sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
#     echo "export VISIBLE=now" >> /etc/profile

# RUN echo "y" | android update sdk -a --no-ui --filter sys-img-x86_64-android-21,Android-21

# VOLUME /data

# ADD entrypoint.sh /entrypoint.sh
# ADD kvmconfig.sh /kvmconfig.sh
# RUN chmod +x /entrypoint.sh
# RUN chmod +x /kvmconfig.sh

# ENTRYPOINT ["/entrypoint.sh"]
