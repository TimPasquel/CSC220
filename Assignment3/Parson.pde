/**
 *  Professor is my Avatar-derived class that displays & moves a mobile Professor.
 *  You must write your own Avatar-derived class. You can delete class Professor
 *  or use it as a starting point for your re-named class. Document what your
 *  class adds or changes at the top of the class declaration like this.
**/
int ProfessorScaleStep = 0 ;
int ProfessorTimeDelaySlot = 0 ;
class Professor extends CollisionDetector {
  /* The data fields store the state of the Avatar. */
  protected int legdist = 0 ; // You can initialize to a constant here.
  int channel = 0 ;
  int mypitch = 0 ;
  float mydelay = 0 ;
  float [] delaySeconds = {.1, .15, .25};
  int instrument = 106 ; // http://midi.teragonaudio.com/tutr/gm.htm
  
  //ADDED VAIRBALE
  long lastNoteOn = 0 ;
  
  Professor(int avx, int avy, int avz, float spdx, float spdy, float spdz, float avscale) {
    super(avx,avy,avz,spdx,spdy,spdz,avscale,0,0,0);
    // Call the base class constructor to initialize its data fields,
    // then initialize this class' data fields.
    xlimitright = width ;
    ylimitbottom = height ; // limit off-screen motion to
    xlimitleft = 0 ;    // one width or height off the display
    ylimittop = 0 ;    // in either direction
    int [] myscale = scales[2];  // major scale
    mypitch = myscale[ProfessorScaleStep] + 48  ;
    // major scale, next note in scale, halfway up keyboard
    ProfessorScaleStep = (ProfessorScaleStep + 1) % myscale.length ;
    mydelay = delaySeconds[ProfessorTimeDelaySlot];
    instrument += ProfessorTimeDelaySlot ;
    ProfessorTimeDelaySlot = (ProfessorTimeDelaySlot + 1) % delaySeconds.length ;
  }
  void shuffle() {
    forceshuffle(); // always do it.
  }
  // The display() function simply draws the Avatar object.
  // The move() function updates the Avatar object's state.
  void display() {
    // Draw the avatar.
    push(); // STUDENT *MUST* use push() & translate first in display().
    translate(myx, myy, myz);
    scale(myscale);
    noStroke();
    fill(240, 150, 150);
    // STUDENT: Notice that I enclose each body part in a push()-pop()
    // pair for 3D. This is because we *MUST* use translate to position a 3D
    // box() or sphere, may use scale(X,Y,Z) to stretch a box or sphere - scaling
    // is needed to stretch a sphere, and must use rotateX, rotateY, and/or rotateZ
    // to position the body part at a non-multiple of 90 degrees. pop()
    // is needed to discard these transformations after the body part displays.
    // 2D REWORK ellipse(0, 0, 50, 40); // head, 0,0 is the conceptual center of the object.
    push();  // HEAD, requires scaling
    scale(50,40,50);  // ratio width:height:depth
    sphere(.5);    // diameter is 10 * scale
    pop();   // END OF HEAD
    // An object rotates around its 0,0 point.
    // 2D REWORK quad(-5 , 0, 5 , 0, 10 , 40 , -10 , 40 ); // neck
    push();  // START NECK
    translate(0, 20, 0);    // 2d neck was at 40 pixels above 0,0
    scale(20,40,20);
    sphere(.5);
    pop();  // end of neck
    fill(0);  // professor gown
    // 2D REWORK ellipse(0, 60 , 40 , 80 ); // torso IN FRONT OF NECK
    push();  // TORSO REQUIRES TRANSLATE & SCALE
    translate(0, 60, 0);
    // scale(4,8,4);  // ratio w:h:d
    // sphere(5);    // diameter is 10 * scale
    scale(40,80,40);  // ratio w:h:d, taken from above ellipse
    sphere(.5);  // radius of .5 == diameter of 1, you can make all spheres this way
    pop();  // END OF TORSO
    stroke(0);
    // stick arms & legs
    strokeWeight(10) ; // REWORD 2D strokeWeight(8);
    // STUDENT NOTE: strokeWeight extends into the Z plane
    line(0, 60 , -20 -abs(10-legdist) , 120 );  // left leg
    line(0, 60 , 20 +abs(10-legdist) , 120 );  // right leg
    strokeWeight(7); // 2D REWORK strokeWeight(5);
    line(0, 60 , -40 , 20 -2*abs(10-legdist) );   // left arm
    line(0, 60 , 40 , 20 +2*abs(10-legdist) );   // right arm
    strokeWeight(2);
    fill(0, 50, 255);
    // 2D REWORK ellipse(-10 , -5 , 10 , 10 ); // avatar's left side of glasses
    push();
    translate(-6, -2, 20);
    sphere(5);
    pop(); // end left eye
    // 2D REWORK ellipse(10 , -5 , 10 , 10 ); // avatar's right side of glasses
    push();
    translate(6, -2, 20);
    sphere(5);
    pop(); // end right eye
    // 2D line(-5 , -5 , 5 , -5 ); // glasses connector
    line(-6, -2, 25, 6, -2, 25); // glasses connector
    // 2D line(-15 , -5 , -22 , -8 ); // left earpiece
    // 2D line(15 , -5 , 22 , -8 ); // right earpiece
    // 3D lines go thru head, so just put a black circle around it
    push(); // Put a noFill band around the head to hold the glasses.
    noFill();
    stroke(0);
    translate(0, -2, 0);  // Higher up looks like a halo.
    rotateX(radians(90));
    ellipse(0,0,50,50);
    pop();
    fill(0);
    // 2D REWORK ellipse(0, 1 , 5 , 5 );  // nose
    push(); // nose
    translate(0, 4, 25);
    sphere(2);
    pop(); // nose
    // 2D REWORK arc(0, 10 , 20 , 10 , 0, PI); // mouth
    // PLOT A BUNCH OF CONTIGUOUS 2D MOUTHS
    push();
    translate(0, 0, 20);
    for (int back = 0 ; back < 20 ; back++) {
      arc(0, 10 , 20 , 10 , 0, PI); // mouth
      translate(0,0,-1);  // next mouth is behind previous
    }
    pop();
    // 2D REWORK quad(-30 , -15 , 30 , -15 , 15 ,-30 , -35 , -30 );// hat
    push();  // HAT
    translate(0, -22, 0);
    rotateY(radians(45));  // rakish angle
    box(40, 15, 40);
    pop();
    pop(); // STUDENT *MUST* use pop() last in display().
  }
  // The move() function updates the Avatar object's state.
  void move() {
    // get ready for movement in next frame.
    myx = round(myx + speedX) ;
    myy = round(myy + speedY) ;
    myz = round(myz + speedZ);
    legdist = (legdist+1) % 20 ;

    //ADDED THIS VARIABLE
    
    //ADDED THE MIDI CONTORLS
    Set<Avatar> colliders = detectCollisions();
    if (colliders.size() > 0) {
      //CHANGED THE INSTRUMENT
      instrument = 166;
      sendMIDI(ShortMessage.PROGRAM_CHANGE, channel, instrument, 0);
      // sendMIDI(ShortMessage.PROGRAM_CHANGE, channel, instrument, 0);
      int volumeAdjust = 7 ;
      sendMIDI(ShortMessage.CONTROL_CHANGE, channel, volumeAdjust, 48);
      int balanceControl = 8 ;
      int balanceLocation = int(constrain(map(myx, 0, width, 0, 127),0,127));  // 64 is centered in stereo field
      sendMIDI(ShortMessage.CONTROL_CHANGE, channel, balanceControl, balanceLocation);
      sendMIDI(ShortMessage.NOTE_ON, channel, mypitch, 48);
      sendMIDI(ShortMessage.NOTE_ON, channel, mypitch+4, 48);
      sendMIDI(ShortMessage.NOTE_ON, channel, mypitch+5, 48);
      sendMIDI(ShortMessage.NOTE_ON, channel, mypitch+7, 48);
      lastNoteOn = getMilliseconds();
      // See http://midi.teragonaudio.com/tech/midispec.htm
    } else if ((getMilliseconds() - lastNoteOn) > 5000) {  // note has been playing 5 secs
      sendMIDI(ShortMessage.CONTROL_CHANGE, channel, 123, 0); // all notes off!
      lastNoteOn = getMilliseconds();
    }
    
    
    
    for (Avatar other : colliders) {
      float probability = random(0, 100);
      
      //CHANGED THE VALUE FROM 60 TO 85 TO MAKE IT FASTER
      
      if (probability < 85) { // mow 60% of them
        other.mow();
      }
    }
  }
  int [] getBoundingBox() {
    int [] result = new int[6];
    result[0] = myx-round(40*myscale) ; // left extreme of left arm
    result[1] = myy - round(30*myscale); // top of hat
    result[2] = myz - round(25*myscale);  // back of head
    result[3] = myx + round(myscale*max(20 +abs(10-legdist),40)); // max of right leg & arm
    result[4] = myy + round(120*myscale) ; // bottom of legs
    result[5] = myz + round(25*myscale);  // front of head
    return result ;
  }
}

// D. Parson's makecustomPShapeParsonParson vectors taken from Shape3DDemo
/*
 *  Make and return a custom 3D PShape created using vertex() calls,
 *  for use in Avatar-derived class VectorAvatar. The textureimg
 *  parameter may be null; when it is non-null, use it to texture
 *  at least one of the planar sides of the returned PShape. If the
 *  STUDENT decides not to texture, remove the loadImage call at the
 *  top of the sketch, allowing textureimg to be null.
*/
PShape makecustomPShapeParsonParson(PImage textureimg) {
  // STUDENT NOTE: Even though
  // https://processing.org/reference/vertex_.html
  // shows use of 3D coordinates combined with texture:
  // vertex(x, y, z, u, v), that did not work for my
  // 3D planar surfaces like the initial base that varies
  // the Z value. Intuitively, the limitation makes sense,
  // since texturing images are 2D, and varying the Z
  // coordinate can create a non-planar shape, even though
  // mine are all planar. I switched to vertex(x, y, u, v)
  // for the textured planar surface in the else clause below,
  // then used rotateX and translate to move it into position
  // within the GROUP PShape.
  PShape base = createShape();
  base.beginShape();
  if (textureimg == null) {
    base.vertex(0,100,100);      // vertex(x, y, z) with varying
    base.vertex(-100,100,-100);  // Z did not work for texturing,
    base.vertex(100,100,-100);   // even though the constant Y value
    base.vertex(0,100,100);      // makes this surface planar.
    base.endShape();
    base.setFill(color(0,255,255));
  } else {
    int imgwidth = round(textureimg.width);  // Use 2D vertex() calls to
    int imgheight = round(textureimg.height); // get texture to work.
    base.texture(textureimg);
    base.vertex(0,100,imgwidth/2,imgheight-1); // The u,v coordinates
    base.vertex(-100,-100,0,0);  // in the vertex() calls tell where in
    base.vertex(100,-100,imgwidth-1,0); // the PImage to attach to the
    base.endShape();  // PShape vertex.
    base.rotateX(radians(90));  // rotate with apex pointing at me
    base.translate(0,100,0);    // translate to drop it down to the floor.
    // base.setTint(color(250,197,200)); // light pink -- leave tint off for clean look.
  }
  PShape left = createShape();  // Al of the other planar sides use the Z coordinate.
  left.beginShape();
  left.vertex(0,100,100);      // center,bottom,front
  left.vertex(0,-100,0);       // center,top, center (pyramid apex)
  left.vertex(-100,100,-100);  // left,bottom,back
  left.vertex(0,100,100);      // close at original vertex for setFill to work
  left.endShape();
  left.setFill(color(255,0,0));
  PShape right = createShape();
  right.beginShape();
  right.vertex(0,100,100);
  right.vertex(0,-100,0);
  right.vertex(100,100,-100);
  right.vertex(0,100,100);;
  right.endShape();
  right.setFill(color(0,255,0));
  PShape back = createShape();
  back.beginShape();
  back.vertex(-100,100,-100);
  back.vertex(100,100,-100);
  back.vertex(0,-100,0);
  back.vertex(-100,100,-100);
  back.endShape();
  back.setFill(color(0,0,255));
  PShape custom = createShape(GROUP);
  custom.addChild(base);
  custom.addChild(left);
  custom.addChild(right);
  custom.addChild(back);
  custom.translate(100,100,0); // trial-and-error, slide into centered position
  return custom ;
}

