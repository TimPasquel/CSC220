/************************************************************
/* Authors: Dr. Parson & (Tim Pasquel)
/* Creation Date: 09/4/2023
/* Due Date: 09/26/2023
/* Course: CSC220 Object-Oriented Multimedia Programming
/* Professor Name: Dr. Parson
/* Avatar Name: JohnWick
/* Assignment: 1.
/* Sketch name: CSC220F23AvatarClassInAvatarRoom
/*    This 2D sketch puts the mobile avatar in a mostly-immobile
/*    2D room, where each wall or piece of furniture is a 2D avatar,
/*    and at least one furniture surface moves. It illustrates
/*    the use of a Java interface, inheritance, an abstract base class
/*    containing helper functions & fields, and also simple collision
/*    detection using bounding boxes. Initial draft September 12, 2018.
 *********************************************************/
 
 //Major Changes:
 //Changed the professor class name to JohnWick
 //Changed the bounding box of personal avatar to meet rotation specs as well as any additional changes
 //Furniture is now an ellipse instead of a rect., boudning boxes chaged accordingly 
 //Paddle now moves to fit the specs
 //There are 30 avatars instead of 50 to reduce traffic
 //Some avatars are really small/big which is defined randomly at creation
 //More specific documentation can be found below in the code
 
/*  KEYBOARD COMMANDS:
/*  'b' toggles display of bounding boxes for debugging, initially on
/*  'f' toggles freezing of display in draw() off / on.
/*  '~' applies shuffle() to each Avatar object, repositioning the mobile ones.
/*  '!' applies forceshuffle() to each Avatar object, repositioning all of them.
*/

// The only GLOBAL VARIABLES are for the collection of Avatar objects.
// All Avatar state variables go inside of Avatar-derived subclasses.
Avatar avatars [] ;   // An array holding multiple Avatar objects.
int backgroundColor = 255 ;  // White on gray scale.
boolean showBoundingBox = true ;  // toggle with 'b' key
boolean isFrozen = false ; // toggle with 'f' key to freeze display

void setup() {
  // setup() runs once when the sketch starts, initializes sketch state.
  size(1000, 800); // YOU may change size.
  // fullScreen();  // P2D uses the grahics cards for some of the calculations, blocks Zoom
  frameRate(60);  // needs to be set here for newer Macs
  background(backgroundColor);
  //CHANGED THE # OF AVATARS FROM 50 TO 30
  avatars = new Avatar [ 30 ] ;
  avatars[0] = new JohnWick(width/4, height/4, 2, 3, 2);
  // See constructors in their classes below to interpret parameters.
  int cyan = color(0, 255, 255, 255);  // Red, Green, Blue, Alpha
  // By positioning based on system variables *width* and *height*, as opposed to
  // using fixed location numbers, your sketch will work with any display size.
  avatars[1] = new Furniture(width/2, 5, width, 10, cyan);  // 10 pixels wide boundary is impenetrable
  avatars[2] = new Furniture(width/2, height-5, width, 10, cyan);
  avatars[3] = new Furniture(5, height/2, 10, height, cyan);
  avatars[4] = new Furniture(width-5, height/2, 10, height, cyan);
  avatars[5] = new JohnWick(3*width/4, 3*height/4, 2, 1, 1);
  int magenta = color(255, 0, 255, 255);
  final int barlength = 200 ;
  avatars[6] = new Furniture(barlength/2, height/2, barlength, 10, magenta);  // 10 pixels wide boundary is impenetrable
  avatars[7] = new Furniture(width-barlength/2, 2*height/3, barlength, 10, magenta);
  avatars[8] = new Furniture(width/3, barlength/2, 10, barlength, magenta);
  avatars[9] = new Furniture(width/3, height-barlength/2, 10, barlength, magenta);
  color orange = color(255,184,0,255);
  //CHANGED THE WIDTH OF THE PADDLE FROM 10 TO 30 TO MAKE IT SO IT DOESNT LEAVE THE SCREEN (AS OFTEN)
  avatars[10] = new Paddle(width/2, height/2, barlength, 30, .5, orange);
  for (int i = 11 ; i < avatars.length ; i++) {
    avatars[i] = new JohnWick(int(random(0,width)), int(random(0, height)),
      round(random(1,5)), round(random(-5,-1)), .25);
  }
  rectMode(CENTER);  // I make them CENTER by default. rectMode is otherwise CORNER.
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
}

