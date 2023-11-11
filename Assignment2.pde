/************************************************************
/* Authors: Dr. Parson & (Tim Pasquel)
/* Creation Date: 11/14/2016, updated 9/23/2019, 9/25/2020, 9/22/2021, 9/21/2022, 9/23
/* Due Date: 10/19/2023 - We will have a lab class, start before then.
/* Course: CSC220 Object-Oriented Multimedia Programming
/* Professors Name: Dr. Parson
/* Assignment: 2.
/* Sketch name: CSC220F23Assn2_3D
/*    CSC220F20Assn2_3D makes all Avatar-derived classes 3D.
/*    Assigment 2, with commands to move the camera() and rotate the world.
/*    SUMMARY OF STUDENT REQUIREMENTS:
/*    Save a working copy of this sketch as CSC220F20Assn2_3D WITH YOUR NAME at the top.
/*    1. 50% Completely replace my CodeBullet class with your class that uses 3D boxes & spheres;
/*       it may also use some 2D shapes. Surfaces must adjoin; you could have a free-floating
/*       body part like a halo, but generally the Avatar must be a contiguous 3D image.
/*       I will deduct at least 10 points for a random collection of shapes that don't
/*       look like anything. Make sure to document your class with comments.
/*       getBoundingBox() now returns 6 values per comments in interface Avatar.
/*       TO GET STARTED You could rename CodeBullet to your class name globally, run it,
/*       and then edit your changes into its functions and possibly data fields.
/*
/*    2. 25% Rewrite function makeCustomPShape() to make your own custom 3D PShape used by
/*       my existing class VectorAvatar. Build your PShape using the vertex() function
/*       on one or more planar faces of the PShape. You may use other PShapes such as ELLIPSE,
/*       BOX, etc. in a GROUP, but you must build at least one surface using vertex() calls.
/*
/*       I will award 10% bonus points if your code successfully textures a PShape planar face.
/*       You must use your own image file for this, and make sure to turn it in to D2L.
/*
/*       HINT: To texture, make an individual planar PShape 2D instead of 3D -- no Z coordinates --
/*             and use 3D translations & rotations to put it into place in a GROUP,
/*             similar to my sketch makeCustomPShape().
/*
/*    3. 15% Modify VectorAvatar.getBoundingBox() to enclose your displayed PShape
/*       correctly. Other enhancements to VectorAvatar are optional.
/*
/*    4. 10% Change any constructor calls in setup() to match your constructor.
/*
/*    Do not change classes Furniture or Paddle for this assignment.
/*    Test it and make sure it works. Do not break any of the keyboard commands. TEST THEM!
/*    If you change your key commands, document them at the top like the handout code.
/*
 *********************************************************/
 
/*  KEYBOARD COMMANDS:
/*  'b' toggles display of bounding boxes for debugging, initially on
/*  'f' toggles freezing of display in draw() off / on.
/*  'v' toggles isImmobile to inhibit/enable calls to Avatar.move();
/*  'm' toggles issmear mode for no-erase painting.
/*  '~' applies shuffle() to each Avatar object, repositioning the mobile ones.
/*  '!' applies forceshuffle() to each Avatar object, repositioning all of them.
/*  'p' sets perspective projection; 'o' sets orthographic
 *  'u' when held down moves camera up in Z direction slowly
 *  'U' when held down moves camera up in Z direction quickly
 *  'd' when held down moves camera down in Z direction slowly
 *  'D' when held down moves camera down in Z direction quickly
 *  'n' when held down moves camera up in Y direction slowly
 *  'N' when held down moves camera up in Y direction quickly
 *  's' when held down moves camera down in Y direction slowly
 *  'S' when held down moves camera down in Y direction quickly
 *  'e' when held down moves camera right in X direction slowly
 *  'E' when held down moves camera right in X direction quickly
 *  'w' when held down moves camera left in X direction slowly
 *  'W' when held down moves camera left in X direction quickly
 *  'x' when held down rotates image positive degrees around x
 *  'X' when held down rotates image negative degrees around x
 *  'y' when held down rotates image positive degrees around y
 *  'Y' when held down rotates image negative degrees around y
 *  'z' when held down rotates image positive degrees around z
 *  'Z' when held down rotates image negative degrees around z
 *  'R' resets to original camera point of view
 *  SPACE BAR held down moves camera x,y to mouseX*2-width, mouseY*2-height
*/

//NOTES
//Avatar Name: CodeBullet
//PShape is a little small, I added texturing to panel1 which is one of the triangles, might need to zoom in to see it, however, it works. 

// GLOBALS ADDED FOR 3D FURNITURE:
int minimumZ, maximumZ ; // initialized in setup.

