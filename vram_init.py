f = open("vram_initialize.mif", "w")
DEPTH = 4096
f.write(f'WIDTH=8;\nDEPTH={DEPTH};\nADDRESS_RADIX=HEX;\nDATA_RADIX=DEC;\nCONTENT BEGIN\n')
for i in range(DEPTH):
    ...
f.write("END")
f.close()


N = [00000000,
     00000000,
     11000110,
     11100110,
     11110110,
     11111110,
     11011110,
     11001110,
     11000110,
     11000110,
     11000110,
     11000110,
     00000000,
     00000000,
     00000000,
     00000000]