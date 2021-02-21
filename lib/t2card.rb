
VALUE_ARGS = %w[ dir o out ]

args = { fnames: [] }
  as = ARGV.dup
  while a = as.shift
    case a
    when /^--?(.+)$/
      args[$1.to_sym] = VALUE_ARGS.include?($1) ? as.shift : true
    else
      args[:fnames] << a
    end
  end

if args[:h] || args[:help]

  puts
  puts "Usage: t2card [OPTIONS] [FILE]"
  puts
  puts "  Reads a text file and formats it as a PDF that, when printed"
  puts "  fits a given index card size"
  puts
  puts "Options:"
  puts
  puts "  -k"
  puts "  -b6"
  puts "  --kyodai           Kyōto Daigaku B6 index card"
  puts "  -i"
  puts "  --index            Index Card 3x5 inches (default)"
  puts
  puts "  --raw              Print the formatted lines to STDOUT and exits"
  puts
  puts "  --dir path/to/dir  Changes the working directory"
  puts
  puts "  --ruler            Prints a ruler (horizontal and vertical)"
  puts
  puts "  -o {FILE}"
  puts "  -out {FILE}        changes the output file (defaults to ./out.pdf)"
  puts
  puts "  -h"
  puts "  --help             Print this help"
  puts

  exit 0
end


require 'hexapdf'
require 'ostruct'

KYODAI = OpenStruct.new(
  name: 'kyodai', width: 85, font: 'Courier', fsize: 10, lheight: 11,
  height: 33)
INDEX = OpenStruct.new(
  name: 'index', width: 65, font: 'Courier', fsize: 9, lheight: 9,
  height: 23)

FORMATS = {}
FORMATS['kyodai'] = KYODAI
FORMATS['b6'] = KYODAI
FORMATS['k'] = KYODAI
FORMATS['index'] = INDEX
FORMATS['i'] = INDEX

k = args.keys.find { |k| FORMATS.keys.include?(k.to_s) }.to_s
format = FORMATS[k]

fail "No format keyed under #{k.inspect}" unless format

out = args[:out] || args[:o] || 'out.pdf'
dir = args[:dir] || '.'

out = File.join(dir, out) if ! out.match(/^\//)

#p format
#p args
#p out

doc = HexaPDF::Document.new
page = doc.pages.add
c = page.canvas

X0 =  10
Y0 = 820

c.font(format.font, size: format.fsize).fill_color(0, 0, 0)

if args[:ruler]

  s = ([ '0123456789' ] * 10).join('')
  c.text(s[0, format.width], at: [ X0, Y0 ])
  (1..format.height).each do |y|
    s = y.to_s
    s = s + ' ' + format.to_h.inspect if y == 1
    c.text(s, at: [ X0, Y0 - y * format.lheight ])
  end

  doc.write(out)

  exit 0
end

lines = args[:fnames]
  .inject([]) { |a, fname|
    path = fname.match?(/^\//) ? fname : File.join(dir, fname)
    a.concat((File.readlines(path) rescue [])) }
  .collect(&:rstrip)
lines.shift while lines.first == ''

plines = lines
  .inject([]) { |a, line|
    l = ''
    line.scan(/\s+|[^\s]+/) do |r|
      if l.length + r.length > format.width
        a << l
        l = r.strip
      else
        l += r
      end
    end
    a << l
    a }

if args[:raw]

  puts plines

  exit 0
end

plines.each_with_index do |line, i|

  y = Y0 - i * format.lheight

  break if y < 28

  c.text(line, at: [ X0, y ])
end

doc.write(out)

