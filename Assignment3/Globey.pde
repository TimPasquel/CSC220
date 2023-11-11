int GlobeyCount = 0, GlobeyMax = 0;
final int globeResolution = 100 ;
void makeglobePShape() {
  // STUDENT change globe.png to your image.
  globePImage = loadImage("IMG_1900.jpg");
  // globePImage.resize(globeResolution, globeResolution);
  // globePImage.loadPixels();
  globePShape = createShape(SPHERE,globeResolution);
  // from 2022's BOX: ,globeResolution, globeResolution*1.5, globeResolution*2);
  
  //ADDED THIS LINE TO SET THE TEXTURE ON GLOBEY
  globePShape.setTexture(globePImage);
  
  globePShape.setStroke(false);
  // STUDENT set the texture on this PShape to globePImage.
  // See calls to setTexture(t) in 
  // https://faculty.kutztown.edu/parson/fall2022/CSC220FA2022DemoSome3D.txt
  globePShape.translate(globeResolution, globeResolution,0); // shapeMode(CENTER) broken
  int newcells = 0 ;
  for (int x = 0 ; x < width ; x += globeResolution*2) {
    for (int y = 0 ; y < height ; y += globeResolution*3) {
      for (int z = minimumZ ; z < maximumZ ; z += globeResolution*4) {
        newcells++ ;
      }
    }
  }
  int oldcells = avatars.length ;
  Avatar [] newavatars = new Avatar [ oldcells + newcells ];
  java.lang.System.arraycopy(avatars, 0, newavatars, 0, oldcells);
  int cellix = oldcells ;
  for (int x = 0 ; x < width ; x += globeResolution*2) {
    for (int y = 0 ; y < height ; y += globeResolution*3) {
      for (int z = minimumZ ; z < maximumZ ; z += globeResolution*4) {
        // SLOW!!! avatars = (Avatar []) append(avatars, new Globey(x, y, z, avatars.length));
        newavatars[cellix] = new Globey(x, y, z, cellix);
        cellix++ ;
      }
    }
  }
  GlobeyCount = GlobeyMax = newcells ;
  avatars = newavatars ;
}
float lastHayNote = 0 ;
class Globey implements Avatar {
  final int channel = 1;
  final int DrawbarOrgan = 16 ;
  // http://midi.teragonaudio.com/tutr/gm.htm
  final int pitch = 36 ;  // multiple of 12 for "C"
  // http://midi.teragonaudio.com/tutr/gm.htm says 17 is Drawbar Organ
  int x, y, z, avatarsIndex ;
  
  int mowCounter = 0;
  
  float mowScaleXYZ = 1.0 ;
  Globey(int x, int y, int z, int avatarsIndex) {
    this.x = x ;
    this.y = y ;
    this.z = z ;
    this.avatarsIndex = avatarsIndex ;
  }
  void display() {
    push();
    translate(x, y, z);
    
    //ADDED THE SCALING
    if(mowCounter > 0) {
      scale(mowScaleXYZ);
      mowScaleXYZ -= 0.005;
    }
    shape(globePShape, 0, 0);
    pop();
    // USE MIDI channel 1 and instrument organ. Cannot run in constructor
    // must wait until after initMIDI() runs in draw():
    sendMIDI(ShortMessage.PROGRAM_CHANGE, channel, DrawbarOrgan, 0);
    float elapsed = ((float)frameCount / (float)frameRate) - lastHayNote ;
    int volumeAdjust = 7 ;
    int volumeLevel = int(constrain(map(float(GlobeyCount), 0.0, float(GlobeyMax), 64.0, 127.0), 64.0, 127.0));
    sendMIDI(ShortMessage.CONTROL_CHANGE, channel, volumeAdjust, volumeLevel);
    if (lastHayNote == 0 || elapsed > 60) {
      sendMIDI(ShortMessage.NOTE_ON, channel, pitch, 127);
      lastHayNote = ((float)frameCount / (float)frameRate);
      // See http://midi.teragonaudio.com/tech/midispec.htm
    }
  }
  void move() {
    // ADDED TO THE MOVE FUNCTION
    if(mowCounter > 0) {
      mowCounter += 1;
      if(mowScaleXYZ <= 0.1) {
        GlobeyCount = constrain(GlobeyCount-1, 0, GlobeyCount);
        // println("DEBUG GlobeyCount GlobeyMAX", GlobeyCount, GlobeyMax);
        if (GlobeyCount <= 0) {
        avatars[avatarsIndex] = null ;
        sendMIDI(ShortMessage.NOTE_OFF, channel, pitch, 0);
        }
      }
    }
  }
  int getX() { return x; }
  int getY() { return y; }
  int getZ() { return z; }
  int [] getBoundingBox() {
    int [] result = new int[6];
    result[0] = x - globeResolution ;
    result[1] = y - globeResolution ;
    result[2] = z - globeResolution ;
    result[3] = x + globeResolution ;
    result[4] = y + globeResolution ;
    result[5] = z + globeResolution ;
    return result ;
  }
  void shuffle() {}
  void forceshuffle() {
      x = int(random(0,width));
      y = int(random(0, height));
      z = int(random(minimumZ, maximumZ));
  }
  void mow() {
    mowCounter += 1;
    //GlobeyCount = constrain(GlobeyCount-1, 0, GlobeyCount);
    // println("DEBUG GlobeyCount GlobeyMAX", GlobeyCount, GlobeyMax);
    //if (GlobeyCount <= 0) {
      //avatars[avatarsIndex] = null ;
      //sendMIDI(ShortMessage.NOTE_OFF, channel, pitch, 0);
    //}
  }
}
