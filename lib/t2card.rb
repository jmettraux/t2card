
args = { fnames: [] }
  key = nil
  ARGV.each do |a|
    case a
    when /^-{1,2}(.+)$/
      args[key] = true if key
      key = $1
    else
      if key == nil
        args[:fnames] << a
      else
        args[key] = a
        key = nil
      end
    end
  end
  args[key] = true if key

if args['h'] || args['help']
  puts
  puts "Usage: t2card [OPTIONS] [FILE]"
  puts
  puts "Options:"
  puts
  puts "  -f k       "
  puts "  -f b6      "
  puts "  -f kyodai  Kyōto Daigaku B6 index card"
  puts "  -f c       "
  puts "  -f 5x3     "
  puts "  -f index   Index Card 3x5 inches (default)"
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
FORMATS['5x3'] = INDEX
FORMATS['3x5'] = INDEX
FORMATS['c'] = INDEX

format = FORMATS[args['format'] || args['f'] || 'index']
out = args['out'] || args['o'] || 'out.pdf'
dir = args['dir'] || '.'

out = File.join(dir, out) if ! out.match(/^\//)

#p format
#p args
#p out

doc = HexaPDF::Document.new
page = doc.pages.add
c = page.canvas

X0 = 10
Y0 = 820

c.font(format.font, size: format.fsize).fill_color(0, 0, 0)

if args['ruler']

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
    loop do
      l = line[0, format.width]
      line = line[format.width..-1]
      a << l
      break unless line
    end
    a }

plines.each_with_index do |line, i|
  c.text(line, at: [ X0, Y0 - i * format.lheight ])
end

doc.write(out)

