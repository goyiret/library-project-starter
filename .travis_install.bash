#! /bin/bash

set -o errexit
set -o nounset

download_llvm(){
  echo "Downloading and installing LLVM ${LLVM_VERSION}"

  wget "http://llvm.org/releases/${LLVM_VERSION}/clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-debian8.tar.xz"
  tar -xvf clang+llvm*
  pushd clang+llvm* && sudo mkdir /tmp/llvm && sudo cp -r ./* /tmp/llvm/
  sudo ln -s "/tmp/llvm/bin/llvm-config" "/usr/local/bin/${LLVM_CONFIG}"
  popd
}

download_pcre(){
  echo "Downloading and building PCRE2..."

  wget "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.21.tar.bz2"
  tar -xjvf pcre2-10.21.tar.bz2
  pushd pcre2-10.21 && ./configure --prefix=/usr && make && sudo make install
  popd
}

install-ponyc-master(){
  echo "Building ponyc..."
  make CC="$CC1" CXX="$CXX1" install
}

echo "Installing ponyc build dependencies..."
if [ "${TRAVIS_EVENT_TYPE}" = "cron" ]
then
  echo -e "\033[0;32mInstalling ponyc master\033[0m"
  download_llvm
  download_pcre
  install-ponyc-master
else
  echo -e "\033[0;32mInstalling latest ponyc release\033[0m"
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "8756 C4F7 65C9 AC3C B6B8  5D62 379C E192 D401 AB61"
  echo "deb https://dl.bintray.com/pony-language/ponyc-debian pony-language main" | sudo tee -a /etc/apt/sources.list
  sudo apt-get update
  sudo apt-get -V install ponyc
fi
