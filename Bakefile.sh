# shellcheck shell=bash

task.init() {
	pnpm install
}

# shellcheck disable=SC2034
task.generate-assets() {
	local decoration_color='#ffdeeb'
	local ecosystem_color='#e5dbff'
	local platform_color='#ffe8cc'

	for dir in ./pack-*/; do
		dir=${dir%/}
		bake.info "Generating for \"$dir\""
		local icon_name=${dir##*-}
		local type=${dir#./pack-}; type=${type%%-*}
		local color_var="${type}_color"
		local -n color="$color_var"

		if [[ $dir == ./pack-{ecosystem,platform}-!(all|other) ]]; then
			mkdir -p "$dir/assets"
			magick convert ./assets/package-512px.png -background "$color" -flatten -alpha off ./temp.png
			local resize=x225
			case $icon_name in
				php) resize=x175 ;;
				go) resize=x175 ;;
				java) resize=x325 ;;
				cpp) resize=x250 ;;
				latex) resize=x175 ;;
				markdown) resize=x200 ;;
				rust) resize=x250 ;;
				web) resize=x200 ;;
			esac
			magick ./temp.png \( "./assets/$icon_name.png" -resize "$resize" -geometry +8+8 \) -gravity southeast -composite "$dir/assets/icon.png"
			rm ./temp.png
		else
			magick convert ./assets/package-512px.png -background "$color" -flatten -alpha off "$dir/assets/icon.png"
		fi
	done
}

task.publish() {
	local pack=$1
	cd "$pack"

	vsce publish
	ovsx publish --pat "$(<'../.ovsx-token')"
}
