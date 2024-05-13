#!/bin/bash

__usage="
Usage: build_syterkit [OPTIONS]
Build Rockchip syterkit image.
The target files idbloader.img and syterkit.itb will be generated in the build/syterkit folder of the directory where the build_syterkit.sh script is located.

Options: 
  -c, --config BOARD_CONFIG     Required! The name of target board which should be a space separated list, which defaults to firefly-rk3399_defconfig, set none to use prebuild syterkit image.
  -h, --help                    Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    config="firefly-rk3399_defconfig"
    workdir=$(pwd)/build
    u_boot_url="https://gitlab.arm.com/systemready/firmware-build/syterkit.git"
    rk3399_bl31_url="https://github.com/rockchip-linux/rkbin/raw/master/bin/rk33/rk3399_bl31_v1.36.elf"
    log_dir=$workdir/log
    nonfree_bin_dir=${workdir}/../bin
}

local_param(){
    if [ -f $workdir/.param ]; then
        config=$(cat $workdir/.param | grep config)
        config=${config:7}
    fi
}

parseargs()
{
    if [ "x$#" == "x0" ]; then
        return 0
    fi

    while [ "x$#" != "x0" ];
    do
        if [ "x$1" == "x-h" -o "x$1" == "x--help" ]; then
            return 1
        elif [ "x$1" == "x" ]; then
            shift
        elif [ "x$1" == "x-c" -o "x$1" == "x--config" ]; then
            config=`echo $2`
            shift
            shift
        else
            echo `date` - ERROR, UNKNOWN params "$@"
            return 2
        fi
    done
}

buildid=$(date +%Y%m%d%H%M%S)
builddate=${buildid:0:8}

ERROR(){
    echo `date` - ERROR, $* | tee -a ${log_dir}/${builddate}.log
}

LOG(){
    echo `date` - INFO, $* | tee -a ${log_dir}/${builddate}.log
}

build_syterkit() {
    cd $workdir
    
    if [ -f ${workdir}/bootloader.bin ];then rm ${workdir}/bootloader.bin; fi
    if [ -f ${workdir}/bl31.bin ];then rm ${workdir}/bl31.bin; fi
    if [ -f ${workdir}/scp.bin ];then rm ${workdir}/scp.bin; fi
    if [ -f ${workdir}/splash.bin ];then rm ${workdir}/splash.bin; fi
    if [ -f ${workdir}/exlinux.conf ];then rm ${workdir}/exlinux.conf; fi
    
    if [ -d syterkit ];then
        cd syterkit
        remote_url_exist=`git remote -v | grep "origin"`
        remote_url=`git ls-remote --get-url origin`
        if [[ ${remote_url_exist} = "" || ${remote_url} != ${SYTERKIT_REPO} ]]; then
            cd ../
            rm -rf $workdir/syterkit
            git clone --depth=1 -b ${SYTERKIT_BRANCH} ${SYTERKIT_REPO} syterkit
            if [[ $? -eq 0 ]]; then
                LOG "clone syterkit done."
            else
                ERROR "clone syterkit failed."
                exit 1
            fi
        fi
    else
        git clone --depth=1 -b ${SYTERKIT_BRANCH} ${SYTERKIT_REPO} syterkit
        LOG "clone syterkit done."
    fi

    cd syterkit && mkdir build-${config} && cd build-${config}
    cmake -DCMAKE_BOARD_FILE=${config}.cmake -DCMAKE_BUILD_TYPE=Debug ..
    make -j$(nproc)
    cp ${workdir}/../configs/extlinux.conf ${workdir}
    sed -i "s|BOARD_NAME|${DEVICE_DTS}|g" ${workdir}/extlinux.conf
    cp board/${BOARD}/${SYTERKIT_TYPE}/${SYTERKIT_TYPE}_bin_card.bin ${workdir}/bootloader.bin
    cp ../board/${BOARD}/${SYTERKIT_TYPE}/bl31/bl31.bin ${workdir}/bl31.bin
    cp ../board/${BOARD}/${SYTERKIT_TYPE}/scp/scp.bin ${workdir}/scp.bin
    cp ../board/${BOARD}/${SYTERKIT_TYPE}/splash/splash.bin ${workdir}/splash.bin

}

set -e

default_param
local_param
parseargs "$@" || help $?

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
if [ ! -d ${log_dir} ];then mkdir -p ${log_dir}; fi
if [ ! -f $workdir/.done ];then
    touch $workdir/.done
fi
sed -i 's/syterkit//g' $workdir/.done
LOG "build syterkit..."

SYTERKIT_BRANCH="dev"
SYTERKIT_REPO="https://github.com/YuzukiHD/SyterKit"
SYTERKIT_TYPE="extlinux_boot"

build_syterkit

LOG "The syterkit.itb and idbloader.img are generated in the ${workdir}/syterkit."
echo "syterkit" >> $workdir/.done
