#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#
# This game works on i386, arm64, and amd64 package architectures
#
rp_module_id="ut2004"
rp_module_desc="Unreal Tournament 2004"
rp_module_licence="PROP"
rp_module_help=""
rp_module_section="exp"
rp_module_repo="file https://treefort.icculus.org/ut2004/ut2004-lnxpatch3369-2.tar.bz2"
rp_module_flags="!all x86"

function depends_ut2004() {
    local depends="libstdc++5 libsdl1.2debian libopenal-dev"
    getDepends "${depends[@]}"
}

function install_bin_ut2004() {
    # Alternative URL "https://ut2004.ut-files.com/index.php?dir=UT2004\&file=ut2004-lnxpatch3369-2.tar.tar"
    local dl_url="https://treefort.icculus.org/ut2004/ut2004-lnxpatch3369-2.tar.bz2"
    downloadAndExtract "$dl_url" "$md_inst"  --no-same-owner --strip-components=1
}

function __config_game_dirs() {
    local ut2004_game_dir=$1

    if [[ ! -d "$romdir/ports/ut2004/$ut2004_game_dir" ]]; then
        mkdir -p "$romdir/ports/ut2004/$ut2004_game_dir"
        chown -R "$__user":"$__group" "$romdir/ports/ut2004/$ut2004_game_dir"
    else
        # Note: We only want to ensure the user has access to the game directory.
        # Not necessarily the data files within the directory.
        chown "$__user":"$__group" "$romdir/ports/ut2004/$ut2004_game_dir"
    fi

    if [[ -d "$md_inst/$ut2004_game_dir" ]]; then
        cd "$md_inst/$ut2004_game_dir"
        for file in $(ls *); do

            # Note we move the files, but we want the permissions to remain owned by root.
            # This is to ensure that when installing game data we do not accidentally
            # replace any files provided by the installer
            mv "$md_inst/$ut2004_game_dir/$file" "$romdir/ports/ut2004/$ut2004_game_dir/$file"
        done

        rm -rf "$md_inst/$ut2004_game_dir"
    fi

    ln -snf "$romdir/ports/ut2004/$ut2004_game_dir" "$md_inst/$ut2004_game_dir"

}



function game_data() {
    # Alternative URL "https://ut2004.ut-files.com/index.php?dir=BonusPacks\&file=ut2004megapack-linux.tar.bz2"
    # local mega_pack_url="http://treefort.icculus.org/ut2004/ut2004megapack-linux.tar.bz2"
    local bonus_maps=(
        "https://ut2004.ut-files.com/index.php?dir=Maps/Assault\&file=AS-Confexia.zip"
        "https://ut2004.ut-files.com/index.php?dir=Maps/Onslaught\&file=ons-icarus.zip"
        "https://unreal-archive-files-s3.s3.us-west-002.backblazeb2.com/Unreal%20Tournament%202004/Maps/DeathMatch/F/4/1/ee3ede/dm-forbidden.zip"
    )

    #downloadAndExtract "$mega_pack_url" "$md_inst"  --no-same-owner --strip-components=1

    for item in "${bonus_maps[@]}"; do
        downloadAndExtract "$item" "$md_inst"
    done

    downloadAndExtract "https://unreal-archive-files-s3.s3.us-west-002.backblazeb2.com/Unreal%20Tournament%202004/Maps/Capture%20The%20Flag/D/1/8/303346/ctf-de-lavagiant2.zip" "$md_inst/Maps/"

    for dir in Animations Help Manual Maps Music Sounds StaticMeshes Speech System Textures Web; do
        __config_game_dirs "$dir"
    done

}

function configure_ut2004() {
    # The way the binary is built, it expects libSDL1.2.so.0
    addPort "$md_id" "ut2004" "Unreal Tournament 2004" "cd /opt/retropie/ports/ut2004/System && ./ut2004-bin-linux-amd64"
    mkRomDir "ports/ut2004"

    if [[ "$md_mode" == "install" ]]; then
        game_data

        ln -snf "/usr/lib/x86_64-linux-gnu/libSDL-1.2.so.0" "$md_inst/System/libSDL-1.2.so.0"
        ln -snf "/usr/lib/x86_64-linux-gnu/libopenal.so" "$md_inst/System/openal.so"
        ln -snf "/usr/lib/x86_64-linux-gnu/libstdc++.so.5" "$md_inst/System/libstdc++.so.5"
    fi
    moveConfigDir "$home/.ut2004" "$md_conf_root/ut2004"
}
