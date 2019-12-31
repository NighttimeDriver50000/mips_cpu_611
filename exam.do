onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider inputs
add wave -noupdate /bitcounter/clk
add wave -noupdate /bitcounter/data
add wave -noupdate /bitcounter/frame
add wave -noupdate -divider outputs
add wave -noupdate -radix unsigned /bitcounter/cnt00
add wave -noupdate -radix unsigned /bitcounter/cnt01
add wave -noupdate -radix unsigned /bitcounter/cnt10
add wave -noupdate -radix unsigned /bitcounter/cnt11
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {503} 0}
configure wave -namecolwidth 94
configure wave -valuecolwidth 39
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0} {1785}

restart -f

force -freeze clk 1, 0 50 -r 100
force data 0
force frame 0


run 100

force frame 1
force data 1
run 100
force data 0
run 100
# 10

force data 1
run 100
run 100
# 11

force data 1
run 100
force data 0
run 100
# 10

force frame 0
run 200

force frame 1
force data 1
run 100
force data 0
run 100
# 10

force data 1
run 100
force data 0
run 100
# 10

force data 1
run 100
force data 0
run 100
# 10

run 100
force frame 0
run 100