void draw() {
  if (isFrozen) {
    return ; // toggle 'f' key to freeze/unfreeze display.
  }
  // draw() is run once every frameRate, every 60th of a sec by default.
  background(backgroundColor);  // This erases the previous frame.
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
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
    avatars[i].move();  // Move before display so the bounding boxes are correct.
    avatars[i].display();
  }
  if (showBoundingBox) {
    // Do this in a separate loop so we can do the initial part once.
    // Putting it here for debugging avoids having to do it in the Avatar.display()s.
    rectMode(CORNER);
    noFill();
    stroke(0);
    strokeWeight(1);
    for (Avatar avt : avatars) {
      // For testing bounding box
      int [] bb = avt.getBoundingBox();
      rect(bb[0], bb[1], bb[2]-bb[0], bb[3] - bb[1]);
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
  } else if (key == '~') {
    for (int i = 0 ; i < avatars.length ; i++) {
      avatars[i].shuffle();
    }
  } else if (key == '!') {
    for (Avatar a : avatars) {
      a.forceshuffle();
    }
  }
}

/** overlap checks whether two objects' bounding boxes overlap
**/
boolean overlap(Avatar avatar1, Avatar avatar2) {
  int [] bb1 = avatar1.getBoundingBox();
  int [] bb2 = avatar2.getBoundingBox();
  // If bb1 is completely above, below,
  // left or right of bb2, we have an easy reject.
  if (bb1[0] > bb2[2]      // bb1_left is right of bb2_right
  || bb1[1] > bb2[3]   // bb1_top is below bb2_bottom, now reverse them
  || bb2[0] > bb1[2]   // bb2_left is right of bb1_right
  || bb2[1] > bb1[3]   // bb2_top is below bb1_bottom, now reverse them
  ) {
    return false ;
  }
  // In this case one contains the other or they overlap.
  return true ;
}

