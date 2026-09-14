import json
import os

transcript_path = r'C:\Users\lers2\.gemini\antigravity\brain\5a22e84a-49ba-41d5-a6fb-1dc9b67de386\.system_generated\logs\transcript_full.jsonl'
files = {}

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if 'tool_calls' in data:
                for tc in data['tool_calls']:
                    name = tc.get('name')
                    args = tc.get('args', {})
                    if name == 'write_to_file':
                        target = args.get('TargetFile')
                        if target:
                            files[target] = args.get('CodeContent', '')
                    elif name == 'replace_file_content':
                        target = args.get('TargetFile')
                        if target in files:
                            target_content = args.get('TargetContent', '')
                            replacement = args.get('ReplacementContent', '')
                            files[target] = files[target].replace(target_content, replacement)
        except Exception as e:
            continue

for path, content in files.items():
    if 'app_turismo' in path and path.endswith('.dart'):
        # Fix backslashes to forward slashes just in case we need to normalize paths
        # Actually `path` is whatever the tool was called with.
        try:
            with open(path, 'w', encoding='utf-8') as out:
                out.write(content)
            print(f"Recovered {path}")
        except Exception as e:
            print(f"Failed to recover {path}: {e}")
