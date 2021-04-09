#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

config_file=$DIR/compile.conf
compile_file=$DIR/compile.src
boilerplate_header=$DIR/boilerplates/header.src
boilerplate_module=$DIR/boilerplates/module.src
boilerplate_main=$DIR/boilerplates/main.src

rm $DIR/installer*
touch $DIR/installer_folders.src

folders=$DIR/installer_folders.src

function realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

function header() {
  echo "s = get_shell" >> $1
  echo "c = s.host_computer" >> $1
  echo "h = home_dir" >> $1
}

function print_debug() {
  echo "print(\"$1\")" >> $2
}

function create_folder() {
  echo "c.create_folder($1, $2)" >> $3
}

function create_file() {
  echo "c.touch($1, $2)" >> $3
}

function open_file() {
  echo "file = c.File($1)" >> $2
}

function write_file() {
  echo "Importing file $(realpath $1)..."
  echo "lines = []" >> $2
  n=1
  while read -r line || [ -n "$line" ]; do
    find="\""
    replace="\"\""
    newLines=$(sed "s+${find}+${replace}+g" <<< "$line")
    echo "lines.push(\"$newLines\")" >> $2
    n=$((n+1))
  done < $1
  echo "file.set_content(lines.join(\"\n\"))" >> $2
}

function gather() {
  index=0
  subdir=$1
  name=$2
  function create_installer() {
    newFile="${name//.src/$index.src}"
    touch $newFile
    header $newFile
    echo "Created file $newFile"
    eval "$1=$newFile"
  }
  create_installer currentFile
  for entry in $(find $DIR/$subdir -maxdepth 1 -name '*.src');
  do
    base="$(basename $entry)"
    print_debug "Write $base file..." $currentFile
    create_file "h + \"/$subdir\"" "\"$base\"" $currentFile
    open_file "h + \"/$subdir/$base\"" $currentFile
    write_file $entry $currentFile
    lineCount="$(awk 'END{print NR}' $currentFile)"
    if [ $lineCount -gt 1000 ]
    then
      index=$((index + 1))
      create_installer currentFile
    fi
  done
}

echo "Building installer $(realpath $file)..."

header $folders

print_debug "Create scripts folder..." $folders
create_folder "h" "\"scripts\"" $folders
create_folder "h + \"/scripts\"" "\"library\"" $folders

gather "scripts" "$DIR/installer_scripts.src"
gather "scripts/library" "$DIR/installer_libraries.src"

echo "Execute installers in Grey Hack now:"
echo "build installer_folders.src /usr/bin"
echo "build installer_libraries.src /usr/bin"
echo "build installer_scripts.src /usr/bin"
echo "installer"
