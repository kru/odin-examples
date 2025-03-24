package gflw_window

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"


WIDTH :: 1600
HEIGHT :: 900
TITLE :: "My Window"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

process_input :: proc(window_handle: glfw.WindowHandle) {
	if glfw.GetKey(window_handle, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window_handle, true)
	}
}

main :: proc()  {
	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	window_handle := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)

	defer glfw.Terminate()
	defer glfw.DestroyWindow(window_handle)

	if window_handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	// Load OpenGL context or the "state" of OpenGL
	glfw.MakeContextCurrent(window_handle)
	// Load OpenGL function pointer with the specified OpenGL major and minor version
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	for !glfw.WindowShouldClose(window_handle) {
		process_input(window_handle)
		// process all incoming events like keyboard press
		glfw.PollEvents()

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		glfw.SwapBuffers(window_handle)
	}
}
