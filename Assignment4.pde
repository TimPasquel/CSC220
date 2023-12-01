/************************************************************
/* Sketch: CSC220Fall2023Recur3D, derived from CSC220Fall2020Recur3D,
/*    derived from CSC480SP2020Recur2D, derived from Recursive2020Parson,
/*    derived from Recursive2017Parson.
/*    CSC220Fall2021Recur3D replacees nested zdelta, xdelta, ydeltay
/*    for loops in drawRecursiveShape() with single loop with X,Y,Z limits
/*    under user control, and indirected recursion to drawIndirectRecursiveShape()
/*    that draws orthogonal, nested 2D shapes. It eliminates PImage Easter egg.
/*    CSC220Fall2020Recur3D added 3D space partitioning & navigation
/*    to CSC480SP2020Recur2D. This was originally a CSC220 project in 2017.
/* Author: Dr. Parson and Tim Pasquel
/* Creation Date: 11/06/2022
/* Due Date: Thursday 11/30/2023
/* Course: CSC220
/* Professor Name: Dr. Parson
/* Assignment: 4.
/* Original Sketch name: CSC220Fall2023Recur3D, Parson's solution.
/* Purpose: Demonstrate & accelerate a recursive graphical shape.
*************************************************************/
/*
// keyPressed() WORKS AS FOLLOWS:
// UP increments recursionDepth with no limit.
// DOWN decrements recursionDepth, does not take it < 0.
// RIGHT increments rotationIncrement, wrapping from 359 to 0.
// LEFT decrements rotationIncrement, wrapping from 0 to 359.
// key '0' puts into isPaint=true mode, no background() call in draw()..
// Upper case 'C' sets isPaint to false ('C' for Clear).
// Upper case 'R' sets rotation and rotationIncrement to 0 ('R' for Reset).
//    'R' also eliminates global rotation.
// (key - 'a') and multiply by 10 to get a new frameRate.
// 'g' toggles rotation of the whole space, default is false
// 'O' enters shape rotateZ, no rotateX or rotateY
// '-' enters shape rotateX, no rotateZ or rotateY (dash character)
// '|' enters shape rotateY, no rotateX or rotateZ (vertical bar)
// 'F' toggles freezing the display
 *  'p' sets perspective projection; 'o' sets orthographic (NEW TO 3D)
 *  'f' flips the eye to look at back or front of Z.
 *  vvv START OF KEY POLLING SUPPLIED IN HANDOUT IN moveCameraRotateWorldKeys() vvv
 *  KEYS BELOW ARE WHEN **NEITHER* CONTROL NOR ALT KEY IS CURRENTLY ENGAGED.
 *  'u' when held down moves camera up in Z direction *very* slowly
 *  'U' when held down moves camera up in Z direction quickly
 *  'd' when held down moves camera down in Z direction *very* slowly
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
 *  ^^^ END OF KEY POLLING SUPPLIED IN HANDOUT IN moveCameraRotateWorldKeys() ^^^
 *  VVV CONTINUOUS CONTROL and ALT key closures, CONTROL or ALT key held down VVV
 *  CONTROL-x CONTROL-y CONTROL-z continuously increment these by spanIncr.
 *  CONTROL-X CONTROL-Y CONTROL-Z (upper case) continuously decrement these by spanIncr.
 *  float xSpanLimit = 0.5, ySpanLimit = 0.5, zSpanLimit = .5 ;
 *  ALT-x ALT-y ALT-z continuously increment these by spanIncr.
 *  ALT-X ALT-Y ALT-Z (upper case) continuously decrement these by spanIncr.
 *  float xScaleAmount = 0.5, yScaleAmount = 0.5, zScaleAmount = 0.5 ;
 *  ^^^ END CONTINUOUS CONTROL and ALT key closures ^^^
 *  'R' resets to original camera point of view,
 *      also resets xeye, yeye, zeye, worldxrotate, worldyrotate, worldzrotate
 *      to their original, default positions
 *  '2' sets spanSteps at 2 and '4' sets spanSteps at 4
 *  SPACE BAR held down moves camera x,y to mouseX*2-width, mouseY*2-height
*/

