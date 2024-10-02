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
rp_module_id="unreal"
rp_module_desc="Unreal"
rp_module_licence="PROP https://github.com/OldUnreal/Unreal-testing/blob/master/LICENSE.md"
rp_module_help=""
rp_module_section="exp"
rp_module_repo="https://github.com/OldUnreal/Unreal-testing.git"
rp_module_flags="!all x86 64bit"

function _get_branch_unreal() {
    local version=$(curl https://api.github.com/repos/OldUnreal/Unreal-testing/releases/latest 2>&1 | grep -m 1 tag_name | cut -d\" -f4 | cut -dv -f2)
    echo -ne $version
}

function depends_unreal() {
    local depends=(libsdl2-2.0-0 libopenal1)

    isPlatform "rpi" && depends+=(xorg)
    getDepends "${depends[@]}"
}

function install_bin_unreal() {
    # local version="$(_get_branch_ut)"
    # local arch="$(dpkg --print-architecture)"

    # # For some reason, it failed when using "$rp_module_repo", this works perfectly.
    # local base_url="https://github.com/OldUnreal/UnrealTournamentPatches"
    # local dl_file="OldUnreal-UTPatch${version}-Linux-${arch}.tar.bz2"
    # local dl_url="${base_url}/releases/download/v${version}/${dl_file}"

    # # The download files use "x86" for the i386 architecture
    # [[ "${arch}" == "i386" ]] && arch="x86"

    gitPullOrClone "$md_inst" "https://github.com/OldUnreal/Unreal-testing.git"
}

function __config_game_data_unreal() {
    local unreal_game_dir=$1

    if [[ ! -d "$romdir/ports/unreal/$unreal_game_dir" ]]; then
        mkdir -p "$romdir/ports/unreal/$unreal_game_dir"
        chown -R "$__user":"$__group" "$romdir/ports/unreal/$unreal_game_dir"
    else
        chown "$__user":"$__group" "$romdir/ports/unreal/$unreal_game_dir"
    fi

    if [[ -d "$md_inst/$unreal_game_dir" ]]; then
        cd "$md_inst/$unreal_game_dir"
        for file in $(ls -d *); do

            echo "Moving $md_inst/$unreal_game_dir/$file -> $romdir/ports/$unreal_game_dir/$file"

            if [[ -d "$md_inst/$unreal_game_dir/$file" ]]; then
                if [[ ! -d "$romdir/ports/unreal/$unreal_game_dir/$file" ]]; then
                    mv "$md_inst/$unreal_game_dir/$file" "$romdir/ports/unreal/$unreal_game_dir/$file"
                else
                    rm -rf "$romdir/ports/unreal/$unreal_game_dir/$file"
                    mv "$md_inst/$unreal_game_dir/$file" "$romdir/ports/unreal/$unreal_game_dir/$file"
                fi
            else
                mv "$md_inst/$unreal_game_dir/$file" "$romdir/ports/unreal/$unreal_game_dir/$file"
            fi
        done

        rm -rf "$md_inst/$unreal_game_dir"
    fi

    ln -snf "$romdir/ports/unreal/$unreal_game_dir" "$md_inst/$unreal_game_dir"
}

function game_data_unreal() {

    for dir in Help Maps Music Sounds Textures Web; do

        # Ensure we aren't moving files that are already in place.
        # Eliminates 'mv: '$src/$file' and '$dst/$file' are the same file' errors.
        if [[ ! -h "$md_inst/$dir" ]]; then
            __config_game_data_unreal "$dir"
        fi
    done

    chown -R "$__user":"$__group" "$romdir/ports/unreal"
    find  "$romdir/ports/unreal" -type f -exec chmod 644 {} \;
    find  "$romdir/ports/unreal" -type d -exec chmod 755 {} \;

}

function configure_unreal() {
    if isPlatform "x86"; then
        addPort "$md_id" "unreal" "Unreal" "$md_inst/System64/unreal-bin"
    else
        local launch_prefix="XINIT-WM:"
        addPort "$md_id" "unreal" "Unreal" "$launch_prefix$md_inst/SystemARM64/unreal-bin"
    fi

    mkRomDir "ports/unreal"

    if [[ "$md_mode" == "install" ]]; then
        game_data_unreal
    fi

    # moveConfigDir "$home/.unrealpg" "$md_conf_root/unreal"

    # # We only want to install this if it is not already installed.
    # if [[ ! -f "$home/.unrealpg/System/UnrealTournament.ini" ]]; then
    #     cp "$md_data/UnrealTournament.ini" "$home/.unrealpg/System/UnrealTournament.ini"
    #     chown "$__user":"$__group" "$home/.unrealpg/System/UnrealTournament.ini"
    #     chmod 644 "$home/.unrealpg/System/UnrealTournament.ini"
    # fi
}
