require 'rubygems'
require 'midiator'

midi = MIDIator::Interface.new
midi.autodetect_driver
 
midi.control_change 32, 10, 1 # TR-808 is Program 26 in LSB bank 1
midi.program_change 10, 26

include MIDIator::Drums

counter = 0
prev = nil
beats = []
puts "Tap out a beat with the Enter key"
loop do
  gets
  now = Time.now
  midi.play BassDrum2, 0.1, 10
  if prev
    beats << now - prev 
    counter += 1
  end
  prev = now
  break if counter == 7
end
average = beats.inject(0){|sum, beat| sum += beat} /7

puts "You tapped #{(60/average).to_i} beats per minute."
sleep(0.5)
puts "Here goes..."

16.times do |i|
  midi.play LowTom1, average, 10
end