int recursionDepth = 0 ; // How many function calls deep is the recursion, staring at 0 for no recursion. Increment on UP, decrement on DOWN, don't go negative.
float rotation = 0.0 ;   // How many degrees to rotate the shape in degrees.
float rotationIncrement = 0 ; // How much to add to rotation as recursion depth increases, increment/decrement on RIGHT/LEFT, keep in range 0..360.
boolean isPaint = false ; // 0 sets to true for no background() call, C resets to false.
final int fRate = 30 ; // frame rate constant.
final int strokeSize = 20 ; // basis for strokeWeight()
boolean isGridRotating = false ;
enum RotationType {
  ROTATEZ, ROTATEX, ROTATEY
};
RotationType rottype = RotationType.ROTATEZ ;
// Only switch rottype when we approximate 0 degrees rotation
// to avoid a big discontinuity in the shape & space.
RotationType nextrottype = RotationType.ROTATEZ ;
boolean nextIsGridRotating = false ;
boolean isFrozen = false ;
boolean isOrtho = false ;
boolean lookAtBack = true ;  // toggle with 'f' for flip horizon between back and front

// Added 3D navigation
float xeye, yeye, zeye ;
float worldxrotate = 0, worldyrotate = 0, worldzrotate = 0 ;
float degree = radians(1.0), around = TWO_PI ;

// Globals that allow interactive partitioning of 3D space.
// [xyz]SpanLimit are fractions of the scaled width, height, height in
// drawRecursiveShape(), their negative and positive values states range of
// xdelta of -xSpanLimit * width to xSpanLimit * width, similar for
// ydelta and zdelta for height.
// CONTROL-x CONTROL-y CONTROL-z continuously increment these by spanIncr.
// CONTROL-X CONTROL-Y CONTROL-Z (upper case) continuously decrement these by spanIncr.
float xSpanLimit = 0.5, ySpanLimit = 0.5, zSpanLimit = .5 ;
// The above SpanLimits may range from -[xyz]SpanRange to [xyz]SpanRange.
// spanIncr is the increment, -spanIncr decrement for the above SpanLimits.
final float xSpanRange = 2.0, ySpanRange = 2.0, zSpanRange = 2.0, spanIncr = .002;
// Three separate scale values for drawRecursiveShape(), above SpanRanges are their limits.
// ALT-x ALT-y ALT-z continuously increment these by spanIncr.
// ALT-X ALT-Y ALT-Z (upper case) continuously decrement these by spanIncr.
float xScaleAmount = 0.5, yScaleAmount = 0.5, zScaleAmount = 0.5 ;
int spanSteps = 2 ; // keyPressed() '2' sets spanSteps at 2 and '4' sets spanSteps at 4
// spanSteps controls how many steps within xSpanLimit, ySpanLimit, zSpanLimit

PImage STUDENTIMAGE ;
int imgwidth, imgheight;
float aspectRatio;

PShape STUDENTSHAPE ; // STUDENT I set this via createShape in setup() but use this in drawShape().
// See STUDENTSHAPE B requirement in drawShape().

void setup() {
  // fullScreen(P3D); // STUDENT adjust size() for your monitor.
  size(1500, 1000, P3D);    // Use size() to avoid Zoom problem on fullScreen.
  frameRate(fRate);         // Call frameRate() after size to avoid the new Mac problem.
  colorMode(HSB, 360, 100, 100, 100);
  
  //ADDED STUDENT PARAMATERS
  STUDENTIMAGE = loadImage("IMG_1900.jpg");
  imgwidth = STUDENTIMAGE.width;
  imgheight = STUDENTIMAGE.height;
  aspectRatio = float(imgheight)/ imgwidth;
  
  // STUDENT replace with your own image file for drawShape()
  background(0, 100, 50);
  strokeWeight(strokeSize);
  xeye = width / 2 ;
  yeye = height / 2 ;
  zeye = (height*3) ;
  ellipseMode(CENTER);  // set these as defaults, student may change
  rectMode(CENTER);
  imageMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
}

