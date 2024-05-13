# AvaotaSBC-openEuler

There is no 简体中文.

This repository provides scripts for building openEuler image for AvaotaSBC.

## How To Download the Latest Image

[Release]()

## How to Build Images

>![](documents/public_sys-resources/icon-notice.gif) **NOTICE:**  
>Five openEuler versions are currently supported for Avaota-A1, i.e., 22.03 LTS, 22.03 LTS SP1, 22.03 LTS SP2 and 22.03 LTS SP3.
>When building an image with desktop environment, you need to pay attention to three issues:
>1. Need to set the parameter `-s/--spec`. Please refer to the description of this parameter for details. The corresponding -r/-repo parameter needs to be set at the same time.

### Prepare the Environment
- OS: openEuler or Fedora
- Hardware: AArch64 hardware, Such as the RaspberryPi or RK3399/RK3588 SBCs.

### Run the Scripts to Build Images

Run the following command to build images:

`sudo bash build.sh -n NAME -k KERNEL_URL -b KERNEL_BRANCH -c BOARD_CONFIG -r REPO_INFO -d DTB_NAME -s SPEC`

**NOTE: You can directly execute "sudo bash build.sh" to build an openEuler 20.03 LTS image for Avaota-A1 with the script's default parameters.**

After the script is executed, the following files will be generated in the build/YYYY-MM-DD folder of the directory where the script is located:

- A compressed RAW original image：openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz

The meaning of each parameter:

1. -n, --name IMAGE_NAME

    The image name to be built. For example, `openEuler-22.03-LTS-Avaota-A1-aarch64-alpha1` or `openEuler-21.09-Firefly-RK3399-aarch64-alpha1`.


2. -k, --kernel KERNEL_URL

   The URL of kernel source repository, which defaults to `https://github.com/AvaotaSBC/linux.git`. You can set the parameter as `git@github.com:AvaotaSBC/linux.git` or `git@github.com:114514/linux.git` according to the requirement.

3. -b, --branch KERNEL_BRANCH

    The branch name of kernel source repository, which defaults to openEuler-20.03-LTS. According to the -k parameter, you have the following options:

    - -k https://github.com/AvaotaSBC/linux.git
        - linux-5.10-oe

4. -c, --config BOARD_CONFIG

    To use a Syterkit on the Avaota-A1, you can set this option to 'avaota-a1'.

5. -r, --repo REPO_INFO

    The URL/path of target repo file, or the list of repositories' baseurls. Note that, the baseurls should be separated by space and enclosed in double quotes.
    Examples are as follows:

    - The URL of target repo file: `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-22.03-LTS/generic.repo`.

    - The path of target repo file:
        `./openEuler-22.03-LTS.repo`：for building openEuler 22.03 LTS image, refer to <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-22.03-LTS/generic.repo> for details.

    - List of repo's baseurls: `http://repo.openeuler.org/openEuler-22.03-LTS/OS/aarch64/ http://repo.openeuler.org/openEuler-22.03-LTS/EPOL/aarch64/`.

6. -d, --device-tree DTB_NAME

    The device name in the kernel device-tree whitch is a little different from the board name. It corresponds to the `DTB_NAME.dts` file under the [kernel/arch/arm64/boot/dts/allwinner](https://github.com/AvaotaSBC/linux/tree/linux-5.10-oe/arch/arm64/boot/dts/allwinner) folder. The default is `sun55i-t527-avaota-a1`.

7.  -s, --spec SPEC

    Specify the image version:
    - `headless`, image without desktop environments.
    - `xfce`, image with Xfce desktop environment and related software including CJK fonts and IME.
    - `ukui`, image with UKUI desktop environment and fundamental software without CJK fonts and IME.
    - `dde`, image with DDE desktop environment and fundamental software without CJK fonts and IME.
    - The file path of rpmlist, the file contains a list of the software to be installed in the image, refer to [rpmlist](./scripts/configs/rpmlist) for details.

    The default is `headless`.

8.  -h, --help

    Displays help information.

Applicable AvaotaSBC SBCs:

1. Avaota-A1

    The tested versions are as follows:

    - openEuler-22.03-LTS, run the following command:

        `sudo bash build.sh -n openEuler-22.03-LTS-Avaota-A1-aarch64-alpha1 -k https://github.com/AvaotaSBC/linux.git -b linux-5.10-oe -c avaota-a1 -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-22.03-LTS/generic.repo -d sun55i-t527-avaota-a1 -s headless`

    - openEuler-22.03-LTS with xfce desktop, run the following command:

        `sudo bash build.sh -n openEuler-22.03-LTS-Avaota-A1-aarch64-alpha1 -k https://github.com/AvaotaSBC/linux.git -b linux-5.10-oe -c avaota-a1 -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-22.03-LTS/generic.repo -d sun55i-t527-avaota-a1 -s xfce`


## How to Use an Image

### Install an Image on an SD Card

