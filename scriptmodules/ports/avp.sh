#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="avp"
rp_module_desc="Aliens versus Predator"
rp_module_help="Very buggy, but playable. Common issue: al lib alc_cleanup 1 device not closed. This version has no videos (DRM protected) and no ripped CD audio."
rp_module_licence="MIT https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/LICENSE.md"
rp_module_repo="file https://github.com/Exarkuniv/Rpi-pikiss-binary/raw/Master/avp_rpi.tar.gz"
rp_module_section="exp"
rp_module_flags="!armv6 rpi4"

function depends_avp() {
    getDepends xorg
}

function sources_avp() {
    downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function install_avp() {
    md_ret_files=('cd tracks.txt'
        'language.txt'
        'avp'
        'credits.txt'
        '.avp'
        'avp_huds'
        'avp_rifs'
        'fastfile'
    )
}

function configure_avp() {
    mkRomDir "ports/avp"
    moveConfigDir "$md_inst/.avp" "$md_conf_root/.avp"
    addPort "$md_id" "avp" "Aliens versus Predator" "XINIT: $md_inst/avp -f"
}
