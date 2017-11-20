#!/bin/bash

# Debug setting
DEBUG=false

# Basket download URL
URL="https://github.com/dbaty/Basket/archive/master.zip"


function basket_download {
  echo ""
  echo "Downloading..."
  echo ""

  cd ~/
  $CURL -Lo Basket.zip --progress-bar $URL
}


function basket_install {
  echo ""
  echo "Installing..."
  echo ""

  $UNZIP -qq ~/Basket.zip
  $PIP install -U --user ~/Basket-master/
  $RM -rf ~/Basket.zip ~/Basket-master
}


function basket_findpath {
  echo ""
  echo "Scanning..."
  echo ""

  # Grep site-packages location from pip
  local sitepkgs=$($PIP show Basket | egrep '^Location:' | awk '{print $2}')
  if [[ -e "${sitepkgs}" ]]; then
    basket_quit "Could not parse '${PIP} show Basket'; Basket may not be installed."
  else
    debug "Found modules at ${sitepkgs}"
  fi

  local pydir=""

  IFS='/' read -ra pydir <<< "$sitepkgs"

  for i in "${pydir[@]}"; do
    dir="$i"
    if [[ ! -z "$dir" ]]; then
      if [[ "$dir" == "lib" ]]; then
        debug "Python lib directory reached"
        break
      else
        pydir="${pydir}/$dir"
        debug "${pydir}"
      fi
    fi
  done

  return $pydir
}


function basket_complete {
  echo ""
  echo "Complete..."
  echo ""
  echo "You can now use Basket for the duration of this session. To make this"
  echo "permenant, add this line to your '.bashrc' file in your home directory:"
  echo ""
  echo "PATH=\"${PYPATH}:\${PATH}\""
  echo ""
}


function basket_quit {
  local reason=$@
  echo ""
  echo "The program was unable to complete: ${reason}"
  echo ""
  exit 1
}


function debug {
  if [ "$DEBUG" = true ]; then
    local time=$(date +'%Y%m%d.%H%M%S')
    echo "[$time]" "$@"
  fi
}


function basket_init {
  # Set executables
  CURL=$(which curl)
  if [[ -z "${CURL// }" ]]; then basket_quit "'curl' not found."; fi

  RM=$(which rm)
  if [[ -z "${RM// }" ]]; then basket_quit "'rm' not found."; fi

  UNZIP=$(which unzip)
  if [[ -z "${UNZIP// }" ]]; then basket_quit "'unzip' not found."; fi

  PIP=$(which pip)
  if [[ -z "${PIP// }" ]]; then
    PIP=$(which pip2)
    if [[ -z "${PIP// }" ]]; then basket_quit "'pip' not found."; fi
  fi

  local pyver=$($PIP --version | egrep '\(python [0-9]\.[0-9](\.[0-9])?\)' --only-matching)
}

basket_init
basket_download
basket_install

basket_findpath
result=$?
PYPATH="${result}/bin"

if [[ -e "$PYPATH" ]]; then
  debug "Found Python bin at ${PYPATH}"
  export PATH="${PYPATH}/bin:${PATH}"
  debug "PATH exported as ${PATH}"
  basket_complete
else
  basket_quit "The Python bin directory does not exist at the expected location."
fi