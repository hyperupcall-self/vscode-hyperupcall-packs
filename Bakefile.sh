# shellcheck shell=bash

task.init() {
	pnpm install
}

# shellcheck disable=SC2034
task.svg() {
	local decoration_color='#ffdeeb'
	local ecosystem_color='#e5dbff'
	local platform_color='#ffe8cc'

	magick convert ./assets/package.png -resize 512x512 ./assets/package-512px.png
	inkscape -w 512 -h 512 -o ./assets/package-512px.png ./assets/package.svg
	for dir in ./pack-{ecosystem,platform}-!(all|other)/; do
		dir=${dir%/}
		local icon_name=${dir##*-}
		local type=${dir#./pack-}; type=${type%-*}
		local color_var="${type}_color"
		local -n color="$color_var"
		mkdir -p "$dir/assets"
		magick convert ./assets/package-512px.png -background "$color" -flatten -alpha off ./temp.png
		if [ ! -f "./assets/$icon_name.png" ]; then
			if [ -f "./assets/$icon_name.svg" ]; then
				inkscape -w 512 -o "./assets/$icon_name.png" "./assets/$icon_name.svg"
			elif [ -f "./assets/$icon_name.jpg" ]; then
				inkscape -w 512 -o "./assets/$icon_name.png" "./assets/$icon_name.jpg"
			fi
		fi
		resize=x200
		[ "$icon_name" = 'php' ] && resize=x150
		[ "$icon_name" = 'go' ] && resize=x125
		[ "$icon_name" = 'java' ] && resize=x300
		[ "$icon_name" = 'cpp' ] && resize=x225
		magick ./temp.png \( "./assets/$icon_name.png" -resize "$resize" -geometry +8+8 \) -gravity southeast -composite "$dir/assets/icon.png"
		rm ./temp.png
	done
}

task.publish() {
	local pack=$1
	cd "$pack"

	vsce publish
	ovsx publish --pat "$(<'../.ovsx-token')"
}

task.format:fix() {
	./node_modules/.bin/prettier --write .
}
