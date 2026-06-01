# scripts/fix_hds_hex.py

with open('tests/bench_ABCDEFG.hex', 'r') as f:
    tokens = f.read().split()

words = []
current_word = []

for token in tokens:
    if token.startswith('@'):
        continue  # Skip address markers
        
    current_word.append(token)
    
    # Combine 4 bytes in Little-Endian order
    if len(current_word) == 4:
        word32 = current_word[3] + current_word[2] + current_word[1] + current_word[0]
        words.append(word32)
        current_word = []

with open('tests/bench_ABCDEFG_vivado.hex', 'w') as f:
    for word in words:
        f.write(word + '\n')

print("SUCCESS: Formatted bench_ABCDEFG.hex into bench_ABCDEFG_vivado.hex for Vivado readmemh!")