// Assignment 1 GLOBAL VARIABLES are for the collection of Avatar objects.
// All Avatar state variables go inside of Avatar-derived subclasses.
Avatar avatars [] ;   // An array holding multiple Avatar objects.
int backgroundColor = 255 ;  // Wraps from 255 back to 0.
boolean showBoundingBox = true ;  // toggle with 'b' key
boolean isFrozen = false ; // toggle with 'f' key to freeze display
boolean isImmobile = false ; // toggle with 'f' key to freeze display


// Variables for camera manipulation:
float xeye, yeye, zeye ;    // locations of the camera's eye in 3D space
// Next 3 variables rotate the world from the camera's point of view.
float worldxrotate = 0.0, worldyrotate = 0.0, worldzrotate = 0.0 ;
// Some basic symbolic constants.
final float degree = radians(1.0), around = radians(360.0);
boolean isortho = false ;  // 'o' sets to true, 'p' to false for perspective
boolean issmear = false ;  // true when painting, 'm' toggles this
PShape customPShape = null ;
PImage customPImage = null ;  // Leave this at null if you don't texture.

void setup() {
  // setup() runs once when the sketch starts, initializes sketch state.
  size(1500, 1100, P3D);  // STUDENT may change size or use fullScreen(P3D).
  // fullScreen(P3D);
  frameRate(60);  // default 60, newer Macs need this after size()
  background(backgroundColor);
  maximumZ = height / 2 ;  // front of the scene
  minimumZ = - height / 2 ;  // back of the scene
  customPImage = loadImage("IMG_1900.jpg"); // load before makeCustomPShape(), USE YOUR OWN
  // STUDENT: If you decide not to texture your PShape, remove the
  // above loadImage call, allowing customPImage to be null.
  customPShape = makeCustomPShape(customPImage);
  avatars = new Avatar [ 20 ] ;  // reduced from 50 to reduce CPU load
  avatars[0] = new CodeBullet(width/4, height/4, 0, 2, 3, 1, 2);
  // See constructors in their classes below to interpret parameters.
  int cyan = color(0, 255, 255, 255);  // Red, Green, Blue, Alpha
  // By positioning based on system variables *width* and *height*, as opposed to
  // using fixed location numbers, your sketch will work with any display size.
  // NOTE THE CONSTRUCTORS NOW TAKE A Z COORDINATE, AND Z SPEED IN SOME CASES.
  avatars[1] = new Furniture(width/2, 5, 0, width-20, 10, maximumZ-minimumZ-20, cyan);  // 10 pixels wide boundary is impenetrable
  avatars[2] = new Furniture(width/2, height-5, 0, width-20, 10, maximumZ-minimumZ-20,cyan);
  avatars[3] = new Furniture(5, height/2, 0, 10, height-20, maximumZ-minimumZ-20, cyan);
  avatars[4] = new Furniture(width-5, height/2, 0, 10, height-20, maximumZ-minimumZ-20, cyan);
  avatars[5] = new CodeBullet(3*width/4, 3*height/4, 0, 2, 1, 1, 1);
  int magenta = color(255, 0, 255, 255);
  final int barlength = 200 ;
  avatars[6] = new Furniture(barlength/2, height/2, 0, barlength, 10, maximumZ-minimumZ, magenta);  // 10 pixels wide boundary is impenetrable
  avatars[7] = new Furniture(width-barlength/2, 2*height/3, 0, barlength, 10, maximumZ-minimumZ, magenta);
  avatars[8] = new Furniture(width/3, barlength/2, 0, 10, barlength, maximumZ-minimumZ, magenta);
  avatars[9] = new Furniture(width/3, height-barlength/2, 0, 10, barlength, maximumZ-minimumZ, magenta);
  color orange = color(255,184,0,255);
  avatars[10] = new Paddle(width/2, height/2, 0, barlength, 10, (maximumZ-minimumZ), 0, .02, orange);
  avatars[11] = new Paddle(width/2, height/2, 0, barlength, 10, (maximumZ-minimumZ), 90, -.03, orange);
  avatars[12] = new VectorAvatar(int(random(0,width)), int(random(0,height)), 0, 3, 4, round(random(2,5)), 0.5);
  for (int i = 13 ; i < avatars.length-1 ; i++) { // STUDENT BE CAREFUL TO START i AT *YOUR* NEXT OPEN SLOT!
    int zspeed = round(random(-5,5));
    if (zspeed == 0) { zspeed = 1 ; }
    avatars[i] = new CodeBullet(int(random(0,width)), int(random(0, height)),
      int(random(minimumZ, maximumZ))/2,
      round(random(1,5)), round(random(-5,-1)), zspeed, .25);
  }
  // ALPHA IS A LITTLE NON-FUNCTIONAL IN 3D SKETCHES
  // P3D makes me plot a translucent layer in the right order relative to other objects,
  // which in this sketch is *after*. If you plot a non-255 alpha layer before another,
  // the 3D clipping internals in Processing hides objects on the other side of an
  // alpha < 255 layer when your camera POV goes behind it!!!
  int translucentRedForBackWall = color(255,0,0,100);  // alpha (opacity) is final parameter
  avatars[avatars.length-1] = new Furniture(width/2, height/2, minimumZ, width, height, 1, translucentRedForBackWall);
  rectMode(CENTER);  // I make them CENTER by default. rectMode is otherwise CORNER.
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
  // Added 9/15/2018, put the camera above the middle of the scene:
  xeye = width / 2 ;
  yeye = height / 2 ;
  zeye = (height*2) /* / tan(PI*30.0 / 180.0) */ ;
}

