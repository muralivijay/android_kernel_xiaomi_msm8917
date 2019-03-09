#!/bin/bash
# Author- Muralivijay, bitrvmpd

# Set Message Color Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
WHITE='\033[1m'
NC='\033[0m'

# Clear Screen before staring our script
clear

# Heading
echo -e "${WHITE}###########################################${NC}"
echo -e "${WHITE}##### rolex Kernel - Build Script  ########${NC}"
echo -e "${WHITE}###########################################${NC}"

# Any2kernel2
echo -e "${GREEN}Clone Any2kernel2 if you don,t have${NC}"
git clone https://github.com/muralivijay/AnyKernel2.git -b pie-rolex ~/AnyKernel2

# Toolchain
echo -e "${GREEN}Clone aarch64-linux-android-4.9 toolchain if you don,t have${NC} "
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b master ~/aarch64-linux-android-4.9

# Make clean build
echo -e "${blu}${BLUE}Make clean build?${NC}${txtrst}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) make clean && make mrproper; break;;
        No ) break;;
    esac
done

# Make Sure Cleanup Any2kernel dir build
echo -e "${GREEN} Check your Home dir Any2kernel_teamlions Cloned ${NC}           "
echo -e "${GREEN} Make sure run cleanup.sh script if you are clean building ${NC} "
echo -e "${GREEN} Else when Compress zip it will become Dirty pack Remember ${NC} "
echo -e "${RED} Do it first ${NC}"
echo -e "${BLUE} Or ==>experiment<== you can build kernel with dirty but any2kernel_teamlions must be run clean step before doing this ${NC}"
echo -e "${blu}${BLUE} Are You Done this step ?${NC}${txtrst}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo -e "${GREEN}Good You can Continue to build${NC}" ; break;;
        No ) echo -e "${RED}You must run Clean step before building kernel. now stoping build${NC} " && exit ; break;;
    esac
done

# CCACHE configuration
# ====================
# If you want you can install ccache to speedup recompilation time.
# In ubuntu just run "sudo apt-get install ccache".
# By default CCACHE will use 2G, change the value of CCACHE_MAX_SIZE
# to meet your needs.
if [ -x "$(command -v ccache)" ]
then
  # If you want to clean the ccache
  # run this script with -clear-ccache
  if [[ "$*" == *"-clear-ccache"* ]]
  then
    echo -e "\n\033[0;31m> Cleaning ~/.ccache contents\033[0;0m"
    rm -rf ~/.ccache
  fi
  # If you want to build *without* using ccache
  # run this script with -no-ccache flag
  if [[ "$*" != *"-no-ccache"* ]]
  then
    export USE_CCACHE=1
    export CCACHE_DIR=~/.ccache
    export CCACHE_MAX_SIZE=2G
    echo -e "\n> $(ccache -M $CCACHE_MAX_SIZE)"
    echo -e "\n\033[0;32m> Using ccache, to disable it run this script with -no-ccache\033[0;0m\n"
  else
    echo -e "\n\033[0;31m> NOT Using ccache, to enable it run this script without -no-ccache\033[0;0m\n"
  fi
else
  echo -e "\n\033[0;33m> [Optional] ccache not installed. You can install it (in ubuntu) using 'sudo apt-get install ccache'\033[0;0m\n"
fi

# Want to use a different toolchain? (Linaro, UberTC, etc)
# ==================================
# point CROSS_COMPILE to the folder of the desired toolchain
# don't forget to specify the prefix. Mine is: aarch64-linux-android-
CROSS_COMPILE=~/aarch64-linux-android-4.9/bin/aarch64-linux-android-

# Are we using ccache?
if [ -n "$USE_CCACHE" ]
then
  CROSS_COMPILE="ccache $CROSS_COMPILE"
fi

# Export ARCH-arm64 & Launch rolex
echo -e "${GREEN} Config Kernel if you want add or disable any driver or feature${NC} "
echo "                                                                "
export ARCH=arm64 && export SUBARCH=arm64 && make rolex_defconfig && make menuconfig

# Build Process
echo -e "${GREEN}> Opening rolex_config file...\n${NC}"
echo -e ">${GREEN} Starting kernel compilation using${NC} ${BLUE}rolex_defconfig${NC} ${GREEN}file...\n${NC}"
start=$SECONDS
  CROSS_COMPILE=$CROSS_COMPILE make -j$( nproc --all )

# Get current kernel version
KERNEL_VERSION=$(head -n3 Makefile | sed -E 's/.*(^\w+\s[=]\s)//g' | xargs | sed -E 's/(\s)/./g')
echo -e "\n\n> ${GREEN}Packing rolex Kernel v$KERNEL_VERSION\n\n${NC}"
# Pack the kernel as a flashable TWRP zip. Pie Edition
~/AnyKernel2/build.sh $KERNEL_VERSION PIE

end=$SECONDS
duration=$(( end - start ))
printf "\n\033[0;33m> Completed in %dh:%dm:%ds\n" $(($duration/3600)) $(($duration%3600/60)) $(($duration%60))
echo -e "=====================================\n"
