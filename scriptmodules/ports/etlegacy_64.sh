#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="etlegacy_64"
rp_module_desc="etlegacy_64 - ET: Legacy - A Fully compatable Wolfenstein: Enemy Territory Client and Server"
rp_module_licence="https://raw.githubusercontent.com/etlegacy/etlegacy/master/COPYING.txt"
rp_module_section="exp"
rp_module_repo="git https://github.com/etlegacy/etlegacy.git :_get_branch_etlegacy"
rp_module_flags="!all 64bit"

function depends_etlegacy_64() {
    depends_etlegacy
}

function sources_etlegacy_64() {
    sources_etlegacy
}

function build_etlegacy_64() {
    build_etlegacy
}

function install_etlegacy_64() {
    install_etlegacy
}

function game_data_etlegacy_64() {
    game_data_etlegacy
}

function configure_etlegacy_64() {
    configure_etlegacy
}