/**
 *  Helper function supplied by Dr. Parson, student can just call it.
 *  rotatePoint takes the unrotated coordinates local to an object's
 *  0,0 reference location and rotates them by angleDegrees in degrees.
 *  Applying it to global coordinates rotates around the global 0,0 reference
 *  point in the LEFT,TOP corner of the display. x, y are the unrotated coords.
 *  Return value is 2-element array of the rotated x,y values.
**/
double [] rotatePoint(double x, double y, double angleDegrees) {
  double [] result = new double [2];
  double angleRadians = Math.toRadians(angleDegrees);
  // I have kept local variables as doubles instead of floats until the
  // last possible step. I was seeing rounding errors in the displayed BBs
  // when they are scaled when using floats. Using doubles for these calculations
  // appears to have eliminated those occasionally noticeable errors.
  // SEE: https://en.wikipedia.org/wiki/Rotation_matrix
  double cosAngle = (Math.cos(angleRadians)); // returns a double
  double sinAngle = (Math.sin(angleRadians));
  result[0] = (x * cosAngle - y * sinAngle) ;
  result[1] = (x * sinAngle + y * cosAngle);
  // println("angleD = " + angleDegrees + ", cos = " + cosAngle + ", sin = " + sinAngle + ", x = " + x + ", y = "
    // + y + ", newx = " + result[0] + ", newy = " + result[1]);
  return result ;
}
/**
 *  Helper function supplied by Dr. Parson, student can just call it.
 *  rotateBB takes the (leftx, topy) and (rightx, bottomy) extents of an
 *  unrotated bounding box and determines the leftmost x, uppermost y,
 *  rightmost x, and bottommost y of the rotated BB, and returns these
 *  rotated extents in a 4-element array of coodinates.
 *  rotateBB needs to rotate every corner of the original bounding box
 *  in turn to find the rotated bounding box as min and max values for X and Y.
 *  Parameters:
 *    leftx, topy and rightx, bottomy are the original, unrotated extents.
 *    angle is the angle of rotation in degrees.
 *    scaleXfactor and scaleYfactor are the scalings of the shape with the BB.
 *    referencex,referencey is the "center" 0,0 point within the shape
 *    being rotated, with is also the reference point of the BB, in global coord.
 *  Return 4-element array holds the minx,miny and maxx,maxy rotated extents.
 *  See http://faculty.kutztown.edu/parson/fall2019/RotateBB2D.png
**/
int [] rotateBB(double leftx, double topy, double rightx, double bottomy,
  double angle, double scaleXfactor, double scaleYfactor, double referencex, double referencey) {
  int [] result = new int [4];
  leftx = leftx * scaleXfactor ;
  rightx = rightx * scaleXfactor ;
  topy = topy * scaleYfactor ;
  bottomy = bottomy * scaleYfactor ;
  double [] ul = rotatePoint(leftx, topy, angle); // rotate each of the 4 corners
  double [] ll = rotatePoint(leftx, bottomy, angle);
  double [] ur = rotatePoint(rightx, topy, angle);
  double [] lr = rotatePoint(rightx, bottomy, angle);
  double minx = Math.min(ul[0], ll[0]);// find minx,miny and max,maxy from all 4
  minx = Math.min(minx, ur[0]);
  minx = Math.min(minx, lr[0]);
  double maxx = Math.max(ul[0], ll[0]);
  maxx = Math.max(maxx, ur[0]);
  maxx = Math.max(maxx, lr[0]);
  double miny = Math.min(ul[1], ll[1]);
  miny = Math.min(miny, ur[1]);
  miny = Math.min(miny, lr[1]);
  double maxy = Math.max(ul[1], ll[1]);
  maxy = Math.max(maxy, ur[1]);
  maxy = Math.max(maxy, lr[1]);
  // scale by this shapes scale 
  result[0] = (int)Math.round(referencex + minx) ; // left extreme
  result[1] = (int)Math.round(referencey + miny); // top
  result[2] = (int)Math.round(referencex + maxx); // right side
  result[3] = (int)Math.round(referencey + maxy); // bottom
  return result ;
}

