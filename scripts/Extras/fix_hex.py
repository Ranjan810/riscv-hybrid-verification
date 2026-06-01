# scripts/fix_hex.py

with open('tests/stress_test.hex', 'r') as f:
    tokens = f.read().split()

words = []
current_word = []

for token in tokens:
    if token.startswith('@'):
        continue  # Skip address markers
        
    current_word.append(token)
    
    # Once we have 4 bytes, combine them in Little-Endian order
    if len(current_word) == 4:
        word32 = current_word[3] + current_word[2] + current_word[1] + current_word[0]
        words.append(word32)
        current_word = []

# Write out the Vivado-compatible file
with open('tests/stress_test.hex', 'w') as f:
    for word in words:
        f.write(word + '\n')

print("SUCCESS: Formatted stress_test.hex for Vivado 32-bit readmemh!")