vlib work

vlog -timescale 1ns/1ns mux.v

vsim mux

log {/*}

add wave {/*}

force {SW[0]} 0
force {SW[1]} 1
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 1

force {SW[7]} 0 0 ns, 1 20 ns -repeat 40
force {SW[8]} 0 0 ns, 1 40 ns -repeat 80
force {SW[9]} 0 0 ns, 1 80 ns -repeat 160


run 160ns