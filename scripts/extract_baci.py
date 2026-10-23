"""Extract the selected HS12 universe, retaining source decimal strings.

Usage: python3 scripts/extract_baci.py /path/to/BACI_HS12_V202601.zip
The official ZIP is temporary input; filtered CSVs and audit are retained.
"""
import csv
import hashlib
import io
import json
import sys
import zipfile
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT.parent / 'Main' / 'data'
MANIFEST = json.loads((ROOT / 'data/source-manifest.json').read_text())
CODES = set(MANIFEST['selected_hs6'])
HEADER = ['year', 'exporter_code', 'importer_code', 'hs6', 'value_thousand_usd', 'weight_tonnes']

def main():
    audit = []
    countries = set()
    with zipfile.ZipFile(sys.argv[1]) as z, (OUT / 'baci_selected_2012_2024.csv').open('w', newline='') as all_file:
        combined = csv.writer(all_file)
        combined.writerow(HEADER)
        for year in range(2012, 2025):
            name = f'BACI_HS12_Y{year}_V202601.csv'
            path = OUT / f'electronics_telecom_{year}.csv'
            n = missing = selected = 0
            total = Decimal(0)
            keys = set()
            with z.open(name) as raw, io.TextIOWrapper(raw) as source, path.open('w', newline='') as target:
                writer = csv.writer(target)
                writer.writerow(HEADER)
                for row in csv.DictReader(source):
                    n += 1
                    if row['k'] not in CODES:
                        continue
                    assert int(row['t']) == year
                    key = (row['i'], row['j'], row['k'])
                    assert key not in keys, (year, key)
                    keys.add(key)
                    q = '' if row['q'] in ('NA', '') else row['q']
                    v = Decimal(row['v'])
                    assert v >= 0 and (not q or Decimal(q) >= 0)
                    values = [row['t'], row['i'], row['j'], row['k'], row['v'], q]
                    writer.writerow(values)
                    combined.writerow(values)
                    selected += 1
                    missing += not q
                    total += v
                    countries.update((row['i'], row['j']))
            result = dict(year=year, source_rows=n, selected_rows=selected, missing_weight=missing,
                          value_thousand_usd=str(total), duplicate_keys=0,
                          sha256=hashlib.sha256(path.read_bytes()).hexdigest())
            audit.append(result)
            print(json.dumps(result), flush=True)
    output = dict(source=MANIFEST['url'], release='202601', classification='HS12', years=audit,
                  country_codes=sorted(countries), selected_rows=sum(a['selected_rows'] for a in audit),
                  combined_sha256=hashlib.sha256((OUT/'baci_selected_2012_2024.csv').read_bytes()).hexdigest())
    (ROOT/'docs/historical-validation.json').write_text(json.dumps(output, indent=2)+'\n')

if __name__ == '__main__':
    main()
