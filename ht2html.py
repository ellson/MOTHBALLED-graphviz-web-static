#!/usr/bin/python

import sys

if len(sys.argv) < 2:
  exit

pageset = sys.argv[1].split()

source = sys.argv[2]
basename = source.split('.')[0]

fout = open(basename + '.html', 'w')
fout.write('''<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!--
    This is a generated document.  Please edit "''' + basename + '''.ht" instead
    and then type "make".
-->
<html>
<head>
<title>GraphViz</title>
</head>
<body bgcolor="white">
<table cellspacing="20">
<tr><td>
<!-- icon -->
<img src="doc.png" alt="">
</td><td>
<!-- header -->
<h1>GraphViz ''' + basename + '''</h1>
</td></tr>
<tr><td valign="top">
<!-- menu -->
\t<table hight="100%" bgcolor="#c0c0ff">\n''')

for page in pageset:
  menuitem = page.split('.')[0]
  if basename == menuitem:
    fout.write('\t<tr><td bgcolor="#c0ffc0">' + menuitem + '</td></tr>\n')
  else:
    fout.write('\t<tr><td><a href="' + menuitem + '.html">' + menuitem + '</a></td></tr>\n')

fout.write('''\t</table> 
</td><td valign="top">
<!-- body -->\n''')

fin = open(source, 'r')
fout.write(fin.read())
fin.close

fout.write('''</td></tr>
</table>
</body>
</html>\n''')

fout.close