void draw() {
  // draw() is run once every frameRate, every 60th of a sec by default.
  if (isFrozen) {
    return ;
  }
  if (isortho) {
    ortho();
  } else {
    perspective();
  }
  if (! issmear) {
    background(backgroundColor);  // This erases the previous frame.
  }
  // END EXPERIMENTAL */
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
  moveCameraRotateWorldKeys(); // CAMERA ADDITION 9/15/2018, holding key repeats its action
  // Display & move all avatars in a for loop.
  for (int i = 0 ; i < avatars.length ; i++) {
    // Reinitialze these modes in case an Avatar changed them.
    rectMode(CENTER);
    ellipseMode(CENTER);
    imageMode(CENTER);
    shapeMode(CENTER);
    textAlign(CENTER, CENTER);
    stroke(0);
    noFill();
    strokeWeight(1);
    if (! isImmobile) {
      avatars[i].move();  // Move before display so the bounding boxes are correct.
    }
    avatars[i].display();
  }
  if (showBoundingBox) {
    // Do this in a separate loop so we can do the initial part once.
    rectMode(CORNER);
    noFill();
    stroke(0);
    strokeWeight(1);
    /* THIS WAS THE 2D CODE
    for (Avatar avt : avatars) {
      // For testing bounding box
      int [] bb = avt.getBoundingBox();
      rect(bb[0], bb[1], bb[2]-bb[0], bb[3] - bb[1]);
    }
    */
    for (Avatar avt : avatars) {
      // For testing bounding box
      int [] bb = avt.getBoundingBox();
      line(bb[0], bb[1], bb[2], bb[3], bb[1], bb[2]); // across back top
      line(bb[0], bb[4], bb[2], bb[3], bb[4], bb[2]); // across back bottom
      line(bb[0], bb[1], bb[5], bb[3], bb[1], bb[5]); // across front top
      line(bb[0], bb[4], bb[5], bb[3], bb[4], bb[5]); // across front bottom
      line(bb[0], bb[1], bb[2], bb[0], bb[4], bb[2]); // down back left
      line(bb[3], bb[1], bb[2], bb[3], bb[4], bb[2]); // down back right
      line(bb[0], bb[1], bb[5], bb[0], bb[4], bb[5]); // down front left
      line(bb[3], bb[1], bb[5], bb[3], bb[4], bb[5]); // down front right
      line(bb[0], bb[1], bb[2], bb[0], bb[1], bb[5]); // into top left
      line(bb[3], bb[1], bb[2], bb[3], bb[1], bb[5]); // into top right
      line(bb[0], bb[4], bb[2], bb[0], bb[4], bb[5]); // into bottom left
      line(bb[3], bb[4], bb[2], bb[3], bb[4], bb[5]); // into bottom right
    }
  }
  rectMode(CENTER);  // back to defaults
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
}

//  KEYBOARD COMMANDS documented at top of this sketch.
// System calls keyPressed when user presses a *key*.
// Examples of control characters like arrows in a later example.
void keyPressed() {
  if (key == 'b') {
    // toggle bounding boxes on/off
    showBoundingBox = ! showBoundingBox ;
  } else if (key == 'f') {
    isFrozen = ! isFrozen ;
  } else if (key == 'v') {
    isImmobile = ! isImmobile ;
  } else if (key == '~') {
    for (int i = 0 ; i < avatars.length ; i++) {
      avatars[i].shuffle();
    }
  } else if (key == '!') {
    for (Avatar a : avatars) {
      a.forceshuffle();
    }
  } else if (key == 'R') { // Reset POV to starting point.
    xeye = width / 2 ;
    yeye = height / 2 ;
    zeye = (height*2) /* / tan(PI*30.0 / 180.0) */ ;
    worldxrotate = worldyrotate = worldzrotate = 0.0 ;
  } else if (key == 'o') {
    isortho = true ;
  } else if (key == 'p') {
    isortho = false ;
  } else if (key == 'm') {
    issmear = ! issmear ;
  }
}

