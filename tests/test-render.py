import copy
import importlib.util
import json
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('formulae',ROOT/'tools/render-formulae.py');formulae=importlib.util.module_from_spec(spec);spec.loader.exec_module(formulae)
class FormulaTests(unittest.TestCase):
    def test_snapshot_and_windows_only_beta(self):
        result=formulae.render(json.loads((ROOT/'release-manifest.json').read_text()))
        self.assertIn('hybrid-bridge.rb',result)
        for name,text in result.items():
            self.assertEqual(text,(ROOT/'Formula'/name).read_text())
            self.assertNotIn('{{',text)
        catalog=json.loads((ROOT/'release-manifest.json').read_text())
        catalog['products']['hybrid-bridge']['beta']['artifacts']={'windows-msi':{'url':'https://example.com/setup.msi','sha256':'a'*64}}
        self.assertNotIn('hybrid-bridge-beta.rb',formulae.render(catalog))
    def test_new_stable_cli_keeps_beta_and_updates_both_architectures(self):
        catalog=json.loads((ROOT/'release-manifest.json').read_text())
        stable=copy.deepcopy(catalog['products']['cococo-cli']['beta']);stable['version']='1.0.0'
        for role,artifact in stable['artifacts'].items():
            artifact.update(url='https://example.com/'+role,sha256='a'*64)
        catalog['products']['cococo-cli']['stable']=stable
        rendered=formulae.render(catalog)
        self.assertIn('cococo-cli-beta.rb',rendered)
        text=rendered['cococo-cli.rb'];self.assertIn('class CococoCli < Formula',text)
        for arch in ['arm64','amd64']:self.assertIn('https://example.com/darwin-'+arch,text)
        self.assertIn('conflicts_with "cococo-cli-beta"',text)
    def test_bad_hash_and_channel_are_rejected(self):
        catalog=json.loads((ROOT/'release-manifest.json').read_text())
        catalog['products']['cococo-cli']['beta']['artifacts']['darwin-arm64']['sha256']='bad'
        with self.assertRaises(ValueError):formulae.render(catalog)
if __name__=='__main__':unittest.main()