void draw() {
  if (isFrozen) {
    return ;
  }
  if (isOrtho) {
    ortho();
  } else {
    perspective();
  }
  if (! isPaint) {
    background(0, 100, 50);
  }
  push();
  moveCameraRotateWorldKeys();
  translate(width/2, height/2);  // 0,0 is at middle of the display
  drawRecursiveShape(0, recursionDepth, rotation) ;  // draw the shape
  rotation = (rotation + rotationIncrement) ;  // use this rotation next time in draw().
  // Since rotationIncrement may be negative, use while loop instead
  // of modulo operator to wrap around. Also, update any pending
  // rottype when rotation approaches 0 to avoid jumps in the shape.
  while (rotation < 0.0) {
    rotation += 360.0 ;
  }
  while (rotation >= 360.0) {
    rotation -= 360.0 ;
  }
  if (nextrottype != rottype && rotation <= abs(rotationIncrement)) {
    rottype = nextrottype ;
  }
  if (nextIsGridRotating != isGridRotating && rotation <= abs(rotationIncrement)) {
    isGridRotating = nextIsGridRotating ;
  }
  pop();
  //println("frameRate " + frameRate);
}

void drawRecursiveShape(final int mydepth, final int recursionDepth, final float rotation) {
  if (mydepth >= recursionDepth) {
    push(); // This is the base case, no recursion.
    helpRotate();
    drawShape(mydepth, rotation);
    pop();
  } else {
    // This is the recursive case.
    // Partition the entire window using -xSpanLimit * width, -ySpanLimit * width, and
    // -zSpanLimit * width as the starting points, using xSpanLimit * width,
    // ySpanLimit * width, and zSpanLimit * width inclusive as the ending points,
    // and xincrement, yincrement, zincrement as the increments, where xSpanLimit of .25
    // for example gives 2 steps spanning the center half of width when spanSteps == 2.
    // spanSteps is limited to values 2 or 4 for symmetry & speed of draw().
    float xincrement = (xSpanLimit * 4.0 * width) / spanSteps;
    float yincrement = (ySpanLimit * 4.0 * height) / spanSteps;
    float zincrement = (zSpanLimit * 4.0 * height) / spanSteps;
    for (float xdelta = -xSpanLimit * width; xdelta <= xSpanLimit * width ; xdelta += xincrement) {
      for (float ydelta = -ySpanLimit * height; ydelta <= ySpanLimit * height ; ydelta += yincrement) {
        for (float zdelta = -zSpanLimit * height; zdelta <= zSpanLimit * height ; zdelta += zincrement) {
          //println("DEBUG xdelta " + xdelta + " ydelta " + ydelta + " zdelta " + zdelta
            //+ " xincrement " + xincrement + " yincrement " + yincrement + " zincrement " + zincrement);
          push();
          strokeWeight(strokeSize/4);
          stroke(0,0,0);  // black line connector
          if (isGridRotating) {
            helpRotate();
          }
          line(0,0,0,xdelta,ydelta,zdelta); // draw line from center of outer region to center of nested region
          strokeWeight(strokeSize);
          translate(xdelta, ydelta, zdelta); // 0,0 is now center of outer region to center of nested region
          scale(xScaleAmount, yScaleAmount, zScaleAmount);
          drawRecursiveShape(mydepth+1, recursionDepth, rotation);
          pop();
          // STUDENT A 20%: At this bottom section of the recursive case call drawShape(mydepth, rotation);
          // just like in the non-recursive case, with its full size, not scaled via scale(),
          // but showing the same rotation in effect as the base case (non-recursive) drawShape.
          // Achieving this requires some additional lines of code, properly placed.
          
          ////ADDITIONS
          float scaledown = 1.0;
          push();
          for(int depth = 0; depth <= recursionDepth; depth++) {
            push();
            helpRotate();
            scale(scaledown);
            drawShape(recursionDepth, rotation);
            scaledown *= 0.75;
            pop();
          }
          pop();
          
        }
      }
    }
  }
}

void helpRotate() {
  if (rotation != 0.0) { // rotate the shape just at the time of drawing it.
      float rads = radians(rotation) ;
      if (rottype == RotationType.ROTATEX) {
        rotateX(-rads);
      } else if (rottype == RotationType.ROTATEY) {
        rotateY(rads);
      } else {
        rotateZ(rads);
      }
   }
}

