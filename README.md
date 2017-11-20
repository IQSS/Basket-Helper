# Basket Helper

Assists with installing and setting up Basket for Python. Originally written to assist users with Level 5 workstations at Harvard.

## Introduction

Basket is a module for Python that downloads other modules and dependencies for offline use.

The use case here is that Level 5 workstations have no internet connection for downloading and installing Python modules, so Basket is a helpful tool for finding and downloading module dependencies that can be transferred from a internet-connected machine to the Level 5 workstation.

More info: http://pythonhosted.org/Basket/

### Notes About This Script

This Bash script is not a wrapper for Basket, but assists in installing and setting up Basket on a Mac. For those who may not be Python savvy, it abstracts away some of the confusing aspects of using Python locally.

It defaults to using Python 2.7, but this can be changed in the global variable settings.

Also note: the version available on PyPI has not been updated to using https, which is a requirement for downloading modules from PyPI. However, it's fixed on GitHub.

### Compatibility

* This script is meant for macOS
* It was tested on macOS 10.13
* No guarantees it works on older versions of macOS or OS X
* No guarantees it works on Bash for Windows

## Instructions

1. Ensure you have Python 2.7 installed
2. Clone or download the 'basket.sh' script
3. Ensure the script is executable: `chmod u+rwx basket.sh`
4. Execute the script: `source basket.sh`
5. Once the script has finished, you can use Basket:
    1. `` export BASKET_ROOT="/Users/`whoami`/Documents/<folder_name>" ``
    2. `basket init`
    3. `basket download <python_module_name>`
    4. Copy contents of `<folder_name>` to a USB drive and trasnfer to desired system.