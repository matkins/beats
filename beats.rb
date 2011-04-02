require 'rubygems'
require 'midiator'
require 'lib/stats'

puts "Loading beats..."




@midi = MIDIator::Interface.new
@midi.autodetect_driver

@midi.control_change 32, 10, 1 # TR-808 is Program 26 in LSB bank 1
@midi.program_change 10, 26

include MIDIator::Drums

four_four = [ BassDrum1,
  [BassDrum2, SnareDrum1],
  BassDrum1,
  [BassDrum1, SnareDrum1, SnareDrum2]
]

def get_time_signature
  print "Enter a time signature, [4/4]: "
  tss = gets
  return [4,4] if tss.strip == ''
  num, den = tss.split('/').collect{|n| n.to_i}
  if num && den && num > 0 && den > 0
    [num,den]
  else
    get_time_signature
  end
end

def get_tempo
  print "Enter a tempo in bpm or tap out two bars:"
  prev = nil
  beats = []
  (bpb * 2).times do |counter|
    tempoin = gets
    if !(bpm = tempoin.strip.to_i).zero?
      return bpm, Time.now
    end
    now = Time.now
    beat(0.1, counter)
    if prev
      beats << now - prev 
      counter += 1
    end
    prev = now
  end
  average = beats.average
  if beats.variation_coefficient > 5
    puts "That beat was a bit irregular, please try again!"
    get_tempo
  else
    return (60/average).to_i, prev
  end
end

def beat_length
  60 / @tempo.to_f
end

def beat(length, beat_num)
  if beat_num % bpb == 0
    @midi.play BassDrum2, length, 10
  else
    @midi.play LowTom1, length, 10
  end
end

def bpb
  @time_signature[0]
end

# Begin here....

@time_signature = get_time_signature
@tempo, last_beat = get_tempo


puts "You tapped at #{@tempo} beats per minute."
puts "Here goes..."
while Time.now - last_beat < beat_length do ; end

loop do #4.times do
  bpb.times do |i|
    @midi.play four_four[i], beat_length/2, 10
    @midi.play ClosedHiHat, beat_length/2, 10
  end
end


#More accurate ?
# start = Time.now
# now = nil
# (bpb * 40).times do |i|
#   loop do
#     now = Time.now
#     break if now - last_beat >= beat_length
#   end
#   beat(beat_length/2, i)
#   puts "#{(now - start) - ((i + 1) * beat_length)}"
#   last_beat = now
# end