/**
 *  An *interface* is a specification of methods (functions) that
 *  subclasses must provide. It provides a means to specify requirements
 *  that plug-in derived classes must provide.
 *  This interface Avatar specifies functions for both mobile & immobile
 *  objects that interact in this sketch.
**/
interface Avatar {
    /**
   *  Avatar-derived class must have one or more variable
   *  data fields, at a minimum for the x,y location,
   *  where 0,0 is the middle of the display area.
 **/
 /** Derived classes provide a constructor that takes some parameters. **/
 /**
  *  Write a display function that starts like this:
  
    push();
    translate(x, y);
    
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
   *  getBoundingBox returns an array of 4 integers where elements
   *  [0], [1] tell the upper left X,Y coordinates of the bounding
   *  box, and [2], [3] tell the lower right X,Y. This function
   *  always returns a rectangular bounding box that contains the
   *  entire avatar. Coordinates are those in effect when display() or
   *  move() are called from the draw() function,
  **/
  int [] getBoundingBox();
  /** Return the X coordinate of this avatar, center. **/
  int getX();
  /** Return the Y coordinate of this avatar's center. **/
  int getY();
  /** Randomize parts of a *mobile* object's space, including x,y location. **/
  void shuffle() ;
  /** Randomize parts of *every* object's space, including x,y location. **/
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
  protected int myx, myy ;    // x,y location of this object
  protected float myscale ;   // scale of this object, 1.0 for no scaling
  protected float speedX ;    //  speed of motion, negative for left.
  protected float speedY ;    //  speed of motion, negative for up.
  float myrot = 0.0 ; // subclasses may rotate & scale
  float rotspeed = 0.0, sclspeed = 0.0 ; // subclasses may change myscale, myrot in move().
  // Testing shows that mobile shapes may push other mobile shapes
  // off of the screen, depending on order of collision detection.
  // Some Avatar classes may want their displays to wander around outside.
  // Data field xlimit and ylimit test for that.
  // See java.lang.Integer in https://docs.oracle.com/javase/8/docs/api/index.html
  protected int xlimitleft = Integer.MIN_VALUE ;  // no limit by default
  protected int ylimittop = Integer.MIN_VALUE ;  // no limit by default
  protected int xlimitright = Integer.MAX_VALUE ;  // no limit by default
  protected int ylimitbottom = Integer.MAX_VALUE ;  // no limit by default
  // The constructor initializes the data fields.
  CollisionDetector(int avx, int avy, float spdx, float spdy, float avscale,
      float scalespeed, float rotation, float rotatespeed) {
    myx = avx ;
    myy = avy ;
    speedX = spdx ;
    speedY = spdy ;
    myscale = avscale ;
    sclspeed = scalespeed ;
    myrot = rotation ;
    rotspeed = rotatespeed ;
  }
  void shuffle() {
    // default is to do nothing; override this in derived class.
  }
  void forceshuffle() {
    // default is to change location; add to this (extend) in derived class.
    myx = round(random(10, width-10));  // Put it somewhere on the display.
    myy = round(random(10, height-10));
  }
  int getX() {
    return myx ;
  }
  int getY() {
    return myy ;
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
        if (mine[0] >= theirs[0] && mine[0] <= theirs[2]) {
          // my left side is within them, move to the right
          speedX = abs(speedX);
          myx += 2*speedX ;  // jump away a little extra
        } else if (mine[2] >= theirs[0] && mine[2] <= theirs[2]) {
          // my right side is within them, move to the left
          speedX = - abs(speedX);
          myx += 2*speedX ;
        }
        // Above may have eliminated the overlap, check before proceeding.
        mine = getBoundingBox();
        if (overlap(this,a)) {
        // Do equivalent check for vertical overlap.
          if (mine[1] >= theirs[1] && mine[1] <= theirs[3]) {
            speedY = abs(speedY); // my top, send it down
            myy += 2*speedY ;
          } else if (mine[3] >= theirs[1] && mine[3] <= theirs[3]) {
            speedY = - abs(speedY); // my bottom, send it up
            myy += 2*speedY ;
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
      //if (myscale >= 1) println("DEBUG WENT OFF LEFT " + speedX);
      // Too many print statements, restrict to the bigger Avatars.
      // I usually comment out print statements until I am sure the bug is gone.
    }
    if (xlimitright != Integer.MAX_VALUE && myx >= xlimitright && speedX > 0) {
      speedX = - speedX ;
      myx = xlimitright - 1 ;
      //if (myscale >= 1) println("DEBUG WENT OFF RIGHT " + speedX);
    }
    if (ylimittop != Integer.MIN_VALUE && myy <= ylimittop && speedY < 0) {
      speedY = - speedY ;
      myy = ylimittop + 1 ;
      //if (myscale >= 1) println("DEBUG WENT OFF TOP " + speedY);
    }
    if (ylimitbottom != Integer.MAX_VALUE && myy >= ylimitbottom && speedY > 0) {
      speedY = - speedY ;
      myy = ylimitbottom - 1 ;
      //if (myscale >= 1) println("DEBUG WENT OFF BOTTOM " + speedY);
    }
  }
}

/**
 *  JohnWick is my Avatar-derived class that displays & moves a mobile JohnWick.
 *  You must write your own Avatar-derived class. You can delete class JohnWick
 *  or use it to interact with your Avatar-derived class.
**/
class JohnWick extends CollisionDetector {
  /* The data fields store the state of the Avatar. */
  
