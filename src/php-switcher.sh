#!/usr/bin/env bash

#
# Script to Switch PHP (installed via Homebrew) in MacOS
#
# @author   Raj KB <magepsycho@gmail.com>
# @website  https://www.magepsycho.com
# @version  1.0.0

# UnComment it if bash is lower than 4.x version
shopt -s extglob

################################################################################
# CORE FUNCTIONS - Do not edit
################################################################################

## Uncomment it for debugging purpose
###set -o errexit
#set -o pipefail
#set -o nounset
#set -o xtrace

#
# VARIABLES
#
_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)

_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)

#
# HEADERS & LOGGING
#
function _debug()
{
    if [[ "$DEBUG" = 1 ]]; then
        "$@"
    fi
}

function _header()
{
    printf '\n%s%s==========  %s  ==========%s\n' "$_bold" "$_purple" "$@" "$_reset"
}

function _arrow()
{
    printf '➜ %s\n' "$@"
}

function _success()
{
    printf '%s✔ %s%s\n' "$_green" "$@" "$_reset"
}

function _error() {
    printf '%s✖ %s%s\n' "$_red" "$@" "$_reset"
}

function _warning()
{
    printf '%s➜ %s%s\n' "$_tan" "$@" "$_reset"
}

function _underline()
{
    printf '%s%s%s%s\n' "$_underline" "$_bold" "$@" "$_reset"
}

function _bold()
{
    printf '%s%s%s\n' "$_bold" "$@" "$_reset"
}

function _note()
{
    printf '%s%s%sNote:%s %s%s%s\n' "$_underline" "$_bold" "$_blue" "$_reset" "$_blue" "$@" "$_reset"
}

function _die()
{
    _error "$@"
    exit 1
}

function _safeExit()
{
    exit 0
}

#
# UTILITY HELPER
#
function _seekConfirmation()
{
  printf '\n%s%s%s' "$_bold" "$@" "$_reset"
  read -p " (y/n) " -n 1
  printf '\n'
}

# Test whether the result of an 'ask' is a confirmation
function _isConfirmed()
{
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1
}


function _typeExists()
{
    if type "$1" >/dev/null; then
        return 0
    fi
    return 1
}

function _isOs()
{
    if [[ "${OSTYPE}" == $1* ]]; then
      return 0
    fi
    return 1
}

function _checkRootUser()
{
    #if [ "$(id -u)" != "0" ]; then
    if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
    fi

}

function _printPoweredBy()
{
    local mp_ascii
    mp_ascii='
   __  ___              ___               __
  /  |/  /__ ____ ____ / _ \___ __ ______/ /  ___
 / /|_/ / _ `/ _ `/ -_) ___(_-</ // / __/ _ \/ _ \
/_/  /_/\_,_/\_, /\__/_/  /___/\_, /\__/_//_/\___/
            /___/             /___/
'
    cat <<EOF
${_green}
Powered By:
$mp_ascii

 >> Store: ${_reset}${_underline}${_blue}https://www.magepsycho.com${_reset}${_reset}${_green}
 >> Blog:  ${_reset}${_underline}${_blue}https://blog.magepsycho.com${_reset}${_reset}${_green}

################################################################
${_reset}
EOF
}

################################################################################
# SCRIPT FUNCTIONS
################################################################################
function _printUsage()
{
    echo -n "$(basename "$0") [OPTION]...

Simplified PHP Version Switcher for MacOS
Version $VERSION

    Options:
        --from                  Current PHP version
        --to                    New PHP version you want to switch to

        -h, --help              Display this help and exit

    Examples:
        $(basename "$0") [--from=...] --to=...

"
    _printPoweredBy
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
            --from=*)
                PHP_CURRENT_VERSION="${arg#*=}"
            ;;
            --to=*)
                PHP_TO_VERSION="${arg#*=}"
            ;;
            --debug)
                DEBUG=1
                set -o xtrace
            ;;
            -h|--help)
                _printUsage
            ;;
            *)
                _printUsage
            ;;
        esac
    done

    validateArgs
    #sanitizeArgs
}

function validateArgs()
{
    ERROR_COUNT=0

    if [[ ! -z "$PHP_CURRENT_VERSION" && "$PHP_CURRENT_VERSION" != @(7.1|7.2|7.3|7.4) ]]; then
        _error "Please enter valid PHP version for --from=... parameter (7.1|7.2|7.3|7.4)."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ ! -z "$PHP_TO_VERSION" && "$PHP_TO_VERSION" != @(7.1|7.2|7.3|7.4) ]]; then
        _error "Please enter valid PHP version for --to=... parameter (7.1|7.2|7.3|7.4)."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ "$PHP_CURRENT_VERSION" = "$PHP_TO_VERSION" ]]; then
        _error "Current and switching PHP version cannot be same"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    [[ "$ERROR_COUNT" -gt 0 ]] && exit 1
}

function switchPhpVersion()
{
    _arrow "Unlinking ${PHP_CURRENT_VERSION} and linking ${PHP_TO_VERSION}"
    brew unlink php@"$PHP_CURRENT_VERSION" && brew link --force --overwrite php@"$PHP_TO_VERSION"

    _arrow "Updating \$PATH environment in .zshrc"
    sed -i '' "s/#*export PATH=\"\/usr\/local\/opt\/php@${PHP_TO_VERSION}/export PATH=\"\/usr\/local\/opt\/php@${PHP_TO_VERSION}/g" $ZSH_FIE_PATH
    sed -i '' "s/export PATH=\"\/usr\/local\/opt\/php@${PHP_CURRENT_VERSION}/#export PATH=\"\/usr\/local\/opt\/php@${PHP_CURRENT_VERSION}/g" $ZSH_FIE_PATH

    _note "Reload .zshrc manually: source ~/.zshrc"
    #. "$ZSH_FIE_PATH"

    _arrow "Checking version in PHP CLI"
    php -v

    _arrow "Stopping php@${PHP_CURRENT_VERSION} services"
    brew services stop php@"$PHP_CURRENT_VERSION" || _note "Run command manually: brew services stop php@$PHP_CURRENT_VERSION"
    brew services start php@"$PHP_TO_VERSION" || _note "Run command manually: brew services start php@$PHP_TO_VERSION"

    _arrow "Checking version in SAPI with phpinfo()"
    php -r 'phpinfo();' | grep 'PHP Version'
}

function printSuccessMessage()
{
    _success "PHP Version Switching Completed!"

    echo "################################################################"
    echo ""
    echo " >> Old PHP Version           : ${PHP_CURRENT_VERSION}"
    echo " >> New PHP Version           : ${PHP_TO_VERSION}"

    echo ""
    echo "################################################################"
    _printPoweredBy

}

################################################################################
# Main
################################################################################
export LC_CTYPE=C
export LANG=C

DEBUG=0
_debug set -x
VERSION="1.0.0"

# Defaults
PHP_CURRENT_VERSION=$(php -r "echo substr(phpversion(),0,3);")
HOME_DIR=$HOME
ZSH_FIE_PATH="$HOME/.zshrc"

function main()
{
    [[ $# -lt 1 ]] && _printUsage

    processArgs "$@"
    switchPhpVersion
    printSuccessMessage

    exit 0
}

main "$@"

_debug set +x
