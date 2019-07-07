import sys

sys.path.append('/Users/apua/rsted/venv/lib/python3.7/site-packages/')

s = sys.argv[1]
#s = sys.stdin.read()

from docutils import frontend, utils
from docutils.parsers import rst

v = frontend.OptionParser(components=(rst.Parser,)).get_default_values()
d = utils.new_document('test data', v)
#d.reporter.debug_flag=True
rst.Parser().parse(s, d)
print(d.pformat(), end='')
