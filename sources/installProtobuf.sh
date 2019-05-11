#!/bin/bash
if [[ $EUID -eq 0 ]]; then
   echo "This script must be run as NON root" 
   exit 1
fi
# instructions from nvidia forum
# https://devtalk.nvidia.com/default/topic/1046492/tensorrt/extremely-long-time-to-load-trt-optimized-frozen-tf-graphs/post/5315675/#5315675
# download files
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protobuf-python-3.6.1.zip

wget https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-aarch_64.zip

# unzip them
unzip protoc-3.6.1-linux-aarch_64.zip -d protoc-3.6.1
unzip protobuf-python-3.6.1.zip
# Update the protoc
sudo cp protoc-3.6.1/bin/protoc /usr/bin/protoc
# verify version number
echo "Verfiy version number"
protoc --version
# BUILD AND INSTALL THE LIBRARIES
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
cd protobuf-3.6.1/
./autogen.sh
./configure

NUM_CPU=$(nproc)

make -j$(($NUM_CPU - 1))

make check
sudo make install

# if old version exists these steps may be required
# Remove unnecessary links to the old version
#    sudo rm /usr/lib/aarch64-linux-gnu/libprotobuf.a
#    sudo rm /usr/lib/aarch64-linux-gnu/libprotobuf-lite.a
#    sudo rm /usr/lib/aarch64-linux-gnu/libprotobuf-lite.so
#    sudo rm /usr/lib/aarch64-linux-gnu/libprotobuf.so

# Move old version of the libraries to the same folder where the new ones have been installed, for clarity
#    sudo cp -d /usr/lib/aarch64-linux-gnu/libproto* /usr/local/lib/
#    sudo rm /usr/lib/aarch64-linux-gnu/libproto*

# Refresh shared library cache
sudo ldconfig
cd ..

# Check the updated version
echo "Verfiy version number - again ?"
protoc --version

# # reboot -- then do part two
# echo "reboot -- then do part two"

cd protobuf-3.6.1/python/
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

# Fix setup.py to force compilation with c++11 standard
echo "Fixing setup.py to force c++11 standard"

sed -i '205s/if v:.*/#if v:/' setup.py
sed -i "206s/  extra_compile_args.append('-std=c++11')/#  extra_compile_args.append('-std=c++11')/" setup.py
sed -i "207s/elif os.getenv('KOKORO_BUILD_NUMBER') or os.getenv('KOKORO_BUILD_ID'):/#elif os.getenv('KOKORO_BUILD_NUMBER') or os.getenv('KOKORO_BUILD_ID'):/" setup.py
sed -i "208s/  extra_compile_args.append('-std=c++11')/extra_compile_args.append('-std=c++11')/" setup.py
echo "Done"

# Build, test and install
sudo apt-get -y install python3-dev
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
sudo python3 setup.py install --cpp_implementation

# Make the cpp backend a default one when user logs in
sudo sh -c "echo 'export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp' >> /etc/profile.d/protobuf.sh"

clear
printf "\n\n\nReboot to load ProtoBuf\n\n\n"

