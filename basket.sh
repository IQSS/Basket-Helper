#!/bin/bash

# Debug setting
# 0 = false; 1 = true
DEBUG=0

# Booleans for readability
FALSE=0
TRUE=1

# Python version to use
PYMAJ=2
PYMIN=7

# Basket download URL
URL="https://github.com/dbaty/Basket/tarball/master"


function basket_install {
  echo ""
  echo "Installing..."
  echo ""

  $PIP install -U --user $URL
}


function basket_findpath {
  echo ""
  echo "Scanning..."
  echo ""

  # Grep site-packages location from pip
  local sitepkgs=$($PIP show basket | egrep '^Location:' | awk '{print $2}')
  debug "Result of pip query: ${sitepkgs}"
  if [[ -z "${sitepkgs}" ]]; then
    basket_quit "Could not parse '${PIP} show basket'; Basket may not be installed."
  fi

  PYDIR=""

  IFS='/' read -ra PYDIR <<< "$sitepkgs"

  for i in "${PYDIR[@]}"; do
    dir="$i"
    if [[ ! -z "$dir" ]]; then
      if [[ "$dir" == "lib" ]]; then
        debug "Python lib directory reached"
        break
      else
        PYDIR="${PYDIR}/$dir"
        debug "${PYDIR}"
      fi
    fi
  done
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


function init {
  # Set executables
  CURL=$(which curl)
  if [[ -z "${CURL// }" ]]; then basket_quit "'curl' not found."; fi

  RM=$(which rm)
  if [[ -z "${RM// }" ]]; then basket_quit "'rm' not found."; fi

  UNZIP=$(which unzip)
  if [[ -z "${UNZIP// }" ]]; then basket_quit "'unzip' not found."; fi

  # Find pip and verify Python version
  local is_version=$FALSE

  PIP=$(which pip)
  debug "'which pip' result: ${PIP}"
  if [[ ! -z "${PIP// }" ]]; then
    getpyver
    is_version=$?
  fi

  if [[ "$is_version" -eq "$FALSE" ]] || [[ -z "${PIP// }" ]]; then
    PIP=$(which pip2)
    debug "'which pip2' result: ${PIP}"
    if [[ -z "${PIP// }" ]]; then basket_quit "'pip' not found; is Python installed?"; fi
    getpyver
    is_version=$?
  fi

  if [[ "$is_version" -eq "$FALSE" ]]; then
    basket_quit "Not able to find Python version ${PYMAJ}.${PYMIN}."
  fi
}


function getpyver {
  local pyregex="python\s${PYMAJ}\.${PYMIN}(\.[0-9])?"
  local pipver=$($PIP --version)
  debug "pip version: ${pipver}"

  if echo "$pipver" | egrep -q "$pyregex"; then
    debug "Python ${PYMAJ}.${PYMIN} found"
    return $TRUE
  else
    debug "Python ${PYMAJ}.${PYMIN} not found"
    return $FALSE
  fi
}


function debug {
  if [ "$DEBUG" = true ]; then
    local time=$(date +'%Y%m%d.%H%M%S')
    echo "[$time]" "$@"
  fi
}


#
# MAIN
#
init
basket_install
basket_findpath

PYPATH="${PYDIR}/bin"

if [[ -e "$PYPATH" ]]; then
  debug "Found Python bin at ${PYPATH}"
  export PATH="${PYPATH}:${PATH}"
  debug "PATH exported as ${PATH}"
  basket_complete
else
  basket_quit "The Python bin directory does not exist at the expected location."
fi