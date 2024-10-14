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
rp_module_repo="git https://github.com/etlegacy/etlegacy.git :_get_branch_etlegacy"
rp_module_flags=""

function _get_branch_etlegacy() {
    # Tested tag was 2.82.1 commit 0a24c70
    local version
    local release_url

    release_url="https://api.github.com/repos/etlegacy/etlegacy/tags"
    version=$(curl "$release_url" 2>&1 | grep -m 1 name | cut -d\" -f4 | cut -dv -f2)

    echo -ne "v${version}"
}

function _arch_etlegacy() {
    echo -ne "$(uname -m)"
}

function _arch_etlegacy2() {
    echo -ne "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function depends_etlegacy() {
    # Theoretically needs:
    #libc6-dev-i386 libx11-dev:i386 libgl1-mesa-dev:i386
    local depends=(cmake libopenal-dev libssl-dev libjpeg-dev zlib1g-dev libsdl2-dev libpng-dev
        libglew-dev libsqlite3-dev libcurl4-openssl-dev libglew-dev libfreetype6-dev
        libminizip-dev libogg-dev libtheora-dev)

    if compareVersions "$__os_debian_ver" gt 10; then
        depends+=(liblua5.4-dev)
    fi

    if isPlatform "rpi"; then
        depnds+=(xorg)
    fi

    getDepends "${depends[@]}"
}

function sources_etlegacy() {
    gitPullOrClone
}

function build_etlegacy() {
    local params=(-DCMAKE_BUILD_TYPE=Release -DBUILD_SERVER=1 -DBUILD_CLIENT=1 -DBUILD_MOD=1
        -DBUILD_MOD_PK3=1 -DBUNDLED_ZLIB=0 -DBUNDLED_MINIZIP=0 -DBUNDLED_JPEG=0
        -DBUNDLED_CURL=0 -DBUNDLED_WOLFSSL=0 -DBUNDLED_OPENSSL=0 -DBUNDLED_OGG_VORBIS=0
        -DBUNDLED_THEORA=0 -DBUNDLED_OPENAL=0 -DBUNDLED_FREETYPE=0 -DBUNDLED_PNG=0
        -DBUNDLED_SQLITE3=0 -DFEATURE_CURL=1 -DFEATURE_SSL=1 -DFEATURE_AUTH=1
        -DFEATURE_OGG_VORBIS=1 -DFEATURE_THEORA=1 -DFEATURE_OPENAL=1 -DFEATURE_FREETYPE=1
        -DFEATURE_PNG=1 -DFEATURE_TRACKER=1 -DFEATURE_LUA=1 -DFEATURE_MULTIVIEW=1
        -DFEATURE_EDV=1 -DFEATURE_ANTICHEAT=1 -DFEATURE_GETTEXT=1 -DFEATURE_DBMS=1
        -DFEATURE_RATING=1 -DFEATURE_PRESTIGE=1 -DFEATURE_AUTOUPDATE=0
        -DFEATURE_RENDERER1=1 -DFEATURE_RENDERER2=0 -DFEATURE_RENDERER_GLES=0
        -DFEATURE_OMNIBOT=1 -DFEATURE_LUASQL=1 -DINSTALL_EXTRA=1 -DINSTALL_GEOIP=1
        -DINSTALL_WOLFADMIN=1)

    if isPlatform "64bit" && [[ "$md_id" != "etlegacy_64" ]]; then
        params+=(-DCROSS_COMPILE32=1)
    else
        params+=(-DCROSS_COMPILE32=0)
    fi

    if isPlatform "64bit" && [[ "$md_id" != "etlegacy_64" ]]; then
        params+=(-DBUNDLED_SDL=1)
    else
        params+=(-DBUNDLED_SDL=0)
    fi

    if compareVersions "$__os_debian_ver" gt 10; then
        params+=(-DBUNDLED_LUA=0)
    else
        params+=(-DBUNDLED_LUA=1)
    fi

    if isPlatform "rpi"; then
        params+=(-DBUNDLED_GLEW=1 -DRENDERER_DYNAMIC=0 -DINSTALL_OMNIBOT=0)
    else
        params+=(-DBUNDLED_GLEW=0 -DRENDERER_DYNAMIC=1 -DINSTALL_OMNIBOT=1)
    fi

    mkdir "$md_build/build"
    cd "$md_build/build"

    cmake "${params[@]}" ..
    make

    md_ret_require=(
        "$md_build/build/etl.$(_arch_etlegacy)"
        "$md_build/build/legacy/cgame.mp.$(_arch_etlegacy).so"
        "$md_build/build/legacy/qagame.mp.$(_arch_etlegacy).so"
        "$md_build/build/legacy/ui.mp.$(_arch_etlegacy).so"
    )

    if isPlatform "x86"; then
        md_ret_require+=("$md_build/build/librenderer_opengl1_$(_arch_etlegacy).so")
    fi

}

function install_etlegacy() {
    md_ret_files=(
        "build/etl.$(_arch_etlegacy)"
        "build/etlded.$(_arch_etlegacy)"
        # "build/legacy/cgame.mp.$(_arch_etlegacy).so"
        # "build/legacy/qagame.mp.$(_arch_etlegacy).so"
        # "build/legacy/ui.mp.$(_arch_etlegacy).so"
        "build/legacy"
    )

    if isPlatform "x86"; then
        md_ret_files+=("build/librenderer_opengl1_$(_arch_etlegacy).so")
    fi
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

    if isPlatform "rpi"; then
        pushd "$md_inst/legacy"
        ln -s ui.mp.$(_arch_etlegacy).so ui.mp.$(_arch_etlegacy2).so
    fi

    #mkdir "$md_inst/legacy"
    #mv "$md_inst/cgame.mp.$(_arch_etlegacy).so" "$md_inst/legacy/"
    #mv "$md_inst/ui.mp.$(_arch_etlegacy).so" "$md_inst/legacy/"
    #mv "$md_inst/qagame.mp.$(_arch_etlegacy).so" "$md_inst/legacy/"
}
