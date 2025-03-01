onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib axis_broadcaster_0_opt

do {wave.do}

view wave
view structure
view signals

do {axis_broadcaster_0.udo}

run -all

quit -force
