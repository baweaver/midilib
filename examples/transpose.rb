#! /usr/bin/env ruby
#
# usage: transpose.rb [--channel|-c channel] [--transpose|-t half_steps]
# midi_file [output_file]
#
#   -c channel      1-16; default is 1
#   -t half_steps   default = 12 (one octave up)
#

require 'getoptlong'
require_relative '../lib/midilib/sequence'
require_relative '../lib/midilib/io/seqreader'
require_relative '../lib/midilib/io/seqwriter'

def usage
  $stderr.print <<~EOF
        usage: #{$0} [--channel|-c channel] [--transpose|-t half_steps]
               input_midi_file output_midi_file
    #{'    '}
               --channel|-c   channel      1-16; default is 1
               --transpose|-t half_steps   default = 12 (one octave up)
  EOF
  exit(1)
end

transpose = 12
channel = 0

g = GetoptLong.new(['--transpose', '-t', GetoptLong::REQUIRED_ARGUMENT],
                   ['--channel', '-c', GetoptLong::REQUIRED_ARGUMENT])
g.each do |name, arg|
  case name
  when '--transpose'
    transpose = arg.to_i
  when '--channel'
    channel = arg.to_i - 1
  else
    usage
  end
end

usage unless ARGV.length >= 2

seq = MIDI::Sequence.new
File.open(ARGV[0], 'rb') do |file|
  # The block we pass in to Sequence.read is called at the end of every
  # track read. It is optional, but is useful for progress reports.
  seq.read(file) do |num_tracks, i|
    puts "read track #{i} of #{num_tracks}"
  end
end

seq.each do |track|
  track.each do |event|
    next unless event.is_a?(MIDI::NoteEvent) && event.channel == channel

    val = event.note + transpose
    if val < 0 || val > 127
      warn 'transposition out of range; ignored'
    else
      event.note = val
    end
  end
end

# Output to named file or stdout.
file = ARGV[1] ? File.open(ARGV[1], 'wb') : $stdout
seq.write(file)
file.close if ARGV[1]