/** 3D overlap checks whether two objects' bounding boxes overlap
**/
boolean overlap(Avatar avatar1, Avatar avatar2) {
  int [] bb1 = avatar1.getBoundingBox();
  int [] bb2 = avatar2.getBoundingBox();
  // If bb1 is completely above, below,
  // left or right of bb2, we have an easy reject.
  if (bb1[0] > bb2[3]      // bb1_left is right of bb2_right
  || bb1[1] > bb2[4]   // bb1_top is below bb2_bottom
  || bb1[2] > bb2[5]  // bb1_back is front of bb2_front
  || bb2[0] > bb1[3]   // bb2_left is right of bb1_right
  || bb2[1] > bb1[4]   // bb2_top is below bb1_bottom
  || bb2[2] > bb1[5]  // bb2_back is front of bb1_front
  ) {
    return false ;
  }
  // In this case one contains the other or they overlap.
  return true ;
}

/** Return 1 for non-negative num, -1 for negative. **/
int signum(float num) {
  return ((num >= 0) ? 1 : -1);
}

// Added 9/15/2018 to move camera and rotate world when these keys are held down.
void moveCameraRotateWorldKeys() {
  if (keyPressed) {
    if (key == 'u') {
      zeye += 10 ;
      // println("DEBUG u " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
    } else if (key == 'U') {
      zeye += 100 ;
      // println("DEBUG U " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
    } else if (key == 'd') {
      zeye -= 10 ;
      // println("DEBUG d " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
    } else if (key == 'D') {
      zeye -= 100 ;
      // println("DEBUG D " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
    } else if (key == 'n') {
      yeye -= 1 ;
    } else if (key == 'N') {
      yeye -= 10 ;
    } else if (key == 's') {
      yeye += 1 ;
    } else if (key == 'S') {
      yeye += 10 ;
    } else if (key == 'w') {
      xeye -= 1 ;
    } else if (key == 'W') {
      xeye -= 10 ;
    } else if (key == 'e') {
      xeye += 1 ;
    } else if (key == 'E') {
      xeye += 10 ;
    } else if (key == 'x') {
      worldxrotate += degree ;
      if (worldxrotate >= around) {
        worldxrotate = 0 ;
      }
    } else if (key == 'X') {
      worldxrotate -= degree ;
      if (worldxrotate < -around) {
        worldxrotate = 0 ;
      }
    } else if (key == 'y') {
      worldyrotate += degree ;
      if (worldyrotate >= around) {
        worldyrotate = 0 ;
      }
    } else if (key == 'Y') {
      worldyrotate -= degree ;
      if (worldyrotate < -around) {
        worldyrotate = 0 ;
      }
    } else if (key == 'z') {
      worldzrotate += degree ;
      if (worldzrotate >= around) {
        worldzrotate = 0 ;
      }
    } else if (key == 'Z') {
      worldzrotate -= degree ;
      if (worldzrotate < -around) {
        worldzrotate = 0 ;
      }
    } else if (mousePressed && key == ' ') {
      xeye = mouseX ;
      yeye = mouseY ;
    }
  }
  // Make sure 6th parameter -- focus in the Z direction -- is far, far away
  // towards the horizon. Otherwise, ortho() does not work.
  camera(xeye, yeye,  zeye, xeye, yeye,  zeye-signum(zeye-minimumZ)*maximumZ*2 , 0,1,0);
  if (worldxrotate != 0 || worldyrotate != 0 || worldzrotate != 0) {
    translate(width/2, height/2, 0);  // rotate from the middle of the world
    if (worldxrotate != 0) {
      rotateX(worldxrotate);
    }
    if (worldyrotate != 0) {
      rotateY(worldyrotate);
    }
    if (worldzrotate != 0) {
      rotateZ(worldzrotate);
    }
    translate(-width/2, -height/2, 0); // Apply the inverse of the above translate.
    // Do not use pushMatrix()-popMatrix() instead of the inverse translate,
    // because popMatrix() would discard the rotations.
  }
}

