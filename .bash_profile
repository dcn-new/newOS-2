# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Set XDG runtime directory
if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# Declare a pure wayland session
#export XDG_SESSION_TYPE="wayland"
#export GDK_BACKEND="wayland"
#export QT_QPA_PLATFORM="wayland;xcb"

# aliases (for loggging in)
alias start="exec dbus-run-session sway"
