# TODO Cleanup that mess of a color prompt prep
# Put your fun prompt configs in here
# Mine includes Goodness like:
#  * Colors
#  * Git branch name

git_ps1 ()
{
	__git_ps1 1>/dev/null 2>/dev/null
	err=$?
	if [ "$err" == "0" ]; then
		ps=$( __git_ps1 "(%s)" )
		echo -ne "$ps"
	else
		echo -ne ""
	fi
}

# You want this here
use_color=false

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f $DOT/colors/dir_colors   ]] && match_lhs="${match_lhs}$(<$DOT/colors/dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
        && type -P dircolors >/dev/null \
        && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
        # Enable colors for ls, etc.  Prefer $DOT/colors/dir_colors #64489
        if type -P dircolors >/dev/null ; then
                if [[ -f $DOT/colors/dir_colors ]] ; then
                        eval $(dircolors -b $DOT/colors/dir_colors)
                elif [[ -f /etc/DIR_COLORS ]] ; then
                        eval $(dircolors -b /etc/DIR_COLORS)
                fi
        fi

        if [[ ${EUID} == 0 ]] ; then
                PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[0;36m\]$(git_ps1 "(%s)")\[\033[01;34m\] \W \$\[\033[00m\] '
        else
                PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[0;36m\]$(git_ps1 "(%s)")\[\033[01;34m\] \w \$\[\033[00m\] '
        fi

        alias ls='ls --color=auto'
        alias grep='grep --colour=auto'
else
        if [[ ${EUID} == 0 ]] ; then
                # show root@ when we don't have colors
                PS1='\u@\h \W \$ '
        else
                PS1='\u@\h \w \$ '
        fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs