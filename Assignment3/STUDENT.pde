// All STUDENT instructions are in this tab. TEST AFTER EACH STUDENT STEP!!!
// STUDENT AVATAR & any extra variables for it go in STUDENT tab unless otherwise noted.
// This is due via D2L Assignment 3 at ???.

class CodeBullet extends CollisionDetector {

  //ADDED THE VARIABLE DATA FIELDS
  /* The data fields store the state of the Avatar. */
  protected int legdist = 12 ; // You can initialize to a constant here.
  int channel = 10 ;  // Your Avatar MUST use channel 10.
  int mypitch = 55 ;
  float mydelay = 0 ;
  float [] delaySeconds = {.1, .15, .25}; //IGNORE THE DELAY
  //  I stopped using the delay and switched to making sound upon collisions.
  //INSTRUMENT 106 TO 57, A TRUMPET
  int instrument = 124 ; // http://midi.teragonaudio.com/tutr/gm.htm
  //ADDED VAIRBALE
  long lastNoteOn = 0 ;
  //END OF ADDITION OF VARIABLES
  
  
  CodeBullet(int avx, int avy, int avz, float spdx, float spdy, float spdz, float avscale) {
    super(avx,avy,avz,spdx,spdy,spdz,avscale,0,0,0);
    // Call the base class constructor to initialize its data fields,
    // then initialize this class' data fields.
    xlimitright = width ;
    ylimitbottom = height ; // limit off-screen motion to
    xlimitleft = 0 ;    // one width or height off the display
    ylimittop = 0 ;    // in either direction
    
    //int [] myscale = scales[2];  // major scale
    //mypitch = myscale[ProfessorScaleStep] + 48  ;
    // major scale, next note in scale, halfway up keyboard
    //ProfessorScaleStep = (ProfessorScaleStep + 1) % myscale.length ;
    //mydelay = delaySeconds[ProfessorTimeDelaySlot];   //STUDENT IGNORE DELAY
    //instrument += ProfessorTimeDelaySlot ;
    //You can come up with only one OR more than 1 instrument for your avatar.
    //ProfessorTimeDelaySlot = (ProfessorTimeDelaySlot + 1) % delaySeconds.length ;
    
    
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
        //push();  // HEAD, requires scaling
        //scale(50,40,50);  // ratio width:height:depth
        //sphere(.5);    // diameter is 10 * scale
        //pop();   // END OF HEAD'   '
    
    fill(108, 108, 108);
    push(); //TV Frame
    translate(0, 0, 0);
    box(40,40,40);
    pop(); //End of TV Frame
    
    push(); //Back of TV Frame
    translate(0, 0, -18);
    box(25, 25, 25);
    pop(); //End of Back of TV Frame
    
    fill(0);
    push(); //Antena
    translate(-8, -25, 0);
    box(5, 15, 2);
    pop(); //End of Antena
    
    push(); //Ball of Antena;
    translate(-8, -30, 0);
    sphere(4);
    pop(); //End of Ball of Antena
    
    fill(65, 255, 25);
    push(); //TV Screen
    translate(0, 0, 6);
    box(30, 30, 30);
    pop(); //End of TV Screen
    
    fill(0);
    push(); //Bullet Casing
    translate(0, 0, 25);
    box(8, 4, 2);
    pop(); //End of Bullet Casing
    
    push(); //Bullet
    translate(5, 0, 25);
    sphere(2.2);
    pop(); //End of Bullet
    
    // An object rotates around its 0,0 point.
    // 2D REWORK quad(-5 , 0, 5 , 0, 10 , 40 , -10 , 40 ); // neck
    fill(108, 108, 108);
    push();  // START NECK
    translate(0, 20, 0);    // 2d neck was at 40 pixels above 0,0
    scale(20,40,20);
    sphere(.5);
    pop();  // end of neck
    
    fill(0);  // CodeBullet gown
    // 2D REWORK ellipse(0, 60 , 40 , 80 ); // torso IN FRONT OF NECK
    push();  // TORSO REQUIRES TRANSLATE & SCALE
    translate(0, 60, 0);
    // scale(4,8,4);  // ratio w:h:d
    // sphere(5);    // diameter is 10 * scale
    scale(40,80,40);  // ratio w:h:d, taken from above ellipse
    sphere(.5);  // radius of .5 == diameter of 1, you can make all spheres this way
    pop();  // END OF TORSO
    
    fill(108);
    push(); //Under Shirt
    translate(0, 60, 5);
    scale(20, 75, 40);
    sphere(.5);
    pop(); //End of Under Shirt
    
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
        //push();
        //translate(-6, -2, 20);
        //sphere(5);
        //pop(); // end left eye
    // 2D REWORK ellipse(10 , -5 , 10 , 10 ); // avatar's right side of glasses
        //push();
        //translate(6, -2, 20);
        //sphere(5);
        //pop(); // end right eye
    // 2D line(-5 , -5 , 5 , -5 ); // glasses connector
        //line(-6, -2, 25, 6, -2, 25); // glasses connector
    // 2D line(-15 , -5 , -22 , -8 ); // left earpiece
    // 2D line(15 , -5 , 22 , -8 ); // right earpiece
    // 3D lines go thru head, so just put a black circle around it
        //push(); // Put a noFill band around the head to hold the glasses.
        //noFill();
        //stroke(0);
        //translate(0, -2, 0);  // Higher up looks like a halo.
        //rotateX(radians(90));
        //ellipse(0,0,50,50);
        //pop();
    fill(0);
    // 2D REWORK ellipse(0, 1 , 5 , 5 );  // nose
        //push(); // nose
        //translate(0, 4, 25);
        //sphere(2);
        //pop(); // nose
    // 2D REWORK arc(0, 10 , 20 , 10 , 0, PI); // mouth
    // PLOT A BUNCH OF CONTIGUOUS 2D MOUTHS
        //push();
        //translate(0, 0, 20);
        //for (int back = 0 ; back < 20 ; back++) {
          //arc(0, 10 , 20 , 10 , 0, PI); // mouth
          //translate(0,0,-1);  // next mouth is behind previous
        //}
        //pop();
    // 2D REWORK quad(-30 , -15 , 30 , -15 , 15 ,-30 , -35 , -30 );// hat
        //push();  // HAT
        //translate(0, -22, 0);
        //rotateY(radians(45));  // rakish angle
        //box(40, 15, 40);
        //pop();
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
      
      instrument = 124 ;
      channel = 10;
      
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

      //SECOND INSTRUMENT GROUPING
      instrument = 110;
      channel = 11;
      
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
  //END OF THE MIDI CONTROLS
  int [] getBoundingBox() {
    int [] result = new int[6];
    result[0] = myx-round(40*myscale) ; // left extreme of left arm
    //top of hat was 30 instead of 35
    result[1] = myy - round(35*myscale); // top of hat
    //back of head was 25 instead of 30
    result[2] = myz - round(30*myscale);  // back of head
    result[3] = myx + round(myscale*max(20 +abs(10-legdist),40)); // max of right leg & arm
    result[4] = myy + round(120*myscale) ; // bottom of legs
    result[5] = myz + round(25*myscale);  // front of head
    return result ;
  }
}