  protected int legdist = 0 ; // You can initialize to a constant here.
  JohnWick(int avx, int avy, float spdx, float spdy, float avscale) {
    super(avx,avy,spdx,spdy,avscale,0,0,0);
    // Call the base class constructor to initialize its data fields,
    // then initialize this class' data fields.
    xlimitright = width ;
    ylimitbottom = height ; // limit off-screen motion to
    xlimitleft = 0 ;    // one width or height off the display
    ylimittop = 0 ;    // in either direction
    
    //NEW CHANGE WIDTH HEIGHT ROTATE AND SCALE VARIABLES
    myrot = random(0, 360);
    rotspeed = 1;
    myscale = random(0.01, 1.5);
    sclspeed = 0.01;
    
    
  }
  void shuffle() {
    forceshuffle(); // always do it.
  }
  // The display() function simply draws the Avatar object.
  // The move() function updates the Avatar object's state.
  void display() {
    // Draw the avatar.
    push(); // STUDENT *MUST* use push() & translate first in display().
    //THE 0,0 Reference Point
    translate(myx, myy);
    rotate(radians(myrot));
    scale(myscale);
    noStroke();
    
    fill(0, 0, 0);
    //New addition the back of the hair
    rect(0, 5, 50, 38);
    
    fill(240, 150, 150);
    ellipse(0, 0, 50, 40); // head, 0,0 is the conceptual center of the object.
    // An object rotates around its 0,0 point.
    quad(-5 , 0, 5 , 0, 10 , 40 , -10 , 40 ); // neck
    fill(0);  // JohnWick gown
    ellipse(0, 60 , 40 , 80 ); // torso
    stroke(0);
    // stick arms & legs
    strokeWeight(8);
    line(0, 60 , -20 -abs(10-legdist) , 120 );  // left leg
    line(0, 60 , 20 +abs(10-legdist) , 120 );  // right leg
    strokeWeight(5);
    line(0, 60 , -40 , 20 -2*abs(10-legdist) );   // left arm
    line(0, 60 , 40 , 20 +2*abs(10-legdist) );   // right arm
    strokeWeight(2);
    
    //fill(0, 50, 255);
    
    fill(111, 48, 48); //brown eyes
    ellipse(-10 , -5 , 10 , 10 ); // avatar's right side of glasses
    ellipse(10 , -5 , 10 , 10 ); // avatar's right side of glasses
    
    //Changed to black eyes
    fill(0);
    
    //Change inside of eye
    ellipse(-10, -5, 5, 5); //right eye
    ellipse(10, -5, 5, 5); //left eye
    
    //line(-5 , -5 , 5 , -5 ); // glasses connector
    
    //line(-15 , -5 , -22 , -8 ); // left earpiece
    
    //line(15 , -5 , 22 , -8 ); // right earpiece
    
    fill(0);
    ellipse(0, 1 , 5 , 5 );  // nose
    arc(0, 10 , 20 , 10 , 0, PI); // mouth
    //
    //New addition
    arc(0, -14 , 50 , 20 , PI, PI+PI); //hairline
    
    strokeWeight(0);
    fill(255, 255, 255);
    triangle(0, 30, -5, 25, 5, 25); //top of tie
    triangle(0, 30, -5, 45, 5, 45); //bottom of tie
    
    ellipse(0, 55, 5, 5); //top button
    ellipse(0, 70, 5, 5); //bottom button
    
    fill(185, 15, 15);
    rect(10, 40, 8, 2); //hankerchif
    
    //Eliminated the hat
    //quad(-30 , -15 , 30 , -15 , 15 , -30 , -35 , -30 );
    pop(); // STUDENT *MUST* use pop() last in display().
  }
  // The move() function updates the Avatar object's state.
  void move() {
    //NEW CHANGE ROTATE FACTOR
    myrot += rotspeed;
    if(myrot < -360 || myrot > 360) {
       rotspeed = -rotspeed; 
    }
    
    // get ready for movement in next frame.
    myx = round(myx + speedX) ;
    myy = round(myy + speedY) ;
    legdist = (legdist+1) % 20 ;
    detectCollisions();
  }
  int [] getBoundingBox() {
    int [] result = new int[4];
    
    //NEW CHANGE ROTATING BOUNDING BOX
    
    if (myrot == 0) {
       result[0] = myx-round(40*myscale) ; // left extreme of left arm
       result[1] = myy - round(30*myscale); // top of hat
       result[2] = myx + round(myscale*max(20 +abs(10-legdist),40)); // max of right leg & arm
       result[3] = myy + round(120*myscale) ; // bottom of legs
    }
    else {
      //OLD RANDOM NUMBERS METHOD
      //result = rotateBB(-ewidth, -eheight/3.8, ewidth, eheight*1.28, rotateFactor,
        //myscale, myscale, myx, myy);
      
      //REAL MATHMATICAL METHOD
       result = rotateBB(-40, -30, max(20 +abs(10-legdist), 40), 120, myrot,
        myscale, myscale, myx, myy);
    }
    return result ;
  }
}

/**
 *  Class Furniture implements immobile obstacles as rectangles.
 *  It adds fields for object width, height, and color.
**/
class Furniture extends CollisionDetector {
  /* The data fields store the state of the Avatar. */
  protected int mywidth, myheight, mycolor ;
  // Save the the problems of writing a new display function
  // by implementing no-op rotation and scaling here,
  // subclasses can use them.
  // rot is in degrees.
  // The constructor initializes the data fields.
  Furniture(int avx, int avy, int w, int h, int c) {
    super(avx,avy,0,0,1.0,0,0,0);
    mywidth = w ;
    myheight = h ;
    mycolor = c ;
  }
  // The display() function simply draws the Avatar object.
  // The move() function updates the Avatar object's state.
  void display() {
    // Draw the avatar.
    push(); // STUDENT *MUST* use push() & translate first in display().
    translate(myx, myy);
    if (myrot != 0.0) {
      rotate(radians(myrot));
    }
    if (myscale != 1.0) {
      scale(myscale);
    }
    fill(mycolor);
    stroke(mycolor);
    strokeWeight(1);
    
    ellipse(0, 0, mywidth, myheight);
    
    pop(); // STUDENT *MUST* use pop() last in display().
  }
  // The move() function updates the Avatar object's state.
  // Furniture is immobile, so move() does nothing.
  void move() {
  }
  int [] getBoundingBox() {
    int [] result = rotateBB(-mywidth/2, -myheight/2, mywidth/2, myheight/2, myrot,
      myscale, myscale, myx, myy);
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
  Paddle(int avx, int avy, int w, int h, float rotatespeed, int c) {
    super(avx, avy, w, h, c);
    rotspeed = rotatespeed ;
    xlimitright = 2 * width ;
    ylimitbottom = 2 * height ;
    xlimitleft = - width ;    // one width or height off the display
    ylimittop = - height ;    // in either direction
    
    //NEW CHANGE SPEED VARIABLES CHANGED TO 0.5 TO MOVE
    speedX = 0.50;
    speedY = 0.50;
    
  }
  void move() {
    // Extend base class move by adding rotation.
    myrot += rotspeed ;
    while (myrot >= 360) {
      myrot -= 360 ;
    } 
    while (myrot < 0) {
      myrot += 360;
    }
    //NEW CHANGE ADDED MOVEMENT TO THE PADDLE
    myx = round(myx + speedX) ;
    myy = round(myy + speedY) ;
    detectCollisions();
    
    super.move(); // Do the base class move for those parts.
  }
}
