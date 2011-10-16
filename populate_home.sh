#!/bin/bash
dotFiles=`ls -a`
if [ ! -d "$HOME/dot_backup" ]; then
	mkdir $HOME/dot_backup
	for file in ${dotFiles:4}; do
		if [ -e "$HOME/$file" ]; then
			cp-r $HOME/$file $HOME/dot_backup/
		fi
	done
fi
for file in ${dotFiles:4}; do
	if [ "$file" != '.git' ] && [ "$file" != 'populate_home.sh' ] \
		&& [ "$file" != '.ssh' ] && [ "$file" != "gnome-term" ]; then
		`rm -rf $HOME/$file` > /dev/null #BE careful with this
		ln -s $PWD/$file $HOME/ > /dev/null
		err=$?
		if [ $err == 0 ]; then
			echo "$file put in Home"
		else echo "Trouble with $file"
		fi
	elif [ "$file" == '.ssh' ]; then
		mv $HOME/.ssh/config $HOME/.ssh/config_old \
			> /dev/null # Likely some won't have
		ln -s $PWD/.ssh/config $HOME/.ssh/config
		err=$?
		if [ $err == 0 ]; then
			echo "$file put in Home"
		else echo "Trouble with $file"
		fi
	fi
done

gtdot=$HOME/.gconf/apps/gnome-terminal/profiles/Default/%gconf.xml
if [ -e "$gtdot" ] && \
	[ ! -h "$gtdot" ]; then
	echo -ne "Moving gnome-terminal configuration to backup in its directory"
	mv $gtdot ${gtdot}_old
	echo "done"
	echo -ne "Linking gnome-terminal to git configuration"
	ln -s $PWD/gnome-term/%gconf.xml $gtdot
	echo "done"
fi

echo ""
echo ""
echo "Making sure git options set..."
git config --global user.name "Jon Phenow"
git config --global user.email "j.phenow@gmail.com"
git config --global color.ui true
echo "Git colors and user defaults set"

echo ""
echo ""
echo "Ensuring .viminfo writeable"
chown $USER $HOME/.viminfo # add > /dev/null when tested
echo ".viminfo accessible for user now"
