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

rp_module_id="lr-mess-jaguar"
rp_module_name="Atari Jaguar"
rp_module_ext=".zip"
rp_module_desc="MESS emulator ($rp_module_name) - MESS Port for libretro"
rp_module_help="Requires lr-mess already installed.\n\nROM Extensions: $rp_module_ext\n\n
Put games in:\n
$romdir/atarijaguar\n\n
Put BIOS files in $biosdir:\n
jaguarboot.zip, jaguar.zip, jaguarcd.zip"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-mess-jaguar() {
	local _mess=$(dirname "$md_inst")/lr-mess/mess_libretro.so
	if [[ ! -f "$_mess" ]]; then
		printMsgs dialog "cannot find '$_mess' !\n\nplease install 'lr-mess' package."
		exit 1
	fi
}

function sources_lr-mess-jaguar() {
	true
}

function build_lr-mess-jaguar() {
	true
}

function install_lr-mess-jaguar() {
	true
}

function configure_lr-mess-jaguar() {
	local _mess=$(dirname "$md_inst")/lr-mess/mess_libretro.so
	local _retroarch_bin="$rootdir/emulators/retroarch/bin/retroarch"
	local _system="atarijaguar"
	local _config="$configdir/$_system/retroarch.cfg"
	local _add_config="$_config.add"
	local _custom_coreconfig="$configdir/$_system/custom-core-options.cfg"
	local _script="$scriptdir/scriptmodules/run_mess.sh"

	# create retroarch configuration
	ensureSystemretroconfig "$_system"

	# ensure it works without softlists, using a custom per-fake-core config
    iniConfig " = " "\"" "$_custom_coreconfig"
    iniSet "mame_softlists_enable" "disabled"
	iniSet "mame_softlists_auto_media" "disabled"
	iniSet "mame_boot_from_cli" "disabled"

	# this will get loaded too via --append_config
	iniConfig " = " "\"" "$_add_config"
	iniSet "core_options_path" "$_custom_coreconfig"
	#iniSet "save_on_exit" "false"

	# set permissions for configurations
 	chown $__user:$__group "$_custom_coreconfig"
 	chown $__user:$__group "$_add_config"

	# setup rom folder
	mkRomDir "$_system"

	# ensure run_mess.sh script is executable
	chmod 755 "$_script"

	# add the emulators.cfg as normal, pointing to the above script
	addEmulator 1 "$md_id" "$_system" "$_script $_retroarch_bin $_mess $_config $_system $biosdir -cart %ROM%"

	# add system to es_systems.cfg as normal
	addSystem "$_system" "$md_name" "$md_ext"
}
