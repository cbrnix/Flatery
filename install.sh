#!/bin/bash

# Default install all variants for user only
iconsDir=$HOME/.local/share/icons
iconsVariants=$(ls | grep "Flatery-" | grep -v "wallpapers" | cut -f 2- -d "-")

installWallpapers=false
wallpapersDir=$HOME/.local/share/backgrounds

badVariant=false

function show_valid_variants {
	echo "Valid variants are : $iconsVariants" 
}

function show_help {
	cat << EOF
Usage : ./install.sh [-hgw] [-v variant]
Install the given variants of the icon theme, with or without wallpapers, locally or globally.
Default behavior is all variants, locally, no wallpapers.
Note that if a version of the to be installed variant exist in the install directory, it will first be removed.

-h	Display this help
-w	Install with wallpapers
-g	Install globally (needs root privileges)
-v	Install only the given variants, e.g. -v "Mint Orange"
	Special values are "none" and "all".
	If the option is absent, all variants are installed.
	
Exit status:
 0	if OK,
 1	if a selected variant does not exist (low severity, more of a warning),
 2	if write permissions to install directory are missing (more serious),
 3	if wrong arguments are given (e.g. -v without a value).
EOF
}

# Parsing options
while getopts ":hgwv:" opt; do
	case ${opt} in
		h )
			# Display help and exit
			show_help
			exit 0
			;;
		g ) 
			# Install globally
			iconsDir=/usr/share/icons
			wallpapersDir=/usr/share/backgrounds
			;;
		v )
			# Install only user selected variant(s)
			case "$OPTARG" in
				all )
					# Keep the full list
					;;
				none )
					# Don't install any variant
					iconsVariants=""
					;;
				* )
					# All other cases, use specified
					iconsVariants="$OPTARG"
					;;
			esac
			;;
		w )
			# Install wallpaper(s)
			installWallpapers=true
			;;
		? )
			# Wrong usage
			echo "Invalid option -$OPTARG"
			echo
			show_help
			exit 3
			;;
	esac
done


# Check if any variant is selected
if [[ -z $iconsVariants ]]; then
	
	echo "No icons will be installed."

else

	# Automatically create directory if the iconsDir does not exists. only if installing it non-globally
	# But check if we're installing it globally!
	if [[ "$iconsDir" == "/usr/share/icons" ]]; then
		# Check write permissions
		if [[ ! -w $iconsDir ]]; then
			echo "Can't write to $iconsDir"
			exit 2
		fi
	else
		# Automatically create iconsDir directory (aka. ~/.local/share/icons) if not exists
		mkdir -p "$iconsDir"
	fi

	# Install icons variants
	echo "Installing icons into $iconsDir"
	for variant in $iconsVariants; do
		if [[ -d "Flatery-$variant" ]]; then 
			echo "	Installing variant $variant"
			rm -rf $iconsDir/$variant	
			cp -r Flatery-$variant $iconsDir
		else
			echo "	Skipping variant $variant (doesn't exist)"
			badVariant=true
		fi
	done
	
fi


# Check if wallpapers are selected for install
if $installWallpapers; then
	
	# Also check for wallpapers directory. see if user home directory wallpapersDir exists
	if [[ "$wallpapersDir" == "/usr/share/backgrounds" ]]; then
		# Check write permissions
		if [[ ! -w $wallpapersDir ]]; then
			echo "Can't write to $wallpapersDir"
			exit 2	
		fi
	else
		# Automatically create wallpapersDir directory (aka. ~/.local/share/backgrounds) if not exists
		mkdir -p "$wallpapersDir"
	fi
	
	# Install wallpapers
	echo "Installing wallpapers into $wallpapersDir"  
	rm -rf $wallpapersDir/Flatery-wallpapers
	cp -r Flatery-wallpapers $wallpapersDir
	
fi

# Exit with appropriate code
if $badVariant; then
	exit 1
else
	exit 0
fi
