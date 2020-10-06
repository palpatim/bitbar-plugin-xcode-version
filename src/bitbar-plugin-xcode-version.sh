#!/bin/bash

#
# Lightweight Xcode version switcher
#
# Author: Tim Schmelter
#

# metadata
# <bitbar.title>Xcode version switcher</bitbar.title>
# <bitbar.version>v0.0.1</bitbar.version>
# <bitbar.author>Tim Schmelter</bitbar.author>
# <bitbar.author.github>palpatim</bitbar.author.github>
# <bitbar.desc>Display current Xcode version and switch to others</bitbar.desc>
# <bitbar.abouturl>https://github.com/palpatim/bitbar-plugin-xcode-version</bitbar.abouturl>

###############################################################################
# bitbar-plugin-xcode-version.sh
# Displays the currently selected Xcode version, as reported by xcode-select.
# Allows switching versions to any version of Xcode installed in
# /Applications/Xcode*.app
###############################################################################

function get_app_name {
  local app_path="$1"
  app_name=$(basename "$app_path" .app)
  echo "$app_name"
}

function get_icon_base64 {
  icon_path=$( get_icon_path )
  icon_base64=$( base64 < "$icon_path" )
  echo "$icon_base64"
}

function get_icon_path {
  app_path=$( get_selected_path )
  app_name=$( get_app_name "${app_path}" )
  app_icon="/var/tmp/${app_name}.png"
  echo "$app_icon"
}

function get_selected_path {
  path=$(xcode-select --print-path)
  app=${path%%/Contents*}
  echo "$app"
}

function get_version_from_path {
  app_path="$1"
  app_name=$( get_app_name "${app_path}" )
  version=${app_name##Xcode_}
  echo "$version"
}

function get_version {
  app_path=$( get_selected_path )
  get_version_from_path "${app_path}"
}

function ensure_icon_exists {
  icon_path=$( get_icon_path )
  if [[ -f "$icon_path" ]] ; then
    return 0
  fi
  write_icon
}

function write_icon {
  package_path=$( get_selected_path )
  icon_path=$( get_icon_path )
  sips -s format png -z 44 44 "${package_path}/Contents/Resources/Xcode.icns" --out "$icon_path" > /dev/null 2>&1
}

function get_plugin_directory {
  declare -r link=$( readlink $0 )
  if [[ -n "$link" ]] ; then
    dir=$( dirname "$link" )
    echo "${dir}"
  else
    echo $PWD
  fi
}

function get_switch_script {
  local dir=$( get_plugin_directory )
  echo "${dir}/switch_xcode.ascpt"
}


###############################################################################
# MAIN
###############################################################################
switch_script=$( get_switch_script )

current_path=$( get_selected_path )
current_version=$( get_version_from_path "${current_path}" )

ensure_icon_exists

echo "$( get_version ) | image=$( get_icon_base64 )"

echo "---"
for full_xcode_path in $( find "/Applications" -maxdepth 1 -name "Xcode*.app" | sort ) ; do
  version=$( get_version_from_path "${full_xcode_path}" )
  if [[ "${version}" = "${current_version}" ]] ; then
    echo "Currently ${version}"
  else
    echo "Switch to ${version} | bash=${switch_script} param1=${full_xcode_path} terminal=false refresh=true"
  fi
done
