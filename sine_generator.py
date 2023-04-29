import numpy as np
f = open("full_sin.mif", "w")
DEPTH = 4096
f.write(f'WIDTH=24;\nDEPTH={DEPTH};\nADDRESS_RADIX=HEX;\nDATA_RADIX=DEC;\nCONTENT BEGIN\n')
for phase_idx in range(DEPTH):
    float_phase = float(phase_idx)/DEPTH
    value = int(np.sin(float_phase*2*np.pi)*(2**23) )
    value_str = f'{value:d}'
    f.write(f'{phase_idx:0>4X}' + " : " + value_str + ";\n")
f.write("END")
f.close()
