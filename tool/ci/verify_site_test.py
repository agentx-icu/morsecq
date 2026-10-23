from pathlib import Path
import tempfile
import unittest
from verify_site import verify_site

class SiteRoutesTest(unittest.TestCase):
    def test_html_only_output_does_not_satisfy_app_slash_urls(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for language in ['', 'zh-CN/']:
                for page in ['privacy', 'terms', 'support']:
                    file = root / f'{language}{page}.html'
                    file.parent.mkdir(parents=True, exist_ok=True)
                    file.write_text('<html>MorseCQ</html>')
            with self.assertRaises(ValueError):
                verify_site(root)
            for language in ['', 'zh-CN/']:
                for page in ['privacy', 'terms', 'support']:
                    file = root / f'{language}{page}/index.html'
                    file.parent.mkdir(parents=True, exist_ok=True)
                    file.write_text('<html>MorseCQ</html>')
            self.assertEqual(len(verify_site(root)), 6)

if __name__ == '__main__':
    unittest.main()
