# InputDefs.gd
extends Node

# --- Button bitmasks ---
const UPmask       = 1 << 0
const DOWNmask     = 1 << 1
const FORWARDmask     = 1 << 2
const BACKmask    = 1 << 3
const CIRCLEmask   = 1 << 4
const TRIANGLEmask = 1 << 5
const SQUAREmask   = 1 << 6
const Xmask        = 1 << 7
const R1mask       = 1 << 8
const R2mask       = 1 << 9
const L1mask       = 1 << 10
const L2mask       = 1 << 11
const JUMPmask     = 1 << 12

# --- Input history buffers ---
const BUFFER_SIZE = 30

var p1_history: Array[int] = []
var p2_history: Array[int] = []

# --- Record a frame of input ---
func record_p1(mask: int):
	p1_history.append(mask)
	if p1_history.size() > BUFFER_SIZE:
		p1_history.pop_front()

func record_p2(mask: int):
	p2_history.append(mask)
	if p2_history.size() > BUFFER_SIZE:
		p2_history.pop_front()

# --- Sequence detection ---
func detect_sequence(sequence: Array, history: Array[int]) -> bool:
	var step = 0
	for held in history:
		if step_matches(sequence[step], held):
			step += 1
			if step == sequence.size():
				#history.clear()
				return true
	return false

func step_matches(required: int, held: int) -> bool:
	return (held & required) == required

# --- Debug: convert a mask to a readable string ---
const INPUT_NAMES = {
	1 << 12: "Airborne",
	1 << 0:  "UP",
	1 << 1:  "DOWN",
	1 << 2:  "LEFT",
	1 << 3:  "RIGHT",
	1 << 4:  "CIRCLE",
	1 << 5:  "TRIANGLE",
	1 << 6:  "SQUARE",
	1 << 7:  "X",
	1 << 8:  "R1",
	1 << 9:  "R2",
	1 << 10: "L1",
	1 << 11: "L2",
	
}

func mask_to_string(mask: int) -> String:
	if mask == 0:
		return "NONE"
	var parts = []
	for bit in INPUT_NAMES:
		if mask & bit:
			parts.append(INPUT_NAMES[bit])
	return " + ".join(parts)
