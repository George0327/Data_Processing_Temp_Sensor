onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+fifo8x32 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fifo8x32 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {fifo8x32.udo}

run -all

endsim

quit -force
