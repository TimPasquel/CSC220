// All MIDI global variables & global MIDI functions are in this tab. //<>// //<>//
import javax.sound.midi.* ;  // Get everything in the Java MIDI (Musical Instrument Digital Interface) package.

// Added 2021 for MIDI display() in csc220 fall 2021 Assignment 3.
int [][] scales = {
  {0, 2, 4, 7, 9, 12}, // major pentatonic -- should give fairly consonant combinations
  {0, 3, 5, 7, 10}, // minor pentatonic
  {0, 2, 4, 5, 7, 9, 11, 12}, // major scale
  {0, 2, 3, 5, 7, 8, 10, 12}  // harmonic minor
  // musician students can add others
} ;
int curscale = 1 ;  // one of the above, LEFT and RIGHT arrows adjust this
int tonic = 0 ;  // offset into above scales, this is the key of C
int octave = 5 ; // 5 * 12 notes in an octave gives us middle C
int volume = 64 ;  // use UP and DOWN ARROWS to adjust overall volume (not per-note velocity)
// for each MIDI channel 0 through 15


// MIDI VARIABLES, see http://faculty.kutztown.edu/parson/spring2017/MidiKBSpring2016Parson.txt
final int midiDeviceIndex = 0 ;  // setup() checks for number of devices. Use one for output.
// NOTE: A final variable is in fact a constant that cannot be changed.
MidiDevice.Info[] midiDeviceInfo = null ;
// See javax.sound.midi.MidiSystem and javax.sound.midi.MidiDevice
MidiDevice device = null ;
// See javax.sound.midi.MidiSystem and javax.sound.midi.MidiDevice
Receiver receiver = null ;
// javax.sound.midi.Receiver receives your OUTPUT MIDI messages (counterintuitive?)
// SEE https://www.midi.org/specifications/item/gm-level-1-sound-set but start at 0, not 1
int patch = 98 ; // tonal percussion per above link, change with up & down arrow keys
int lastnote = -1 ; // most recent midi note in the range 0..127
int lastvelocity = -1 ; // most recent midi note in the range 0..127
int interval = 0 ; // for sending out a harmonic interval
int controller = 1 ;  // start with modwheel, let user adjust
int controllerDegree = 0 ; // initially no audio effect amount

void initMIDI() {
  // MIDI:
  // 1. FIND OUT WHAT MIDI DEVICES ARE AVAILABLE FOR VARIABLE midiDeviceIndex.
  midiDeviceInfo = MidiSystem.getMidiDeviceInfo();
  for (int i = 0 ; i < midiDeviceInfo.length ; i++) {
    println("MIDI DEVICE NUMBER " + i + " Name: " + midiDeviceInfo[i].getName()
      + ", Vendor: " + midiDeviceInfo[i].getVendor()
      + ", Description: " + midiDeviceInfo[i].getDescription());
  }
  // 2. OPEN ONE OF THE MIDI DEVICES UP FOR OUTPUT.
  try {
    device = MidiSystem.getMidiDevice(midiDeviceInfo[midiDeviceIndex]);
    device.open();  // Make sure to close it before this sketch terminates!!!
    // There should be a way to schedule a method when Processing closes this
    // sketch, so we can close the device there, but it is not documented for Processing 3.
    receiver = device.getReceiver();
    // NOTE: Either of the above method calls can throw MidiUnavailableException
    // if there is no available device or if it does not have a Receiver to
    // which we can send messages. The catch clause intercepts those error messages.
    // See https://www.midi.org/specifications/item/gm-level-1-sound-set, use patch variable
    ShortMessage noteMessage1 = new ShortMessage() ;
    noteMessage1.setMessage(ShortMessage.PROGRAM_CHANGE, 0, patch, 0); // to channel 0
    receiver.send(noteMessage1, -1L);  // send it now
    ShortMessage noteMessage2 = new ShortMessage() ;
    noteMessage2.setMessage(ShortMessage.PROGRAM_CHANGE, 1, (patch+32)%128, 0); // to channel 1
    receiver.send(noteMessage2, -1L);  // send it now
  } catch (MidiUnavailableException mx) {
    System.err.println("MIDI DEVICE " + midiDeviceIndex + " UNAVAILABLE: " + mx.getMessage()); // Error messages go here.
    device = null ;
    receiver = null ; // Do not try to use them.
    println("MIDI DEVICE " + midiDeviceIndex + " UNAVAILABLE: " + mx.getMessage());
  } catch (InvalidMidiDataException dx) {
    System.err.println("MIDI ERROR: " + dx.getMessage()); // Error messages go here.
  }
  for (int c = 0 ; c < 16 ; c++) {
    sendMIDI(ShortMessage.CONTROL_CHANGE, c, 7, volume);
  }
}
 
void sendMIDI(int command, int channel, int data1, int data2) {
  // Construct & send a ShortMessage with these parameters.
  if (channel >= 0 && channel <= 15) {
    // Added channel validation because we are using -1 as "no sound".
    try {
      ShortMessage message = new ShortMessage(command, channel, data1, data2);
      receiver.send(message, -1L);  // -1L means send it now, not queued for later.
    } catch (InvalidMidiDataException ix) {
      System.err.println("InvalidMidiDataException: " + ix.getMessage());
    }
  }
}

long getMilliseconds() {
  return java.lang.System.currentTimeMillis();
}