/**
 *  An *interface* is a specification of methods (functions) that
 *  subclasses must provide. It provides a means to specify requirements
 *  that plug-in derived classes must provide.
 *  This interface Avatar specifies functions for both mobile & immobile
 *  objects that interact in this sketch. Added 3D getBoundingBox() for assn2.
**/
interface Avatar {
    /**
   *  Avatar-derived class must have one or more variable
   *  data fields, at a minimum for the myx,myy,myz location,
   *  where 0,0,0 is the Avatar's reference point after translate(myx, myy, myz).
 **/
 /** Derived classes provide a constructor that takes some parameters. **/
 /**
  *  Write a display function that starts like this:
  
    pushMatrix();
    translate(myx, myy, myz);
    
    and ends like this:
    
    pop();
    
    with all display code inside the function.
    Write this in your derived class, not here in Avatar.
    
    In addition to translate, the display() code in your class must use
    one or more of scale (with 1 or 2 arguments), rotate,
    shearX, or shearY. You can also manipulate variables for color & speed.
    See my example classes for ideas. 
  **/
  void display();
  /** Write move() to update variable fields inside the object.
   *  Write this in your derived class, not here in Avatar. **/
  void move();
  /**
   *  getBoundingBox returns an array of 6 integers where elements
   *  [0],[1],[2] have the minimum X,Y,Z coordinates respectively, and
   *  [3],[4],[5] have the maximum X,Y,Z coordinates respectively.
   *  This function always returns a cuboid bounding box that contains the
   *  entire avatar. Coordinates are those in effect when display() or
   *  move() are called from the draw() function,
  **/
  int [] getBoundingBox();
  /** Return the X coordinate of this avatar, center. **/
  int getX();
  /** Return the Y coordinate of this avatar's center. **/
  int getY();
  /** Return the Z coordinate of this avatar's center. **/
  int getZ();
  /** Randomize parts of a *mobile* object's space, including x,y,z location. **/
  void shuffle() ;
  /** Randomize parts of *every* object's space, including x,y,z location. **/
  void forceshuffle();
}

