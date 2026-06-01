import sys
import os

def convert_hex(input_file, output_file):
    mem = {}
    current_addr = 0
    
    # 1. Parse the byte-oriented Verilog hex file
    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('@'):
                # GNU objcopy outputs byte addresses after the @ symbol
                current_addr = int(line[1:], 16)
            else:
                # Read space-separated bytes
                bytes_str = line.split()
                for b in bytes_str:
                    mem[current_addr] = int(b, 16)
                    current_addr += 1
                    
    if not mem:
        print(f"Warning: No data found in {input_file}")
        return

    # Find highest address to determine memory bounds
    max_addr = max(mem.keys())
    max_word_addr = (max_addr // 4) * 4
    
    # 2. Write the 32-bit word-oriented Hex file
    with open(output_file, 'w') as f:
        for addr in range(0, max_word_addr + 4, 4):
            # Little-Endian Assembly: [addr+3] [addr+2] [addr+1] [addr+0]
            b0 = mem.get(addr + 0, 0)
            b1 = mem.get(addr + 1, 0)
            b2 = mem.get(addr + 2, 0)
            b3 = mem.get(addr + 3, 0)
            
            # Combine into a single 32-bit integer
            word_val = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0
            
            # Write exactly 8 hex characters (32 bits) per line
            f.write(f"{word_val:08x}\n")
            
    print(f"SUCCESS: Converted {input_file} -> {output_file} (32-bit format)")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 scripts/fix_hex.py <input.hex> <output.hex>")
        sys.exit(1)
        
    in_file = sys.argv[1]
    out_file = sys.argv[2]
    
    if not os.path.exists(in_file):
        print(f"ERROR: Input file {in_file} does not exist.")
        sys.exit(1)
        
    convert_hex(in_file, out_file)