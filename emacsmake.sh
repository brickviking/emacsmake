#!/bin/bash
#
# v0.1 Initial cut, should be mostly complete
# v0.2 Changes to account for mistakes I made
# TODO: rework for versions of emacs earlier than 28.0.50, as there's no makefile until the
#       configure phase

# Modifiable parameters
# You WILL want to fiddle with these if you don't want the args I chose
COMPILEHOME="${HOME}/src/c/emacs"
# This gets used to run emacs-sandbox.sh with custom directory
EMACSCONFHOME="${HOME}/.emacs-playpen"

# We might need to rejigger this from args, which will screw with runMe and helpMe
EMACSHOME="${HOME}/bin/emacs-playpen"
CONFIGPARAMS="--prefix=${EMACSHOME}"

# Help function, usage()
helpMe() {
    echo "$0: emacs recompiler script"
    echo "   -h    help (this text)"
    echo "   -d    distclean (no compile)"
    # This could be rolled into -r
    echo "   -e    run every step"
    echo "         default emacs binary location is ${EMACSHOME}"
    echo "   -c    run configure with params"
    echo "      params are: ${CONFIGPARAMS}"
    echo "   -m    compile (no install)"
    echo "   -i    install to ${EMACSHOME}"
    echo "   -r    execute from ${EMACSHOME}"
    echo "   -u    uninstall from ${EMACSHOME}"
}

# Runs make distclean, but only if the configure step had created one.
# TODO: no chance to break out of this, perhaps we should offer that
cleanMe() {
    if [[ -f Makefile ]]; then
	echo "This will REMOVE all compiled files including makefiles"
	make distclean
    else
	echo "Makefile not found, skipping"
    fi
}

# Runs configure phase
configMe() {
    ./configure "${CONFIGPARAMS}"
}

# Runs make (hopefully we ran configure first)
makeMe() {
    if [[ -f Makefile ]]; then
	make
    else
	echo "No Makefile found, perhaps run with -c first?"
    fi
}

# Runs the install phase (currently don't need sudo, but would have normally done)
installMe() {
    # echo "This will require you to enter in your password" # only needed for system dirs
    # sudo make install
    # TODO: should check that there's a emacs binary first, but I don't know where that will be
    make install
}

# Assuming everything else is done, runs compiled emacs from install
runMe() {
    pushd "${EMACSHOME}"
    # Stick up a buffer with relevant instructions to run in *scratch*
    # vim notepad.txt  # currently handled by my emacs-28.0.50 client
    # TODO: We should probably capture whether emacs runs or dies
    RETVAL=$( emacs-sandbox.sh -d "${EMACSCONFHOME}" -i quelpa-use-package )
    if [[ "${RETVAL}" != 0 ]]; then
        echo "Completed with ${RETVAL}"
    else
        echo "Completed with success"
    fi
    popd
}

# Uninstall from $EMACSHOME
uninstallMe() {
    # Only requirements are that I've installed
    make uninstall
}

# Do everything
execMe() {
    cleanMe
    configMe
    makeMe
    installMe
    runMe
}

# main()

# Need a getopts-style processor here, or I could simply roll my own. Quicker to roll.
# args=$(getopt -n "$0" -o cde:hmiru -l emacs:,help,config,make,install,run,uninstall -- "$@") || { usage; exit 1; }

# eval set -- "$args"
# The while true won't work, as we need to run steps in order, not in the order the args are processed.
# TODO: we could handle multiple x/y/z in order, like this:
#    each arg read, sets val, then 

# First, let user know about emacs-sandbox.sh if they don't already have it
SANDBOX_LOCATION=$(type -p emacs-sandbox.sh)
if [[ -z "${SANDBOX_LOCATION}" ]]; then
    echo "You do not have emacs-sandbox.sh, you should probably grab this"
    echo "so you can run emacs from a sandboxed location"
    echo "Continuing anyhow"
fi
unset SANDBOX_LOCATION

if [[ -n $2 ]]; then
    echo "$0: Too many arguments, we only need one of the following"
    helpMe
elif [[ -n $1 ]]; then
    case $1 in 
        "-h"|"--help"|"-?") helpMe ;;
        "-d") pushd "${COMPILEHOME}"
	      cleanMe ;;
        "-e") pushd "${COMPILEHOME}" # Eventually changes to ${EMACSHOME}
	      execMe ;;
        "-c") pushd "${COMPILEHOME}"
	      configMe ;;
        "-m") pushd "${COMPILEHOME}"
	      makeMe ;;
        "-i") pushd "${COMPILEHOME}"
	      installMe ;;
        "-r") pushd "${EMACSHOME}"
	      runMe ;;
	"-u") pushd "${COMPILEHOME}"
	      uninstallMe ;;
        *) helpMe ;;
    esac
popd # FIXME: reverse whatever pushd we did, errors when helpMe called
else # We don't have $1
    helpMe
fi

