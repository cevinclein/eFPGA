

create_clock [get_ports CLK]  -name CLK -period 40


set_disable_timing [get_pins  -hierarchical -regexp {.*BEG.*}]