/**
 *  An abstract class provides helper functions and data fields required by
 *  all subclasses. Abstract class CollisionDetector provides location and
 *  scaling and rotation data fields that subclasses use. It also provides
 *  helper functions, notably detectCollisions() for collision detection, that
 *  are used by all subclasses. The keyword *protected* means that only subclasses
 *  can use protected data & methods. The keyword *private* means that only the
 *  defining class can use them, and *public* means that any class can use them.
**/
abstract class CollisionDetector implements Avatar {
  protected int myx, myy, myz ;    // x,y,z location of this object
  protected float myscale ;   // scale of this object, 1.0 for no scaling
  protected float speedX ;    //  speed of motion, negative for left.
  protected float speedY ;    //  speed of motion, negative for up.
  protected float speedZ ;    //  speed of motion, negative for away from front.
  float myrotZ = 0.0 ; // subclasses may rotate & scale in other dimensions
  float rotZspeed = 0.0, sclspeed = 0.0 ; // subclasses may change myscale, myrotZ in move().
  // Testing shows that mobile shapes may push other mobile shapes
  // off of the screen, depending on order of collision detection.
  // Some Avatar classes may want their displays to wander around outside.
  // Data field xlimit and ylimit test for that.
  // See java.lang.Integer in https://docs.oracle.com/javase/8/docs/api/index.html
  protected int xlimitleft = Integer.MIN_VALUE ;  // no limit by default
  protected int ylimittop = Integer.MIN_VALUE ;  // no limit by default
  protected int xlimitright = Integer.MAX_VALUE ;  // no limit by default
  protected int ylimitbottom = Integer.MAX_VALUE ;  // no limit by default
  protected int zlimitmin = minimumZ ;  // default for drawing
  protected int zlimitmax = maximumZ ;  // default for drawing
  // The constructor initializes the data fields.
  CollisionDetector(int avx, int avy, int avz, float spdx, float spdy, float spdz,
      float avscale, float scalespeed, float rotation, float rotatespeed) {
    myx = avx ;
    myy = avy ;
    myz = avz ;
    speedX = spdx ;
    speedY = spdy ;
    speedZ = spdz ;
    myscale = avscale ;
    sclspeed = scalespeed ;
    myrotZ = rotation ;
    rotZspeed = rotatespeed ;
  }
  void shuffle() {
    // default is to do nothing; override this in derived class.
  }
  void forceshuffle() {
    // default is to change location; add to this in derived class.
    myx = round(random(10, width-10));  // Put it somewhere on the display.
    myy = round(random(10, height-10));
    myz = round(random(minimumZ/4, maximumZ/4)); // don't go too far out
  }
  int getX() {
    return myx ;
  }
  int getY() {
    return myy ;
  }
  int getZ() {
    return myz ;
  }
  // Check this object against every other Avatar object for a collision.
  // Also make sure it doesn't wander outside the x and y limit values
  // set by the constructor. Putting detectCollisions() in this abstract class
  // eliminates the need to put it into multiple derived class move() functions,
  // which can simply call this function.
  protected void detectCollisions() {
    int [] mine = getBoundingBox();
    for (Avatar a : avatars) {
      if (a == this) {
        continue ; // this avatar always overlaps with itself
      }
      int [] theirs = a.getBoundingBox();
      if (overlap(this,a)) {
        if (mine[0] >= theirs[0] && mine[0] <= theirs[3]) {
          // my left side is within them, move to the right
          speedX = abs(speedX);
          myx += 2*speedX ;  // jump away a little extra
        } else if (mine[3] >= theirs[0] && mine[3] <= theirs[3]) {
          // my right side is within them, move to the left
          speedX = - abs(speedX);
          myx += 2*speedX ;
        }
        // Above may have eliminated the overlap, check before proceeding.
        mine = getBoundingBox();
        if (overlap(this,a)) {
        // Do equivalent check for vertical overlap.
          if (mine[1] >= theirs[1] && mine[1] <= theirs[4]) {
            speedY = abs(speedY); // my top, send it down
            myy += 2*speedY ;
          } else if (mine[4] >= theirs[1] && mine[4] <= theirs[4]) {
            speedY = - abs(speedY); // my bottom, send it up
            myy += 2*speedY ;
          }
        }
        // Z test added for assignment 2 3D.
        mine = getBoundingBox();
        if (overlap(this,a)) {
        // Do equivalent check for vertical overlap.
          if (mine[2] >= theirs[2] && mine[2] <= theirs[5]) {
            speedZ = abs(speedZ); 
            myz += 2*speedZ ;
          } else if (mine[5] >= theirs[2] && mine[5] <= theirs[5]) {
            speedZ = - abs(speedZ);
            myz += 2*speedZ ;
          }
        }
      }
    }
    // Testing shows that mobile shapes may push other mobile shapes
    // off of the screen or thru Avatars, depending on order of collision detection.
    // Some Avatar classes may want their displays to wander around outside the display.
    // Data fields xlimit and ylimit test for that.
    if (xlimitleft != Integer.MIN_VALUE && myx <= xlimitleft && speedX < 0) {
      speedX = - speedX ;
      myx = xlimitleft + 1 ;
      // if (myscale >= 1) println("DEBUG WENT OFF LEFT " + speedX);
      // Too many print statements, restrict to the bigger Avatars.
      // I usually comment out print statements until I am sure the bug is gone.
    }
    if (xlimitright != Integer.MAX_VALUE && myx >= xlimitright && speedX > 0) {
      speedX = - speedX ;
      myx = xlimitright - 1 ;
      // if (myscale >= 1) println("DEBUG WENT OFF RIGHT " + speedX);
    }
    if (ylimittop != Integer.MIN_VALUE && myy <= ylimittop && speedY < 0) {
      speedY = - speedY ;
      myy = ylimittop + 1 ;
      // if (myscale >= 1) println("DEBUG WENT OFF TOP " + speedY);
    }
    if (ylimitbottom != Integer.MAX_VALUE && myy >= ylimitbottom && speedY > 0) {
      speedY = - speedY ;
      myy = ylimitbottom - 1 ;
      // if (myscale >= 1) println("DEBUG WENT OFF BOTTOM " + speedY);
    }
    if (myz <= zlimitmin && speedZ < 0) {
      speedZ = - speedZ ;
      myz = zlimitmin + 1 ;
      // if (myscale >= 1) println("DEBUG WENT OFF BACK " + speedY);
    }
    if (myz >= zlimitmax && speedZ > 0) {
      speedZ = - speedZ ;
      myz = zlimitmax - 1 ;
      // if (myscale >= 1) println("DEBUG WENT OFF FRONT " + speedY);
    }
  }
}

