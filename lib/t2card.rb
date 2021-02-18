
require 'hexapdf'

doc = HexaPDF::Document.new
page = doc.pages.add
c = page.canvas

c.font('Helvetica', size: 12).fill_color(0, 0, 0)

c.text('Hello World', at: [ 10, 10 ])

doc.write('out.pdf')