                      //DONE
// STUDENT 1 (10%) Copy your Avatar class (nothing else) into this tab and add constructor
// calls in the setup() function in the main tab within this loop.
  //for (int i = avatars.length/2-2 ; i < avatars.length ; i++) {
  //    // STUDENT 1 construct your avatars in this loop.
  //}
// Test that your avatar displays and moves properly before STEP 2.



                    //DONE?
// STUDENT 2 (10%) The constructor parameters should not need to change from Assignment 2.
// There are no new arguments. The MIDI instrument, channel, and other MIDI properties are
// defined inside my Professor class and will be inside your class after it displays.
// Class Professor is in tab Parson. Here are the MIDI data fields at the top of the class.
// You can come up with only one OR more than 1 instrument for your avatar.

//int ProfessorScaleStep = 0 ;
//int ProfessorTimeDelaySlot = 0 ;
//class Professor extends CollisionDetector {
//  /* The data fields store the state of the Avatar. */
//  protected int legdist = 0 ; // You can initialize to a constant here.
//  int channel = 0 ;
//  int mypitch = 0 ;
//  float mydelay = 0 ;
//  float [] delaySeconds = {.1, .15, .25}; IGNORE THE DELAY
//  I stopped using the delay and switched to making sound upon collisions.
//  int instrument = 106 ; // http://midi.teragonaudio.com/tutr/gm.htm

// and in the constructor code:

    //int [] myscale = scales[2];  // major scale
    //mypitch = myscale[ProfessorScaleStep] + 48  ;
    //// major scale, next note in scale, halfway up keyboard
    //ProfessorScaleStep = (ProfessorScaleStep + 1) % myscale.length ;
    //mydelay = delaySeconds[ProfessorTimeDelaySlot];   STUDENT IGNORE DELAY
    //instrument += ProfessorTimeDelaySlot ;
    // You can come up with only one OR more than 1 instrument for your avatar.
    //ProfessorTimeDelaySlot = (ProfessorTimeDelaySlot + 1) % delaySeconds.length ;
    
// I used two global variables ProfessorScaleStep and ProfessorTimeDelaySlot defined
// just outside the class to vary the note (mypitch) instrument, and timing
// (mydelay) for each newly constructed Professor object. Normally a Java "class static"
// variable inside the class would have only 1 value shred by all objects of that class,
// but the Processing framework disallows class static variables for framework
// implementation reasons, so I put them outside the class.

// Your Avatar MUST use channel 10 (I am using 0 and 1 and reserving the others),
// a range of instruments away from my 106 and its neighbors (see
// // http://midi.teragonaudio.com/tutr/gm.htm ) or explore with ConcentricCirclesInterval sketch.



