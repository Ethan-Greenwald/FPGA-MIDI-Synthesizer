import numpy as np
f = open("quarter_sin.mif", "w")
f.write("WIDTH=24;\nDEPTH=16384;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n")
for phase_idx in range(11025):
    float_phase = float(phase_idx)/11025
    value = int(np.sin(float_phase*np.pi/2)*(2**23) )
    value_str = f'{value:0>6X}'
    f.write(f'{phase_idx:0>4X}' + " : " + value_str + ";\n")
f.close();
