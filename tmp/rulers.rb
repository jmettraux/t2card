
require 'hexapdf'

doc = HexaPDF::Document.new
page = doc.pages.add
#page = doc.pages.add(HexaPDF::Type::Page.media_box(:B6))
c = page.canvas

c.font('Courier', size: 12).fill_color(0, 0, 0)

R =
  (0..9).collect { |k| "#{k}_23456789" }.join('') +
  (0..9).collect { |k| "#{k}_23456789" }.join('')

(8..20).each do |size|
  c.font_size = size
  c.text("size: #{size}", at: [ 10, 10 + (size - 8) * 40 + 20 ])
  c.text(R, at: [ 10, 10 + (size - 8) * 40 ])
end

doc.write('ruler.pdf')

