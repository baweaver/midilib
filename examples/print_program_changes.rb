#! /usr/bin/env ruby
#
# Shows use of print_decimal_numbers and print_channel_numbers_from_one.

require_relative '../lib/midilib/sequence'

DEFAULT_MIDI_TEST_FILE = 'NoFences.mid'

# Read from MIDI file
seq = MIDI::Sequence.new

File.open(ARGV[0] || DEFAULT_MIDI_TEST_FILE, 'rb') do |file|
  # The block we pass in to Sequence.read is called at the end of every
  # track read. It is optional, but is useful for progress reports.
  seq.read(file)
end

seq.each do |track|
  puts
  puts "*** track name \"#{track.name}\", \"#{track.instrument}\""
  track.each do |e|
    e.print_decimal_numbers = true
    e.print_channel_numbers_from_one = true
    puts e if e.is_a?(MIDI::ProgramChange)
  end
end