boolean nesting = false ;
void drawShape(int mydepth, final float rotation) {
  // Since HSB uses 0..359 degrees, just like rotation,
  // use rotation for HUE as well. I am adding 175 so
  // it comes out as cyan when there is no rotation.
  stroke((175+rotation)%360,100,100);
  fill((rotation)%360,100,100);

  // STUDENT B 50%: Each student creates their own shape according to handout spec.
  // You must use 2D shapes only, with copies rotated in X, Y, and Z directions, and
  // nested to the degree given by global recursionDepth+1. Also, plot one 2D PShape STUDENTSHAPE
  // per https://processing.org/reference/createShape_.html, and plot it as the innermost nested shape per // 
   // recursionDepth.
  // I initialized STUDENTSHAPE via createShape() in setup() to avoid doing it repeatedly inside drawShape().
  // I will demo. The handout code does none of this.
  // NOTE: If you plot 2 2D shapes of different colors in the same Z plane, their pixels will
  // munge together. The later one plotted will NOT cover the earlier ones. 
  // Therefore, as you nest deeper to plot smaller shapes, you could plot 2 of each offset at
  // increased z and -z distances from the outermost one. I just stuck with the same color instead
  // of plotting multiple copies. However, I plotted 2 copies of the STUDENTSHAPE,
  // one at a positive and one at a negative Z translate, to correct the problem.

  // Plot via shape(STUDENTSHAPE, 0, 0, yourwidth, yourheight) one library-supplied PShape built with 
  // STUDENTSHAPE  = createShape(â€¦) (could be a 2D vector file via loadShape() if you know how to build those), 
  // AND display one STUDENTIMAGE loaded within setup() with loadImage() and plotted with 
  // image(STUDENTIMAGE, 0, 0, yourwidth, yourheight). Call createShape() and loadImage() 
  // up in setup() to avoid the overhead of creating them in each call to drawShape().
  // You do NOT need to use vertex() in creating your PShape. You can use a canned library 
  // shape as documented in the createShape() documentation.
 
  //line(-width/4, -height/3, -width/4, height/3);
  //line(width/4, -height/3, width/4, height/3);
  //line(-width/3, 0, width/3, 0);
  
  // next ellipses inside sphere for navigating in.
  //ellipse(0,0,width/12, height/12);
  //ellipse(0,0,height/12, width/12);
 
 ////ADDITIONS
 //float scaledown = 1.0;
 //push();
 //for(int depth = 0; depth <= mydepth; depth++) {
 //  push();
 //  helpRotate();
 //  scale(scaledown);
 //  drawShape(mydepth, rotation);
 //  scaledown *= 0.75;
 //  pop();
 //}
 //pop();
 
 
  
  push();
  
  //ADDED THE X Y AND Z SHAPE AS WELL AS IMAGE TEXTURING
  strokeWeight(3);
  STUDENTSHAPE  = createShape(RECT, 0, 0, 500, 200);
  
  shape(STUDENTSHAPE, -250, 100, -500, 200);
  image(STUDENTIMAGE, 0, 0, -500, 200);
  rotateX(PI/2);
  shape(STUDENTSHAPE, -250, 100, -500, 200);
  image(STUDENTIMAGE, 0, 0, -500, 200);
  rotateY(PI/2);
  shape(STUDENTSHAPE, -250, 100, -500, 200);
  image(STUDENTIMAGE, 0, 0, -500, 200);
  rotateZ(PI/2);
  
  strokeWeight(.1);
  stroke(0);
  scale(10.0);
  sphereDetail(10);
  fill((rotation+42)%360,100,100);
  sphere(10.0);
  fill((rotation+12345)%360,100,100);
  stroke(0);
  pop();
}

