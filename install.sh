#!/bin/bash

# Default install all variants for user only
iconsDir=$HOME/.local/share/icons
iconsVariants=$(ls | grep "Flatery-" | grep -v "wallpapers" | cut -f 2- -d "-")

installWallpapers=false
wallpapersDir=$HOME/.local/share/backgrounds

function show_valid_variants {
	echo "Valid variants are : $iconsVariants" 
}

# Parsing options
while getopts "gwv:" opt; do
	case ${opt} in
		g ) 
			# Install globally
			iconsDir=/usr/share/icons
			wallpapersDir=/usr/share/backgrounds
			;;
		v )
			# Install only user selected variant(s)
			iconsVariants="$OPTARG"
			;;
		w )
			# Install wallpaper(s)
			installWallpapers=true
			;;
		: )
			# Given variant does not exist
			show_valid_variants
			exit 1
			;;
	esac
done

# Check write permissions for install dir
if [[ -w $iconsDir ]]; then

	echo "Installing icons into $iconsDir"

	# Apply icons variants
	for variant in $iconsVariants; do
		if [[ -d "Flatery-$variant" ]]; then 
			echo "	Installing variant $variant"
			rm -rf $iconsDir/$variant	
			cp -r Flatery-$variant $iconsDir
		else
			echo "Variant $variant does not exist"
		fi
	done
	
else 

	# Error, can't write
	echo "Can't write to $iconsDir"
	exit 1	

fi


# Install wallpapers
if $installWallpapers; then
	if [[ -w $wallpapersDir ]]; then
		
		echo "Installing wallpapers into $wallpapersDir"  

		# Install wallpapers
		rm -rf $wallpapersDir/Flatery-wallpapers
		cp -r Flatery-wallpapers $wallpapersDir

	else 

		# Error, can't write
		echo "Can't write to $wallpapersDir"
		exit 1	

	fi
fi

# If everything went good, exit with code 0
exit 0
