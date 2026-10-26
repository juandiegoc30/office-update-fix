from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit, unquote

root = Path(__file__).resolve().parents[1] / 'docs'
class Page(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.ids, self.links, self.lang, self.h1 = set(), [], None, 0
        self.feed(text)
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if 'id' in a:
            assert a['id'] not in self.ids, a['id']
            self.ids.add(a['id'])
        if tag == 'html': self.lang = a.get('lang')
        if tag == 'h1': self.h1 += 1
        for key in ('src', 'href'):
            if key in a: self.links.append(a[key])

for file in root.rglob('*.html'):
    page = Page(file.read_text())
    assert page.lang in ('es', 'en') and page.h1 == 1
    for link in page.links:
        url = urlsplit(link)
        if url.scheme: continue
        target = (file.parent / unquote(url.path)).resolve() if url.path else file
        if target.is_dir(): target /= 'index.html'
        assert target.is_file(), (file, link)
        if url.fragment:
            assert url.fragment in Page(target.read_text()).ids, (file, link)
print('PASS: both languages, unique IDs, headings, local assets, links and anchors.')
