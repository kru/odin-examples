package glfw_shaders

import "core:fmt"
import gl "vendor:OpenGL"

main :: proc() {
	nrAttributes: i32
	// gl.GetIntegerv(gl.MAX_VERTEX_ATTRIBS, &nrAttributes)
	fmt.println("Maximum nr of vertex attributes supported,", gl.MAX_VERTEX_ATTRIBS)
}