boolean controlKey = false ;
boolean altKey = false ;
boolean shiftKey = false ;
void keyPressed() {
  println("DEBUG keyPressed() key=" + key + ", int(key) =" + int(key) + ", keyCode=" + keyCode + ", iscoded = " + (key == CODED));
  println("DEBUG controlKey: " + controlKey + ", altKey: " + altKey + " shiftKey " + shiftKey + " on " + key);
  // See https://processing.org/reference/keyCode.html
  if (key == CODED) {
    if (keyCode == CONTROL) {
      controlKey = true ;
    } else if (keyCode == ALT) {
      altKey = true ;
    } else if (keyCode == SHIFT) {
      shiftKey = true ;
    } else if (keyCode == UP) {
      recursionDepth++ ;
      println("recursionDepth " + recursionDepth);
    } else if (keyCode == DOWN) {
      recursionDepth = constrain(recursionDepth-1, 0, recursionDepth);
      println("recursionDepth " + recursionDepth);
    } else if (keyCode == RIGHT) {
      rotationIncrement = ((int)rotationIncrement+1) % 360 ;
      println("rotationIncrement " + rotationIncrement);
    } else if (keyCode == LEFT) {
      rotationIncrement = ((int)rotationIncrement-1+360) % 360 ;
      println("rotationIncrement " + rotationIncrement);
    }
  } else if (key == '0') {
    isPaint = true ;
  
  // STUDENT C 10%: 
  // on key of '2' set spanSteps to 2, 
  // on key of '4' set spanSteps to 4.
  // on key of '6' set spanSteps to 6.
  // on key of '8' set spanSteps to 8.
  // Note you can treat character variables like key and constants like '0'
  // as integers for the purpose of arithmetic such as subtraction and
  // numeric comparisions of key to character constants. You don't necessarily
  // need to but it can shorten your code. Or you can just use individual
  // "else if" statements for each key constant or a switch statement.
  // Also, setting spanSteps greater than 4 runs slowly with more than 1 level
  // of recursion. When testing, the starting point is spanSteps == 2.
  // Hitting '2' after recursing 1 level deep should show no change.
  } 
  
  //ADDED THE KEYS 2-8
  else if(key == '2') {
       spanSteps = 2; 
    }
    else if(key == '4') {
       spanSteps = 4; 
    }
    else if(key == '6') {
       spanSteps = 6; 
    }
    else if(key == '8') {
       spanSteps = 8; 
    }
  
  else if (key == 'C') {
    isPaint = false ;
  } else if (key == 'R') {
    // Use 'C' for this: isPaint = false ;
    rotation = 0 ;
    rotationIncrement = 0 ;
    isGridRotating = false ;
    nextIsGridRotating = false ;
    rottype = RotationType.ROTATEZ ;
    nextrottype = RotationType.ROTATEZ ;
    xeye = width / 2 ;
    yeye = height / 2 ;
    zeye = (height*3) /* / tan(PI*30.0 / 180.0) */ ;
    worldxrotate = worldyrotate = worldzrotate = 0 ;
    lookAtBack = true ;
    xSpanLimit = ySpanLimit = zSpanLimit = 0.5 ;
    xScaleAmount = yScaleAmount = zScaleAmount = 0.5 ;
  } else if (key == 'f') {
    lookAtBack = ! lookAtBack ;
    print("lookAtBack is " + lookAtBack);
  } else if (key == 'g') {
    nextIsGridRotating = ! nextIsGridRotating ;
    println("next isGridRotating = " + nextIsGridRotating);
  } else if (key == 'O') {
    nextrottype = RotationType.ROTATEZ ;
    println("next rotation type is rotateZ");
  } else if (key == '-') {
    nextrottype = RotationType.ROTATEX ;
    println("next rotation type is 'rotateX'");
  } else if (key == '|') {
    nextrottype = RotationType.ROTATEY ;
    println(" nextrotation type is 'rotateY'");
  } else if (key == 'F') {
    isFrozen = ! isFrozen ;
    println("isFrozen = " + isFrozen);
  } else if (key == 'o') {
    isOrtho = true ;
    println("using orthographic projection");
  } else if (key == 'p') {
    isOrtho = false ;
    println("using perspective projection");
  }
}

void keyReleased() {
  println("DEBUG keyReleased() key=" + key + ", int(key) =" + int(key) + ", keyCode=" + keyCode + ", iscoded = " + (key == CODED));
  println("DEBUG controlKey: " + controlKey + ", altKey: " + altKey + " shiftKey " + shiftKey + " on " + key);
  if (key == CODED) {
    if (keyCode == CONTROL) {
      controlKey = false ;
    } else if (keyCode == ALT) {
      altKey = false ;
    } else if (keyCode == SHIFT) {
      shiftKey = false ;
    }
  }
}

