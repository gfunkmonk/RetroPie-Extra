#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

rp_module_id="adom"
rp_module_desc="Ancient Domains of Mystery - a free roguelike by Thomas Biskup"
rp_module_help="A keyboard is required to play. Press SHIFT+Q to exit the game."
rp_module_licence="PROP"
rp_module_section="exp"
rp_module_flags="!all arm rpi4 rpi5 x86"

function __get_binary_url_adom() {
    local url="https://www.adom.de/home/download/current/adom_linux_arm_3.3.3.tar.gz"
    echo "$url"
}

function install_bin_adom() {
    local tmpdir="$(mktemp -d)"
    downloadAndExtract "$(__get_binary_url_adom)" "$tmpdir"
    cp -rf "$tmpdir/adom/"* "$md_inst"
    rm -rf "$tmpdir"
}

function configure_adom() {
    addPort "$md_id" "adom" "ADOM - Ancient Domains of Mystery" "CON:$md_inst/adom"
    mkRomDir "ports"
    moveConfigDir "$home/.adom.data" "$md_conf_root/adom"
}
