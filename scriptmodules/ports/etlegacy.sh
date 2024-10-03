#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
#
# https://github.com/etlegacy/etlegacy/wiki/FAQ#i-want-to-play-et-legacy-on-my-linux-system-which-version-should-i-use-32-or-64-bit
#
# It depends. If you only want to play Legacy mod, or one of the other mods provided in 64 bit,
# install the 64 bit version. If you want to be able to play third party mods that are only
# available in 32 bit, install the 32 bit version. In that case, you will have to install all
# required libs in 32 bits, including the entire graphics stack.

rp_module_id="etlegacy"
rp_module_desc="etlegacy - ET: Legacy - A Fully compatable Wolfenstein: Enemy Territory Client and Server"
rp_module_help="This installs the 32bit version of ET: Legacy.  Per their website, this SHOULD work perfectly on a 64bit machine.  However, there are build conflicts that require help to get working properly."
rp_module_licence="GPL3 https://raw.githubusercontent.com/etlegacy/etlegacy/master/COPYING.txt"
rp_module_section="exp"
rp_module_repo="git https://github.com/etlegacy/etlegacy.git master :_get_branch_etlegacy"
rp_module_flags="!64bit"

function _get_branch_etlegacy() {
    # Tested tag was 2.82.1 commit 0a24c70
    # manual:
    # 'curl https://api.github.com/repos/etlegacy/etlegacy/tags | grep -m 1 sha | cut -d\" -f4 | cut -dv -f2 | cut -7'

    local version
    local release_url

    release_url="https://api.github.com/repos/etlegacy/etlegacy/tags"
    version=$(download "$release_url" - | grep -m 1 sha | cut -d\" -f4 | cut -dv -f2 | cut -c -7)

    echo -ne "$version"
}

function _arch_etlegacy() {
    echo -ne "$(uname -m)"
}

function _get_etlagcy_base_params() {
    local params=(-DCMAKE_BUILD_TYPE=Release -DBUNDLED_OPENSSL=0 -DBUNDLED_JPEG=0 -DBUNDLED_ZLIB=0)
    params+=(-DBUNDLED_OPENAL=0 -DBUNDLED_SDL=0 -DBUNDLED_PNG=0 -BUNDLED_GLEW=0)

    echo -ne "${params[@]}"
}

function depends_etlegacy() {
    # Theoretically needs:
    #libc6-dev-i386 libx11-dev:i386 libgl1-mesa-dev:i386

    local depends=(cmake libopenal-dev libssl-dev libjpeg-dev zlib1g-dev libsdl2-dev libpng-dev)
    depnds+=(libglew-dev)

    getDepends "${depends[@]}"
}

function sources_etlegacy() {
    gitPullOrClone
}

function build_etlegacy() {
    local params
    params="$(_get_etlagcy_base_params)"

    if isPlatform "64bit"; then
        params+=(-DCROSS_COMPILE32=1)
        git submodule init
        git submodule update
    fi

    if isPlatform "rpi"; then
        params+=(-DARM=1)
    fi

    mkdir "$md_build/build"
    cd "$md_build/build"

    cmake "${params[@]}" ..
    make clean
    make

    md_ret_require="$md_build/build/etl.$(_arch_etlegacy)"
}

function install_etlegacy() {
    md_ret_files=(
        "build/etl.$(_arch_etlegacy)"
        "build/etlded.$(_arch_etlegacy)"
        "build/librenderer_opengl1_$(_arch_etlegacy).so"
        "build/legacy/cgame.mp.$(_arch_etlegacy).so"
        "build/legacy/ui.mp.$(_arch_etlegacy).so"
        "build/legacy/qagame.mp.$(_arch_etlegacy).so"
    )
}

function game_data_etlegacy() {
    downloadAndExtract "https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip" "$md_build"
    cd "$md_build"
    ./et260b.x86_keygen_V03.run --noexec --target tmp
    cd "$md_build/tmp/etmain"

    cp ./*.pk3 "$romdir/ports/etlegacy"
}

function configure_etlegacy() {
    local launch_prefix
    local launcher_cmd

    if ! isPlatform "x86"; then
        local launch_prefix="XINIT-WM:"
    fi

    launcher_cmd="$launch_prefix$md_inst/etl.$(_arch_etlegacy)"
    addPort "$md_id" "etlegacy" "Wolfenstein - Enemy Territory" "$launcher_cmd"

    mkRomDir "ports/etlegacy"

    moveConfigDir "$md_inst/etmain" "$romdir/ports/etlegacy"
    [[ "$md_mode" == "install" ]] && game_data_etlegacy

    moveConfigDir "$home/.etlegacy" "$md_conf_root/etlegacy"

    mkdir "$md_inst/legacy"
    mv "$md_inst/cgame.mp.$(_arch_etlegacy).so" "$md_inst/legacy/"
    mv "$md_inst/ui.mp.$(_arch_etlegacy).so" "$md_inst/legacy/"
    mv "$md_inst/qagame.mp.$(_arch_etlegacy).so" "$md_inst/legacy/"
}
