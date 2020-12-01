#!/bin/bash
#
# v0.1 Initial cut, should be mostly complete

EMACSCONFHOME="${HOME}/.emacs-playpen"
# You WILL want to fiddle with these if you don't want the args I chose
CONFIGPARAMS="--with-imagemagick --with-xwidgets --prefix=${EMACSHOME}"
COMPILEHOME="${HOME}/src/emacs"

# We might need to rejigger this from args, which will screw with runMe and helpMe
EMACSHOME="${HOME}/bin/emacs-playpen"

# Help function, usage()
helpMe() {
    echo "$0: emacs recompiler script"
    echo "   -h    help (this text)"
    echo "   -d    distclean (no compile)"
    # This could be rolled into -r
    # echo "   -e    set emacs binary home for running"
    # echo "         default location is ${EMACSHOME}"
    echo "   -c    run configure with params"
    echo "      params are: ${CONFIGPARAMS}"
    echo "   -m    compile (no install)"
    echo "   -i    install to ${EMACSHOME}"
    echo "   -r    execute from ${EMACSHOME}"
}

# Runs make distclean
cleanMe() {
    echo "This will REMOVE all compiled files including makefiles"
    make distclean
}

# Runs configure phase
configMe() {
    ./configure ${CONFIGPARAMS}
}

# Runs make (hopefully we ran configure first)
makeMe() {
    make
}

# Runs the install phase (currently don't need sudo, but would have normally done)
installMe() {
    # echo "This will require you to enter in your password" # only needed for system dirs
    # sudo make install
    make install
}

# Assuming everything else is done, runs compiled emacs from install
runMe() {
    pushd ${EMACSHOME}
    # Stick up a buffer with relevant instructions to run in *scratch*
    # vim notepad.txt  # currently handled by my emacs-28.0.50 client
    # TODO: We should probably capture whether emacs runs or dies
    RETVAL=$( emacs-sandbox.sh -d "${EMACSCONFHOME}" -i quelpa-use-package )
    if [[ ${RETVAL} != 0 ]]; then
        echo "Completed with ${RETVAL}"
    else
        echo "Completed with success"
    fi
    popd
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
# args=$(getopt -n "$0" -o cde:hmir -l emacs:,help,config,make,install,run -- "$@") || { usage; exit 1; }

# eval set -- "$args"
# The while true won't work, as we need to run steps in order, not in the order the args are processed.
# TODO: we could handle multiple x/y/z in order, like this:
#    each arg read, sets val, then 
# First, change to home of compile, as most args address this

if [[ -n $2 ]]; then
    echo "$0: Too many arguments, we only need one of the following"
    helpMe
elif [[ -n $1 ]]; then
    case $1 in 
        "-h"|"--help"|"-?") helpMe ;;
        "-d") pushd ${COMPILEHOME}
	      cleanMe ;;
        "-e") pushd ${COMPILEHOME}
	      execMe ;;
        "-c") pushd ${COMPILEHOME}
	      configMe ;;
        "-m") pushd ${COMPILEHOME}
	      makeMe ;;
        "-i") pushd ${COMPILEHOME}
	      installMe ;;
        "-r") pushd ${EMACSHOME}
	      runMe ;;
        *) helpMe ;;
    esac
popd # reverse whatever pushd we did
else # We don't have $1
    helpMe
fi