                        //DONE?
// STUDENT 3 (50%) All of my Professor's MIDI function calls are inside its move() function.
// Note that detectCollisions() now returns a java.util.Set object containing
// all of the colliding Avatar objects, if any, including bales of Globey objects.
// Use this code from detectCollisions()'s return value to sonify collisions.
// Use your own new or added CONTROL_CHANGEs or other MIDI messages, e.g., 2 notes at a time.

    //Set<Avatar> colliders = detectCollisions();
    //if (colliders.size() > 0) {
    //  sendMIDI(ShortMessage.PROGRAM_CHANGE, channel, instrument, 0);
    //  int volumeAdjust = 7 ;
    //  sendMIDI(ShortMessage.CONTROL_CHANGE, channel, volumeAdjust, 127);
    //  int balanceControl = 8 ;
    //  int balanceLocation = int(constrain(map(myx, 0, width, 0, 127),0,127));  // 64 is centered in stereo field
    //  sendMIDI(ShortMessage.CONTROL_CHANGE, channel, balanceControl, balanceLocation);
    //  sendMIDI(ShortMessage.NOTE_ON, channel, mypitch, 127);
    //  // See http://midi.teragonaudio.com/tech/midispec.htm
    //}
    //for (Avatar other : colliders) {
    //  float probability = random(0, 100);
    //  if (probability < 60) { // mow 60% of them
    //    other.mow();
    //  }
    //}
    
    // 3a. CHANGE the probability if mow()ing a Globey from 60% to something else. Play around with values.
    // 3b. Add a CONTROL_CHANGE MIDI effect that you can hear, see
    // http://midi.teragonaudio.com/tech/midispec.htm and experiment with ConcentricCirclesInterval sketch.
    // Take a listen to modulation wheel (controller 1) and chorus (controller 93) Note that unlike the
    // instrument numbers, these start at 0, i.e., mod wheel is 1, bank select is 0. Make it a mapped
    // function of y location relative to [0, height-1] or another avatar varying variable.
    // 3c. Add a second CONTROL_CHANGE MIDI effect that you can hear. Make it a mapped function
    // of z location relative to minimumZ and maximumZ or anotehr avara varying variable.
    
    
                       //DONE
 // STUDENT 4 (30%) Make an imploding Globey similar to a video I will post. 
 // Here is what I did for the video:
 // 4a. changed this in Globey's mow() function:
  // void mow() {
  //  avatars[avatarsIndex] = null ;
  //  GlobeyCount = constrain(GlobeyCount-1, 0, GlobeyCount);
  //  // println("DEBUG GlobeyCount GlobeyMAX", GlobeyCount, GlobeyMax);
  //  if (GlobeyCount == 0) {
  //    sendMIDI(ShortMessage.NOTE_OFF, channel, pitch, 0);
  //  }
  //}
  // TO THIS:
  //void mow() {
  //  mowCounter += 1 ;
  //}
  // I initialized the "int mowCounter = 0" code in the top of class Globey.
 
 
                               //DONE
  // 4b. The move() function in Globey now does the following pseudo-code:
  //  If the mowCounter is greater than 0
  //      Add 1 to mowCounter
  //      If mowScaleXYZ is a value very close to 0.0 (it may never reach 0).
  //        Do the steps previously in Globey.mow(), i.e., null this object's avatars[] entry 
  //        and send the NOTE_OFF if the decrement GlobeyCount <= 0.
  
  //  4c. In Globey.display, immediately after translate, if the mowCounter is greater than 0,
  //      scale(mowScaleXYZ), where mowScaleXYZ is initialized to 1.0 in the constructor.
  //      Then, still within the "if the mowCounter is greater than 0" scope,
  //      decrement mowScaleXYZ by some tiny but vsible amount. This will shrink the sphere.
  //      See step 4b above for when mowScaleXYZ approaches 0. I played around with shrinkage
  //      decerements and the boundary for sphere disappearance in step 4b.
  //      THE SCALE MUST MAKE THE GLOBEY SHRINK ***SLOWLY***, NOT EXPLODE!!!
  //      Basically, you want the scale in this step to approach 0 slowly, and when it is
  //      close to 0 (invisible in at least 1 dimension), do the step 4.b removal with NOTE_OFF.
  //      You should leave the bounding box for the sphere full size as it shrinks,
  //      in order to keep a higher probability of collision.
  
  // 4d. In the Globey tab change this line of code in makeglobePShape():
  //     globePImage = loadImage("clover.png");
  //     to load a .jpg or .png supplied by you. Make sure to include that image
  //     file in your project directory and turn it in to D2L with ALL YOUR CODE .pde files,
  //     preferrabbly as a regular .zip file. 
  //     Then do the following as given in makeglobePShape():
  // STUDENT set the texture on this PShape to globePImage.
  // See calls to setTexture(t) in 
  // https://faculty.kutztown.edu/parson/fall2022/CSC220FA2022DemoSome3D.txt
  // If you use an image off the web with no copyright restriction, cite its URL in a command.
