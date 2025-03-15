package generate_image_info


import "core:fmt"
import "core:image"
import "core:image/png"
import "core:os"
import "core:path/slashpath"
import "core:strings"


_ :: png


INPUT_DIR :: "images"
OUTPUT_FILE :: "images.odin"


main :: proc() {
	d, d_err := os.open(INPUT_DIR, os.O_RDONLY)
	assert(d_err == nil, "Failed opening '" + INPUT_DIR + "' folder'")
	defer os.close(d)

	input_files, _ := os.read_dir(d, -1)

	f, _ := os.open(OUTPUT_FILE, os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
	defer os.close(f)

	images: [dynamic]os.File_Info

	for i in input_files {
		if !strings.has_suffix(i.name, ".png") {
			continue
		}

		append(&images, i)
	}
	fmt.fprintln(f,
`// This file is generated. Re-generate it by running:
//	odin run generate_image_info
	package image_viewer

	Image :: struct {
		width: int,
		height: int,
		data: []u8,
	}

	Image_Name :: enum {`,
	)
	for i in images {
		fmt.fprintfln(f, "	%v,", strings.to_ada_case(slashpath.name(i.name)))
	}

	fmt.fprintln(f, `}
		images := [Image_Name]Image {`)

	for i in images {
		img, img_err := image.load_from_file(i.fullpath)

		if img_err == nil {
			enum_name := strings.to_ada_case(slashpath.name(i.name))
			fmt.fprintfln(f, "	.%v = {{ data = #load(\"images/%v\"), width = %v, height = %v }},", enum_name, i.name, img.width, img.height
			)
		}
	}

	fmt.fprintfln(f, "}")
}
