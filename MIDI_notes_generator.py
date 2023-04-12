import numpy as np
f = open("MIDI_freq_to_period.hex", "w")

for n in range(128):
    freq = 2**((n-69)/12.0)*440
    period = int(50000000.0/freq)
    period_str = f'{period:0>6X}'
    # print(period)
    f.write(period_str + "\n")

# for phase_idx in range(11025):
#     if(phase_idx % 8 == 0): #add hex address at each line (after 8 entries)
#         addr_str = f'{phase_idx:0>5X}' #f'{addr:05}'
#         f.write("\n@" + addr_str)
        
#     float_phase = float(phase_idx)/11025
#     value = int(np.sin(float_phase*np.pi/2)*(2**23) )
#     value_str = f'{value:0>6X}'
#     f.write(" " + value_str)
f.close();