/**
 *  CodeBullet is my Avatar-derived class that displays & moves a mobile CodeBullet.
 *  You must write your own Avatar-derived class. You can delete class CodeBullet
 *  or use it as a starting point for your re-named class. Document what your
 *  class adds or changes at the top of the class declaration like this.
**/
class CodeBullet extends CollisionDetector {
  /* The data fields store the state of the Avatar. */
  protected int legdist = 0 ; // You can initialize to a constant here.
  CodeBullet(int avx, int avy, int avz, float spdx, float spdy, float spdz, float avscale) {
    super(avx,avy,avz,spdx,spdy,spdz,avscale,0,0,0);
    // Call the base class constructor to initialize its data fields,
    // then initialize this class' data fields.
    xlimitright = width ;
    ylimitbottom = height ; // limit off-screen motion to
    xlimitleft = 0 ;    // one width or height off the display
    ylimittop = 0 ;    // in either direction
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
    detectCollisions();
  }
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

/**
 *  Class Furniture implements immobile obstacles as rectangles.
 *  It adds fields for object width, height, and color.
**/
class Furniture extends CollisionDetector {
  /* The data fields store the state of the Avatar. */
  protected int mywidth, myheight, mydepth, mycolor, mystroke ;
  // Save the the problems of writing a new display function
  // by implementing no-op rotation and scaling here,
  // subclasses can use them.
  // rot is in degrees.
  // The constructor initializes the data fields.
  Furniture(int avx, int avy, int avz, int w, int h, int depth, int c) {
    super(avx,avy,avz,0,0,0,1.0,0,0,0);
    mywidth = w ;
    myheight = h ;
    mydepth = depth ;
    mycolor = c ;
    // Extract RGB from mycolor & set nystroke to its opposite.
    mystroke = color(255-red(mycolor), 255-green(mycolor), 255-blue(mycolor));
  }
  // The display() function simply draws the Avatar object.
  // The move() function updates the Avatar object's state.
  void display() {
    // Draw the avatar.
    push(); // STUDENT *MUST* use push() & translate first in display().
    translate(myx, myy, myz);
    if (myrotZ != 0.0) {
      rotateZ(radians(myrotZ));
    }
    if (myscale != 1.0) {
      scale(myscale);
    }
    fill(mycolor);
    stroke(mystroke); // 2D REWORK to see edges stroke(mycolor);
    strokeWeight(10);
    // 2D REWORK rect(0,0,mywidth,myheight);  // 0,0 is the center of the object.
    box(mywidth, myheight, mydepth);
    pop(); // STUDENT *MUST* use pop() last in display().
  }
  // The move() function updates the Avatar object's state.
  // Furniture is immobile, so move() does nothing.
  void move() {
  }
  int [] getBoundingBox() {
    int [] result = new int[6];
    result[0] = myx-mywidth/2 ; // left extreme of box
    result[1] = myy - myheight/2; // top of box
    result[2] = myz - mydepth/2; // back of box
    result[3] = myx + mywidth/2; // right of box
    result[4] = myy + myheight/2; // bottom of box
    result[5] = myz + mydepth/2; // back of box
    return result ;
  }
}
/**
 *  Paddle extends class Furniture into a mobile, rotating rectangle.
**/
class Paddle extends Furniture {
  // Call base class constructor to initialize its fields,
  // then initialize fields added by this class (none presently),
  // and let limits on off-screen excursions.
  // Paddle changed from assignment 1 to grow and shrink in its rotated major direction,
  // rotation is fixed to 0 or 90 degrees in one direction, and it grows to width & shrinks to 1 in that direction.
  Paddle(int avx, int avy, int avz, int w, int h, int depth, float rotateamount, 
      float scalingspeed, int c) {
    super(avx, avy, avz, w, h, depth, c);
    myrotZ = rotateamount ;
    sclspeed = scalingspeed ;
    xlimitright = 2 * width ;
    ylimitbottom = 2 * height ;
    xlimitleft = - width ;    // one width or height off the display
    ylimittop = - height ;    // in either direction
    if (myrotZ != 0 && myrotZ != 90) {
      println("ERROR, Paddle is rotated invalid amount: " + rotateamount);
      myrotZ = 0 ;
    }
  }
  void move() {
    myscale += sclspeed ;
    int pixwidth = round(myscale * mywidth) ;
    if ((pixwidth <= 0 && sclspeed < 0) || (pixwidth >= width && sclspeed > 0)) {
      sclspeed = - sclspeed ;
    }
    super.move(); // in case it is ever implemented
  }
  void display() { // redefined from Furniture to scale only in X, rotate around Z
    // Draw the avatar.
    push(); // STUDENT *MUST* use push() & translate first in display().
    translate(myx, myy, myz);
    if (myrotZ != 0.0) {
      rotateZ(radians(myrotZ));
    }
    if (myscale != 1.0) {
      scale(myscale,1,1);  // scale only in X vector
    }
    fill(mycolor);
    stroke(mystroke); // 2D REWORK to see edges stroke(mycolor);
    strokeWeight(10);
    // 2D REWORK rect(0,0,mywidth,myheight);  // 0,0 is the center of the object.
    box(mywidth, myheight, mydepth);
    pop(); // STUDENT *MUST* use pop() last in display().
  }
  // Customize display() and getBB() for scaling in only 1 direction.
  int [] getBoundingBox() {
    int [] result = new int[6];
    if (myrotZ == 0) {
      result[0] = round(myx-(myscale*mywidth)/2) ; // left extreme of box
      result[1] = myy - myheight/2; // top of box
      result[2] = myz - mydepth/2; // back of box
      result[3] = round(myx+(myscale*mywidth)/2) ; // left extreme of box
      result[4] = myy + myheight/2; // bottom of box
      result[5] = myz + mydepth/2; // back of box
    } else {
      result[1] = round(myy-(myscale*mywidth)/2) ; // ROTATED BY 90
      result[0] = myx - myheight/2; 
      result[2] = myz - mydepth/2; 
      result[4] = round(myy+(myscale*mywidth)/2) ; 
      result[3] = myx + myheight/2; 
      result[5] = myz + mydepth/2; 
    }
    return result ;
  }
}

// D. Parson's makeCustomPShape vectors taken from Shape3DDemo
/*
 *  Make and return a custom 3D PShape created using vertex() calls,
 *  for use in Avatar-derived class VectorAvatar. The textureimg
 *  parameter may be null; when it is non-null, use it to texture
 *  at least one of the planar sides of the returned PShape. If the
 *  STUDENT decides not to texture, remove the loadImage call at the
 *  top of the sketch, allowing textureimg to be null.
*/
PShape makeCustomPShape(PImage textureimg) {
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
  
  PShape panel1 = createShape();
  panel1.beginShape();
  if (textureimg == null) {
    panel1.vertex(50, 0, 0);
    panel1.vertex(0, 50, 0);
    panel1.vertex(-50, 0, 0);
    panel1.vertex(50, 0, 0);
    panel1.endShape();
    panel1.setFill(color(0));
  } else {
    int imgwidth = round(textureimg.width);  // Use 2D vertex() calls to
    int imgheight = round(textureimg.height); // get texture to work.
    panel1.texture(textureimg);
    panel1.vertex(-50,0, 0, 0);      // vertex(x, y, z) with varying      //USE 2D COORDINEATES
    panel1.vertex(0,50,imgwidth/2, imgheight-1);  // Z did not work for texturing,
    panel1.vertex(50,0,imgwidth-1,0);   // even though the constant Y value
    panel1.endShape();  // PShape vertex.
  }
  PShape panel2 = createShape();
  panel2.beginShape();
  panel2.vertex(50, 0, 100);
  panel2.vertex(0, 50, 100);
  panel2.vertex(-50, 0, 100);
  panel2.vertex(50, 0, 100);
  panel2.endShape();
  panel2.setFill(color(108));
  PShape under = createShape();
  under.beginShape();
  under.vertex(50, 0, 0);
  under.vertex(50, 0, 100);
  under.vertex(-50, 0, 100);
  under.vertex(-50, 0, 0);
  under.vertex(50, 0, 0);
  under.endShape();
  under.setFill(color(10, 255, 25));
  PShape upright = createShape();
  upright.beginShape();
  upright.vertex(50, 0, 0);
  upright.vertex(50, 0, 100);
  upright.vertex(0, 50, 100);
  upright.vertex(0, 50, 0);
  upright.vertex(50, 0, 0);
  upright.endShape();
  upright.setFill(color(10, 255, 25));
  PShape upleft = createShape();
  upleft.beginShape();
  upleft.vertex(-50, 0, 0);
  upleft.vertex(-50, 0, 100);
  upleft.vertex(0, 50, 100);
  upleft.vertex(0, 50, 0);
  upleft.vertex(-50, 0, 0);
  upleft.endShape();
  upleft.setFill(color(10, 255, 25));
  
  PShape custom = createShape(GROUP);
  //ADDED PANEL
  custom.addChild(panel1);
  custom.addChild(panel2);
  custom.addChild(under);
  custom.addChild(upright);
  custom.addChild(upleft);
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
    shape(customPShape, 0, 0);
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
    detectCollisions();
  }
  int [] getBoundingBox() {
    // These limits do not account for rotation, but the
    // Pyramid PShape is -100 to +100 in all 3 dimensions.
    // You may have to adjust this to work with your PShape.
    int [] result = new int[6]; // customPShape.depth does not work.
    /*
    println("DEBUG customPShape width,height,depth: " + customPShape.width + ","
      + customPShape.height + "," + customPShape.depth);
    */
    result[0] = round(myx - 150 * myscale) ; //round(myx-myscale*customPShape.width/2.0);
    result[1] = round(myy - 150 * myscale) ; //round(myy-myscale*customPShape.height/2.0);
    result[2] = round(myz - 150 * myscale) ; //round(myz-myscale*customPShape.depth/2.0);
    result[3] = round(myx + 150 * myscale) ; //round(myx+myscale*customPShape.width/2.0);
    result[4] = round(myy + 150 * myscale) ; //round(myy-myscale*customPShape.width/2.0);
    result[5] = round(myz + 150 * myscale) ; // round(myz-myscale*customPShape.depth/2.0);
    return result ;
  }
}