/**
 *  VectorAvatar is my Avatar-derived class that displays & moves a custom vector PShape.
 *  STUDENT must update getBoundingBox() to work with their PShape.
**/
class VectorAvatar extends CollisionDetector {
  /* The data fields store the state of the Avatar. */
  float rotXspeed = .04 ;
  float rotYspeed = .05 ;
  float myrotX = 0, myrotY = 0 ;
  VectorAvatar(int avx, int avy, int avz, float spdx, float spdy, float spdz, float avscale) {
    super(avx,avy,avz,spdx,spdy,spdz,avscale,0,0,0);
    // Call the base class constructor to initialize its data fields,
    // then initialize this class' data fields.
    xlimitright = width ;
    ylimitbottom = height ; // limit off-screen motion to
    xlimitleft = 0 ;    // one width or height off the display
    ylimittop = 0 ;    // in either direction
    rotZspeed = .03 ;
  }
  void shuffle() {
    forceshuffle(); // always do it.
  }
  // The display() function simply draws the Avatar object.
  // The move() function updates the Avatar object's state.
  void display() {
    // Draw the avatar.
    push(); // STUDENT *MUST* use push() & translate first in display().
    translate(myx, myy, myz);
    scale(myscale);
    rotateX(myrotX);
    rotateY(myrotY);
    rotateZ(myrotZ);
    shape(customPShapeParson, 0, 0);
    pop(); // STUDENT *MUST* use pop() last in display().
  }
  // The move() function updates the Avatar object's state.
  void move() {
    // get ready for movement in next frame.
    myx = round(myx + speedX) ;
    myy = round(myy + speedY) ;
    myz = round(myz + speedZ);
    myrotX += rotZspeed ;
    myrotY += rotYspeed ;
    myrotZ += rotZspeed ;
    Set<Avatar> colliders = detectCollisions();
    for (Avatar other : colliders) {
      float probability = random(0, 100);
      if (probability < 40) { // mow() 40% of them
        other.mow();
      }
    }
  }
  int [] getBoundingBox() {
    // These limits do not account for rotation, but the
    // Pyramid PShape is -100 to +100 in all 3 dimensions.
    // You may have to adjust this to work with your PShape.
    int [] result = new int[6]; // customPShapeParson.depth does not work.
    /*
    println("DEBUG customPShapeParson width,height,depth: " + customPShapeParson.width + ","
      + customPShapeParson.height + "," + customPShapeParson.depth);
      I DOUBLED SIZE OF BOUNDING B
    */
    result[0] = round(myx - 100 * myscale * 2) ; //round(myx-myscale*customPShapeParson.width/2.0);
    result[1] = round(myy - 100 * myscale * 2) ; //round(myy-myscale*customPShapeParson.height/2.0);
    result[2] = round(myz - 100 * myscale * 2) ; //round(myz-myscale*customPShapeParson.depth/2.0);
    result[3] = round(myx + 100 * myscale * 2) ; //round(myx+myscale*customPShapeParson.width/2.0);
    result[4] = round(myy + 100 * myscale * 2) ; //round(myy-myscale*customPShapeParson.width/2.0);
    result[5] = round(myz + 100* myscale * 2) ; // round(myz-myscale*customPShapeParson.depth/2.0);
    return result ;
  }
}
