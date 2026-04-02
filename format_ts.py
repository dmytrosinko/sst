import re

try:
    with open('src/sst_en.ts', 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = re.sub(
        r'<source>(.*?)</source>\s*<translation type="unfinished"></translation>',
        r'<source>\1</source>\n        <translation>\1</translation>',
        content
    )

    with open('src/sst_en.ts', 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print("Successfully replaced formatting in TS file")
except Exception as e:
    print(f"Error: {e}")