// Added 2/2020 to move camera and rotate world when these keys are held down.
void moveCameraRotateWorldKeys() {
  if (keyPressed) {
    if (! (controlKey || altKey)) {
      if (key == 'u') {
        zeye += 1/(recursionDepth+1.0) ;
        // println("DEBUG u " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
      } else if (key == 'U') {
        zeye += 50/(recursionDepth+1.0) ;
        // println("DEBUG U " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
      } else if (key == 'd') {
        zeye -= 1/(recursionDepth+1.0) ;
        // println("DEBUG d " + zeye + ", minZ: " + minimumZ + ", maxZ: " + maximumZ);
      } else if (key == 'D') {
        zeye -= 50/(recursionDepth+1.0) ;
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
    } else {
      // controlKey, altKey, or both are currently engaged:
      // STUDENT D 20%: IMPLEMENT THE FOLLOWING
      //  VVV CONTINUOUS CONTROL and ALT key closures, CONTROL or ALT key held down VVV
      // CONTROL-x CONTROL-y CONTROL-z continuously increment these by spanIncr.
      // CONTROL-X CONTROL-Y CONTROL-Z (upper case) continuously decrement these 
      // SpanLimits by spanIncr:
      // float xSpanLimit = 0.5, ySpanLimit = 0.5, zSpanLimit = .5 ;
      // The above SpanLimits may range from -[xyz]SpanRange to [xyz]SpanRange.
      // spanIncr is the increment, -spanIncr decrement for the above SpanLimits.
      // final float xSpanRange = 2.0, ySpanRange = 2.0, zSpanRange = 2.0, spanIncr = .002;
      // USE -[xyz]SpanRange and [xyz]spanRange as limit within a constrain call.
      if (controlKey) {
        // In this code, key == 'x', for example, is how Mac detects control keys,
        // and the other mess is for Windows & Processing 4.x..
        
        //DID THE CONTROL CHANGES FOR THE CAPTIAL AND LOWER CASE DIRECTION CONTROLS        
        
        
        if (key == 'x' || ((int(key) == 24 || (key == CODED && keyCode == 88)) && ! shiftKey)) {
          println("CONTROL-x, replace this line with the specified code.");
          xSpanLimit += spanIncr;
        } else if (key == 'y'|| ((int(key) == 25 || (key == CODED && keyCode == 89)) && ! shiftKey)) {
          println("CONTROL-y, replace this line with the specified code.");
          ySpanLimit += spanIncr;
        } else if (key == 'z'|| ((int(key) == 26 || (key == CODED && keyCode == 90)) && ! shiftKey)) {
          println("CONTROL-z, replace this line with the specified code.");
          zSpanLimit += spanIncr;
        } else if (key == 'X'|| ((int(key) == 24 || (key == CODED && keyCode == 88)) && shiftKey)) {
          println("CONTROL-X, replace this line with the specified code.");
          xSpanLimit -= spanIncr;
        } else if (key == 'Y'|| ((int(key) == 25 || (key == CODED && keyCode == 89)) && shiftKey)) {
          println("CONTROL-Y, replace this line with the specified code.");
          ySpanLimit -= spanIncr;
        } else if (key == 'Z'|| ((int(key) == 26 || (key == CODED && keyCode == 90)) && shiftKey)) {
          println("CONTROL-Z, replace this line with the specified code.");
          zSpanLimit -= spanIncr;
        }
      }
      // ALT-x ALT-y ALT-z continuously increment these by spanIncr.
      // ALT-X ALT-Y ALT-Z (upper case) continuously decrement these by spanIncr.
      // float xScaleAmount = 0.5, yScaleAmount = 0.5, zScaleAmount = 0.5 ;
      // The ScaleAmounts may range from -[xyz]SpanRange to [xyz]SpanRange.
      // USE -[xyz]SpanRange and [xyz]spanRange as limit within a constrain call.
      // STUDENT DOES NOT NEED CODE LIKE (int(key) == 24 && ! shiftKey)).
      // Just use code like "key == 'x'" inside this block, i.e., like Mac.
      // ^^^ END CONTINUOUS CONTROL and ALT key closures ^^^
      // IF A POLLED KEY STICKS< JUST HIT THE SPACE BAR TO UNSTICK IT.
      if (altKey) {
        println("ALT-" + key + " , replace this line with the specified code.");
      }
    }
  }
  // Make sure 6th parameter -- focus in the Z direction -- is far, far away
  // towards the horizon. Otherwise, ortho() does not work.
  //camera(xeye, yeye,  zeye, xeye, yeye,  zeye-signum(zeye-minimumZ)*maximumZ*2 , 0,1,0);
  camera(xeye, yeye,  zeye, xeye, yeye,  (lookAtBack ? -1000000 : 1000000),
    0,1,0);
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
    // Do not use push()-pop() instead of the inverse translate,
    // because pop() would discard the rotations.
  }
}
