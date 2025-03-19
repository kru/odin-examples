package main

import "core:fmt"
import "base:runtime"

main :: proc() {
	explicit_context_definition()
}

explicit_context_definition :: proc "c" () {
	// Try comment the following statement out below
	context = runtime.default_context()
	fmt.println("\n#explicit context definition")
	dummy_procedure()
}

dummy_procedure :: proc() {
	fmt.println("dummy_procedure")
}
