package image_viewer

import "core:image"
import "core:image/png"

_ :: png

import "core:fmt"

main :: proc() {
	for &img, name in images {
		fmt.println("%v is %v x %v pixels and %v bytes large", name, img.width, img.height, len(img.data))

		if img.width > 15 {
			loaded_img, loaded_img_err := image.load_from_bytes(img.data)

			if loaded_img_err == nil {
				fmt.println("%v has width > 15, so we loaded it!", name)
				fmt.println("The loaded PNG image is indeed %v pixel wide!", loaded_img.width)
			}
		}
	}
}
