import numpy as np
f = open("full_sin.mif", "w")
DEPTH = 8192
f.write(f'WIDTH=24;\nDEPTH={DEPTH};\nADDRESS_RADIX=HEX;\nDATA_RADIX=DEC;\nCONTENT BEGIN\n')
scale = 2**(23) - 1
for phase_idx in range(DEPTH):
    value = int(scale*np.sin(2*np.pi*phase_idx/DEPTH))
    value_str = f'{value}'
    f.write(f'{phase_idx:0>4X}' + " : " + value_str + ";\n")
f.write("END")
f.close()


# scale = 2**(sample_width*8-1)-1
# wave_table = np.array([scale*np.sin(2*np.pi*(i/N)) for i in range(N)], dtype=np.int32)	
# wave_table = wave_table.astype(int)
# return wave_table