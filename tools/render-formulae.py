#!/usr/bin/env python3
"""Generate formulae from the shared release catalog; no fetching or publishing."""
import argparse
import json
from pathlib import Path
import re
from urllib.parse import urlparse
ROOT = Path(__file__).resolve().parents[1]


def quoted(value):
    return json.dumps(value).replace('#{', r'\#{')


def render(catalog):
    if catalog.get('schema') != 1: raise ValueError('unsupported catalog schema')
    result = {}
    for product, stem, klass in [('hybrid-bridge','hybrid-bridge','HybridBridge'),('cococo-cli','cococo-cli','CococoCli')]:
        for channel, entry in catalog['products'][product].items():
            assets=entry['artifacts']
            if not all('darwin-'+a in assets for a in ('arm64','amd64')): continue
            if channel not in ('stable','beta'): raise ValueError('unsupported channel')
            version=entry['version']
            if not re.fullmatch(r'\d+\.\d+\.\d+(?:-beta\.\d+)?',version): raise ValueError('invalid version')
            if ('-beta.' in version)!=(channel=='beta'): raise ValueError('version/channel mismatch')
            formula=stem+('-beta' if channel=='beta' else '')
            values={'CLASS':klass+('Beta' if channel=='beta' else ''),'VERSION':quoted(version),'CHANNEL':channel,'FORMULA':formula,
                    'CONFLICT':quoted(stem if channel=='beta' else stem+'-beta')}
            for role,key in [('darwin-arm64','DARWIN_ARM64'),('darwin-amd64','DARWIN_AMD64'),('notices','NOTICES')]:
                if role=='notices' and product!='cococo-cli':continue
                a=assets[role]
                if urlparse(a['url']).scheme!='https' or not re.fullmatch('[0-9a-f]{64}',a['sha256']):raise ValueError('invalid artifact')
                values[key+'_URL']=quoted(a['url']);values[key+'_SHA']=quoted(a['sha256'])
            template=(ROOT/'templates'/f'{stem}.rb.in').read_text()
            result[formula+'.rb']=re.sub(r'\{\{([A-Z0-9_]+)\}\}',lambda m:values[m[1]],template)
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--manifest',type=Path,required=True);p.add_argument('--output-dir',type=Path,default=ROOT);p.add_argument('--check',action='store_true');a=p.parse_args()
    for name,data in render(json.loads(a.manifest.read_text())).items():
        path=a.output_dir/'Formula'/name
        if a.check:
            if not path.exists() or path.read_text()!=data:raise SystemExit('stale formula: '+name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_text(data)
