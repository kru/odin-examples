package numbers

import "core:fmt"

main :: proc() {
	a := 0b0101_1100 // 92
	a1 := 0b_1100 // 12
	b := 1.018
	c := 0o31 // 25(int) -> 31 = 011 001 -> 0001_1001
	d := 0xAE193

	fmt.printf("binary: %v\n", a)
	fmt.printf("binary: %v\n", a1)
	fmt.printf("float: %f\n", b)
	fmt.printf("octal: %v\n", c)
	fmt.printf("hexa: %f\n", f32(d))
}
