#!/bin/bash

sudo apt-get install python-pip python-matplotlib python-pil -y

CHECK_ARCH=$(dpkg --print-architecture)

if [[ $CHECK_ARCH =~ arm64 ]]
then
    printf "\nAssuming you have a Jetson TX2. Will install all requirements and install tensorflow-gpu in 10s.\nCancel if system is wrong."
    sleep 7
    sudo apt-get install libhdf5-serial-dev hdf5-tools
    pip3 install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu==1.13.1+nv19.4 --user
else
    printf "\nInstalling tensorflow-gpu with pip3 install tensorflow-gpu\n\n"
    pip3 install tensorflow-gpu
fi

CHECK_TF=$(pip3 freeze | grep tensorflow)

if [ -z "$CHECK_TF" ]
then
      printf "\n[❌]Could not verify if tensorflow is installed. Check manually!"
else
      printf "\n[✅] Verified install.\n"
fi

if [[ -d tf_trt_models/ && -d tf_trt_models/third_party/models/research/object_detection  ]]
then
      printf "\n[✅ ] Directory present. Will skip cloning TRT modules\n"      
else
      printf "\n[❌ ]Currently not present! Will clone\n"
      git clone --recursive https://github.com/NVIDIA-Jetson/tf_trt_models.git
      cd tf_trt_models
      ./install.sh python3
fi

# Exporting object detection module

if grep -Fxq "export PYTHONPATH=\$PYTHONPATH:$PWD/tf_trt_models/third_party/models/research:$PWD/tf_trt_models/third_party/models/research/slim" ~/.bashrc
then
    printf "\nNo need to edit bash\n"
else
    printf "\nNeed to edit bash\n"
    echo "export PYTHONPATH=\$PYTHONPATH:$PWD/tf_trt_models/third_party/models/research:$PWD/tf_trt_models/third_party/models/research/slim" >> ~/.bashrc
fi