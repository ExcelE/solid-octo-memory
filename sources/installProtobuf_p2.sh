#!/bin/bash
if [[ $EUID -eq 0 ]]; then
   echo "This script must be run as NON root" 
   exit 1
fi
# instructions from nvidia forum
# https://devtalk.nvidia.com/default/topic/1046492/tensorrt/extremely-long-time-to-load-trt-optimized-frozen-tf-graphs/post/5315675/#5315675

# this is part two, did you do part one ?
# BUILD AND INSTALL THE PYTHON-PROTOBUF MODULE
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
