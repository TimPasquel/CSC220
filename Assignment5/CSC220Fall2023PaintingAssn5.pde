/************************************************************
/* Author: STUDENT NAME: Tim Pasquel and Dr. Parson
/* Permission to share in Rohrbach Library and YouTube (YES or NO): Yes
/* Creation Date: 11/21/2023
/* Due Date: Thursday 12/14/2023
/* Course: CSC220
/* Professor Name: Dr. Parson
/* Assignment: 5.
/* Purpose: Create video for installation with credit in Rohrbach Library & YouTube.
/* See https://faculty.kutztown.edu/parson/fall2023/csc220fall2023assn5.html for requirements.
*************************************************************/

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// DID THE BONUS POINTS AND ADDED GREYSCALE FOR THE +S4
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


/*  KEYBOARD COMMANDS
  All require a trailing \n to trigger interpretation:
  
  +MUTATOR for replacing a MUTATOR from set below to be the sole mutator
    of the worker-thread mutator queue. See MUTATOR commands below.
  - for removing any MUTATORs from the worker-thread queue.
  
  rANGLE rotate the previous canvas snapshot ANGLE degrees as the background
  sSCALE scale the previous canvas snapshot SCALE amount as the background
  RANGLE rotate the foregound image a fixed ANGLE in degrees
  SSCALE scale the forground image a fixed SCALE
  Xpixels Move horizontally pixels per draw(), positive or negative
  Ypixels Move vertically pixels per draw(), positive or negative.
  f toggle foreground image painting
  b toggle background image painting
  F toggle drawForeground() foreground call
  B toggle drawBackground() background call
  c toggle clipping circle
  C toggle clipping square

  p toggles painting on/off, i.e., no background command in draw() when on
  e toggles echo on/off, i.e., take snapshot at end of draw() when on, display at start of draw()
  x toggles reflect on/off anything painted around the x axis (reflect via scale(1,-1)).
  y toggles reflect on/off anything painted around the y axis (reflect via scale(-1,1)).
  z toggles reflect x and y on/off, on reflects anything painted around the x and y axes
  
  0 resets translations, rotates, scales to their default values, eliminates mutation(s) in effect
  - eliminates mutation(s) in effect
  1 or 2 or ... Decimal String advances the imageQueue reading this many positions % imageLimit
  QQQ quits the program after flushing any pending key capture recording output
  
  MUTATORS:            IGNORE INT and FLOAT in these commands. To be implemented later.
                       For now they use default initialization values set in their constructors.
  
  +b                   blu(2) filter
  +f                   fade foreground image
  +e                   etch with a probability of 0.15
  +n                   nest with a nesting ratio 0f 0,75
  +m                   mask image 0 with image 1
  +s                   blend SCREEN image 0 with image 1
  +t                   threshold etcher 
  +c                   etch in and out from an outer circle
  +q                   etch in and out from an outer square
  +s1                  Posterize Mutator
  +s2                  Erode Mutator
  +s3                  Dilate Mutator
  +s4                  Invisible Mutator hides foreground PImage
  -                    eliminates mutation(s) in effect
*/

boolean IS_PRINTING_COMMAND = false ;  // STUDENT set to false after some practice!!!
// STUDENT: Replace my name with yours. Add a comment giving me permission to include
//          in Rohrbach Library installation.
final String CREDIT = "Tim Pasquel, CSC220, Fall 2023";
final String KeyRecordingFile = "Assn5KeyRecording1.txt" ; // Make null to skip recording/playback
boolean isRecording = false ;  // STUDENT MUST CHANGE THIS TO false FOR PLAYBACK
SortedMap<Integer,Character> playbackSequence = null ; // new TreeMap<Long,Character>

import java.util.* ;  // https://docs.oracle.com/javase/8/docs/api/index.html?java/util/List.html
import java.util.concurrent.* ;
import java.io.* ;
final int imageLimit = 2 ;  // Mutators all use 2 at most.
final List<PImage> imageQueue 
  = Collections.synchronizedList(new LinkedList<PImage>());
final List<PImageMutator> threadMutatorQueue 
  = Collections.synchronizedList(new LinkedList<PImageMutator>());
final Map<Character, PImageMutator> threadMutatorMap 
  = Collections.synchronizedMap(new HashMap<Character, PImageMutator>());
volatile PImage morphedImage = null ;
volatile MutatorManager workManager = null ;
volatile FutureTask<PImage> task = null ;

final PImageMutatorWorkerThread workerThread = new PImageMutatorWorkerThread(); ;
FileReaderActiveClass loaderThread = null ;
PrintWriter keyOut = null ;
BufferedReader keyIn = null ;

float rotateCanvasDegrees = 0.0, rotateForegroundDegrees = 0 ;
float scaleCanvasAmount = 1.0, scaleForegroundAmount = 1.0 ;
float rotateForegroundDegreesSpeed = 0, scaleForegroundAmountSpeed = 1 ;
boolean isPainting = false, isReflectX = false, isReflectY = false, isReflectZ = false ;
boolean isEchoing = false ;
boolean isForegroundPImage = true, isBackgroundPImage = true ;
boolean isForegroundDraw = false, isBackgroundDraw = false ;
PImage echoImage = null ;
PImage clipperCircle = null, clipperSquare = null ;
boolean isClipCircle = false, isClipSquare = false ;
float xloc = 0, yloc = 0, xspeed = 0, yspeed = 0 ;

void setup() {
  // Try to keep this size intact for sketch merging into video.
  size(1920, 1080, P2D);
  // fullScreen(P2D);  // just for testing
  frameRate(30);
  if (KeyRecordingFile != null && KeyRecordingFile.trim().length() > 0) {
    String recordingPath = sketchPath("") + "/" + KeyRecordingFile ;
    File recordingFile = new File(recordingPath);
    if (isRecording && recordingFile.exists()) {
      System.err.println("ERROR, PLEASE REMOVE OR RENAME KEYPRESSED RECORDING FILE "
        + KeyRecordingFile + " BEFORE RECORDING.");
      exit();
    } else if ((! isRecording) && ! recordingFile.exists()) {
      System.err.println("ERROR, KEYPRESSED RECORDING FILE PLAYBACK FILE "
        + KeyRecordingFile + " DOES NOT EXIST.");
      exit();
    }
    try {
      if (isRecording) {
        keyOut = new PrintWriter(recordingFile);
      } else {
        keyIn = new BufferedReader(new FileReader(recordingFile));
        playbackSequence = new TreeMap<Integer,Character>();
        String line ;
        // println("DEBUG playbackSequence PRE-LINE ");
        while ((line = keyIn.readLine()) != null) {
          // println("DEBUG playbackSequence LINE: " + line);
          line = line.trim();
          // println("DEBUG playbackSequence.put 0 " + line);
          int commaix = line.indexOf(",");
          if (commaix == -1) {
            continue ;
          }
          int timestamp = Integer.parseInt(line.substring(0,commaix));
          String remainder = line.substring(commaix+1);
          if (remainder.length() == 0) {
            playbackSequence.put(timestamp, '\n');
            // println("DEBUG playbackSequence.put 1 " + timestamp + " newline");
          } else {
            playbackSequence.put(timestamp, remainder.charAt(0));
            // println("DEBUG playbackSequence.put 1 " + timestamp + " " + remainder.charAt(0));
          }
        }
        keyIn.close();
      }
    } catch (FileNotFoundException fxx) {
        System.err.println("ERROR, RECORDING/PLAYBACK FILE "
          + KeyRecordingFile + " WILL NOT OPEN.");
        exit();
    } catch (IOException ioxx) {
        System.err.println("ERROR, PLAYBACK FILE "
          + KeyRecordingFile + " IO EXCEPTION: " + ioxx.getMessage());
        exit();
    }
  }
  int midwidth = width / 2;
  int midheight = height / 2;
  int radius = min(midwidth,midheight);
  int diameter = min(width,height);
  int black = color(0,255);
  clipperCircle = createImage(width, height, ARGB);
  clipperCircle.loadPixels();
  Arrays.fill(clipperCircle.pixels, 0);  // transparent in center
  clipperSquare = createImage(width, height, ARGB);
  clipperSquare.loadPixels();
  Arrays.fill(clipperSquare.pixels, 0);  // transparent in center
  int topmargin = (height - diameter) / 2;
  int leftmargin = (width - diameter) / 2 ;
  int bottommargin = height - topmargin ;
  int rightmargin = width - leftmargin ;
  for (int col = 0 ; col < width ; col++) {
    for (int row = 0 ; row < height ; row++) {
      int pix = (row * width) + col ;
      if (dist(col,row,midwidth,midheight) >= radius) {
        clipperCircle.pixels[pix] = black ;
      }
      if ((col < leftmargin || col >= rightmargin)
          || (row < topmargin || row >= bottommargin)) {
        clipperSquare.pixels[pix] = black ;
      }
    }
  }
  clipperCircle.updatePixels();
  clipperSquare.updatePixels();
  try {
      loaderThread = new FileReaderActiveClass();
  } catch (FileNotFoundException fnx) {
    System.err.println("ERROR: CSC220Fall2023PaintingAssn5.txt not found.");
    exit();
  }
  Thread thread = new Thread(workerThread);
  thread.start();
  thread = new Thread(loaderThread);
  thread.start();
  background(0);
  // FOLLOWING ARE FOR INITIAL MUTATOR TESTS ONLY
  //threadMutatorQueue.add(new BlurMutator(imageQueue, null, null));
  //threadMutatorQueue.add(new FadeMutator(imageQueue, null, null));
  //threadMutatorQueue.add(new EtchMutator(imageQueue, null, null));
  // threadMutatorQueue.add(new NestMutator(imageQueue, null, null));
  //threadMutatorQueue.add(new MaskMutator(imageQueue, null, null));
  //threadMutatorQueue.add(new BlendScreenMutator(imageQueue, null, null));
  // threadMutatorQueue.add(new ThresholdEtchMutator(imageQueue, null, null));
  // threadMutatorQueue.add(new CircleEtchMutator(imageQueue, null, null));
  // threadMutatorQueue.add(new SquareEtchMutator(imageQueue, null, null));
  // threadMutatorQueue.add(new PosterMutator(imageQueue, null, null));
}

void draw() {
  if (workManager == null) {
    if (imageQueue.size() == 0) {
      return ;  // booting up
    }
    workManager = new MutatorManager(imageQueue, null, null);
  }
  if (task != null && task.isDone()) {
    try {
      morphedImage = task.get();
      // println("DEBUG GOT BACK A TASK");
    } catch (Exception xxx) {
      System.err.println("ERROR FROM MUTATOR MANAGER: "
        + xxx.getClass() + "," + xxx.getMessage());
      task = null ;
    }
  //} else {
  //  println("DEBUG POLLED TASK NOT DONE ", task);
  }
  if (! (isPainting || isEchoing)) {
    background(0);
  }
  push();
  imageMode(CENTER);
  translate(width/2, height/2);
  if (isEchoing && echoImage != null) {
    push();
    rotate(radians(rotateCanvasDegrees));
    scale(scaleCanvasAmount);
    image(echoImage, 0, 0);
    // morphedImage = echoImage ;
    // workManager.setMorphedImage(morphedImage);
    pop();
  } else if (isBackgroundPImage && imageQueue.size() > 1) {
    imageWithReflectRotate(imageQueue.get(1), isReflectX, isReflectY, true);
  }
  if (isBackgroundDraw) {
    drawBackground();
  }
  if (isForegroundPImage && imageQueue.size() > 0) {
    push();
    if (morphedImage == null) {
      morphedImage = imageQueue.get(0);
    }
    translate(xloc, yloc);
    rotate(radians(rotateForegroundDegrees));
    // println("scaleForegroundAmount", scaleForegroundAmount, "scaleForegroundAmountSpeed", scaleForegroundAmountSpeed);
    scale(scaleForegroundAmount);
    imageWithReflectRotate(morphedImage, isReflectX, isReflectY, false);
    pop();
  }
  if (isForegroundDraw) {
    drawForeground();
  }
  if (isClipCircle) {
    image(clipperCircle, 0, 0, width, height);
  } else if (isClipSquare) {
    image(clipperSquare, 0, 0, width, height);
  }
  pop();
  if (isEchoing) {
    echoImage = takeScreenShot();
  }
  move();
  if (threadMutatorQueue.size() > 0 && imageQueue.size() > 0
        && (task == null || task.isDone())) {
    task = new FutureTask<PImage>(workManager);
    workerThread.scheduleMutator(task);
    // println("DEBUG SENT A TASK");
  }
  push();
  fill(255, 255, 0);
  stroke(255, 255, 0);
  textSize(32);
  text(CREDIT, 32, height-32);
  if (printCommand != null) {
    rectMode(CORNER);
    fill(0);
    stroke(0);
    rect(30, height-130, 170, 40);
    fill(255, 255, 0);
    stroke(255, 255, 0);
    text("CMD: " + printCommand, 32, height-96);
  }
  pop();
  pollPlaybackSequence();
}
String printCommand = null ;

void pollPlaybackSequence() {
  int timestamp ;
  try {
    if (! (playbackSequence == null || playbackSequence.isEmpty())) {
      while ((timestamp = playbackSequence.firstKey()) <= frameCount) {
        char keyStroke = playbackSequence.get(timestamp);
        playbackSequence.remove(timestamp);
        keyInterpreter(keyStroke);
      }
    }
  } catch (NoSuchElementException nsx) {  // happens on QQQ
  }
}

void move() {
  xloc += xspeed ;
  if (xloc >= width/2) {
    xspeed = -abs(xspeed) ;
  } else if (xloc < -width/2) {
    xspeed = abs(xspeed);
  }
  yloc += yspeed ;
  if (yloc >= height/2) {
    yspeed = -abs(yspeed) ;
  } else if (yloc < -height/2) {
    yspeed = abs(yspeed);
  }
  rotateForegroundDegrees += rotateForegroundDegreesSpeed ;
  while (rotateForegroundDegrees <= -360) {
    rotateForegroundDegrees += 360 ;
  }
  while (rotateForegroundDegrees >= 360) {
    rotateForegroundDegrees -= 360 ;
  }
  scaleForegroundAmount *= scaleForegroundAmountSpeed ;
  if (scaleForegroundAmount >= 2) {
    scaleForegroundAmount = 1 ;
  } else if (scaleForegroundAmount <= 0.0125) {
    scaleForegroundAmount = 1 ;
  }
}

// STUDENT Create your own unique drawBackground,
// starting with push() and ending with pop(), and tes it
// using the 'B' key.
void drawBackground() {
  push();
  rectMode(CENTER);
  colorMode(RGB, 0, 0, 0, 255);
  fill(0, 255, 255);
  
  //CHANGED TO ELLIPSE TO LOOK LIKE A TIRE
  ellipse(-width/4-width/8, 0, 50, 50);
  ellipse(width/4+width/8, 0, 50, 50);
  ellipse(0, -height/4-height/8, 50, 50);
  ellipse(0, height/4+height/8, 50, 50);
  
  fill(255, 255, 255);
  ellipse(-width/4-width/8, 0, 25, 25);
  ellipse(width/4+width/8, 0, 25, 25);
  ellipse(0, -height/4-height/8, 25, 25);
  ellipse(0, height/4+height/8, 25, 25);
  
  pop();
}

// STUDENT Create your own unique drawForeground,
// starting with push() and ending with pop(), and tes it
// using the 'F' key.
int fgndColor = 0 ;
float fgndRotate = 0 ;
void drawForeground() {
  push();
  noFill();
  
  //CHANGED IT TO START ON BLACK
  colorMode(RGB, 0, 0, 0, 255);
  //colorMode(HSB, 360, 100, 100, 100);
  stroke(fgndColor, 100, 100);
  
  //CHANGED FROM 1 TO 5
  strokeWeight(5);
  rotate(fgndRotate);
  ellipse(0,0,1000,750);
  fgndColor = (fgndColor + 1) % 360 ;
  fgndRotate = (fgndRotate + 10) % 360 ;
  pop();
}

PImage takeScreenShot() {
  PImage result = createImage(width, height, ARGB);
  result.loadPixels();
  loadPixels() ;  // frame buffer for the display
  System.arraycopy(pixels, 0, result.pixels, 0, pixels.length);
  updatePixels();
  result.updatePixels();
  return result ;
}

void imageWithReflectRotate(PImage fg, boolean isReflectX, boolean isReflectY, boolean isRotate) {
  push();
  if (isReflectX && isReflectY) {
    if (isRotate) {
      rotate(QUARTER_PI);
    }
    translate(-width/4, -height/4);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    push();
    translate(0, height/2);
    scale(1.0, -1.0);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    pop();
    push();
    translate(width/2,0);
    scale(-1.0, 1.0);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    pop();
    push();
    translate(width/2,height/2);
    scale(-1.0, -1.0);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    pop();
  } else if (isReflectX) {
    push();
    if (isRotate) {
      rotate(HALF_PI);
    }
    translate(0, -height/4);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    push();
    translate(0, height/2);
    scale(1.0, -1.0);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    pop();
    pop();
  } else if (isReflectY) {
    push();
    if (isRotate) {
      rotate(HALF_PI);
    }
    translate(-width/4, 0);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    push();
    translate(width/2, 0);
    scale(-1.0, 1.0);
    image(fg, 0, 0, fg.width/2, fg.height/2);
    pop();
    pop();
  } else {
    image(fg, 0, 0, fg.width, fg.height);
  }
  pop();
}

void keyPressed() {
  if (keyOut != null) {
    keyOut.println("" + frameCount + "," + key);
  }
  keyInterpreter(key);
}

String commandBuffer = "" ;
void keyInterpreter(char key) {
  if (Character.isDigit(key) || key == '.' || key == ',') {
    commandBuffer = commandBuffer + key ;
    // println("DEBUG DIGIT", commandBuffer);
  } else if (key == '+') {
      commandBuffer = "+" ;
  } else if (key == '-') {
    commandBuffer = commandBuffer + key ; // may be -M or numeric sign
  } else if (key == 'x' || key == 'y'
      || key == 'z' || key == 'p' || key == 'e'
      || key == 'f' || key == 'b' || key == 'F'
      || key == 'B' || key == 'c' || key == 'C'
      || key == 'n' || key == 'm' || key == 'd'
      || key == 't' || key == 'q' || key == 's') {
    if (commandBuffer.equals("+")
        || commandBuffer.equals("-")) {
      commandBuffer = commandBuffer + key ;
    } else {
      commandBuffer = "" + key ;
    }
  } else if (key == 'r' || key == 's'
      || key == 'R' || key == 'S' || key == 'Y'
      || key == 'X') {
    commandBuffer = "" + key ;
  } else if (key == 'Q') {
    if (commandBuffer.length() > 0 && commandBuffer.charAt(0) == 'Q') {
      commandBuffer = commandBuffer + key ;
    } else {
      commandBuffer = "Q" ;
    }
  } else if (key != '\n') {
    commandBuffer = commandBuffer + key ;
  } else {    // key is newline, parse and execute
    if (IS_PRINTING_COMMAND) {
      printCommand = commandBuffer ;
    } else {
      printCommand = null ;
    }
    if (keyOut != null) {
      keyOut.flush();
    }
    if (commandBuffer.trim().length() > 0) {
      try {
        commandBuffer = commandBuffer.trim();
        char leadChar = commandBuffer.charAt(0);
        if (Character.isDigit(leadChar)) {
          int value = Integer.parseInt(commandBuffer);
          if (value > 0) {
            morphedImage = null ;
            workManager.setMorphedImage(null);
            if (task != null) {
              task.cancel(true);
              task = null ;
            }
            loaderThread.triggerLoadImage(value);
          } else {
            zapAll();
          }
        } else if (commandBuffer.equals("-")) {
          zapMutators();
        } else if (commandBuffer.trim().equals("QQQ")) {
          println("DEBUG QUIT");
          if (keyOut != null) {
            keyOut.flush();
            keyOut.close();
          }
          exit();
        } else if (leadChar == 'r') {
          float value = Float.parseFloat(commandBuffer.substring(1));
          println("DEBUG r parsed", value, commandBuffer);
          rotateCanvasDegrees = value ;
        } else if (leadChar == '+' || leadChar == '-') {
          if (commandBuffer.equals("+s1")) {
            zapMutators();
            threadMutatorQueue.add(new PosterMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+s2")) {
            zapMutators();
            threadMutatorQueue.add(new ErodeMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+s3")) {
            zapMutators();
            threadMutatorQueue.add(new DilateMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+s4")) {
            zapMutators();
            threadMutatorQueue.add(new InvisibleMutator(imageQueue, null, null));
          } else if (commandBuffer.substring(0,2).equals("+b")) {
            zapMutators();
            threadMutatorQueue.add(new BlurMutator(imageQueue, null, null));
          } else if (commandBuffer.substring(0,2).equals("+f")) {
            zapMutators();
            threadMutatorQueue.add(new FadeMutator(imageQueue, null, null));
          } else if (commandBuffer.substring(0,2).equals("+e")) {
            zapMutators();
            threadMutatorQueue.add(new EtchMutator(imageQueue, null, null));
          } else if (commandBuffer.substring(0,2).equals("+n")) {
            zapMutators();
            threadMutatorQueue.add(new NestMutator(imageQueue, null, null));
          } else if (commandBuffer.substring(0,2).equals("+m")) {
            zapMutators();
            threadMutatorQueue.add(new MaskMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+s")) {
            zapMutators();
            threadMutatorQueue.add(new BlendScreenMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+t")) {
            zapMutators();
            threadMutatorQueue.add(new ThresholdEtchMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+c")) {
            zapMutators();
            threadMutatorQueue.add(new CircleEtchMutator(imageQueue, null, null));
          } else if (commandBuffer.equals("+q")) {
            zapMutators();
            threadMutatorQueue.add(new SquareEtchMutator(imageQueue, null, null));
          }
        } else if (leadChar == 's') {
          float value = Float.parseFloat(commandBuffer.substring(1));
          println("DEBUG s parsed", value, commandBuffer);
          scaleCanvasAmount = value ;
        } else if (leadChar == 'R') {
          float value = Float.parseFloat(commandBuffer.substring(1));
          println("DEBUG R parsed", value, commandBuffer);
          rotateForegroundDegreesSpeed = value ;
          if (value == 0) {
            rotateForegroundDegrees = 0 ;
          }
        } else if (leadChar == 'S') {
          float value = Float.parseFloat(commandBuffer.substring(1));
          println("DEBUG S parsed", value, commandBuffer);
          scaleForegroundAmountSpeed = value ;
          if (value == 1) {
            scaleForegroundAmount = 1 ;
          }
         } else if (leadChar == 'X') {
          float value = Float.parseFloat(commandBuffer.substring(1));
          println("DEBUG X parsed", value, commandBuffer);
          xspeed = value ;
          if (value == 0) {
            xloc = 0 ;
          }
        } else if (leadChar == 'Y') {
          float value = Float.parseFloat(commandBuffer.substring(1));
          println("DEBUG Y parsed", value, commandBuffer);
          yspeed = value ;
          if (value == 0) {
            yloc = 0 ;
          }
        } else if (commandBuffer.equals("f")) {
          isForegroundPImage = ! isForegroundPImage ;
          println("isForegroundPImage = ",isForegroundPImage);
        } else if (commandBuffer.equals("b")) {
          isBackgroundPImage = ! isBackgroundPImage ;
          println("isBackgroundPImage = ",isBackgroundPImage);
        } else if (commandBuffer.equals("F")) {
          isForegroundDraw = ! isForegroundDraw ;
          println("isForegroundDraw = ",isForegroundDraw);
        } else if (commandBuffer.equals("B")) {
          isBackgroundDraw = ! isBackgroundDraw ;
          println("isBackgroundDraw = ",isBackgroundDraw);
        } else if (commandBuffer.equals("c")) {
          isClipCircle = ! isClipCircle ;
          if (isClipCircle) {
            isClipSquare = false ;
          }
          println("isClipCircle is ",isClipCircle, " isClipSquare is ", isClipSquare);
        } else if (commandBuffer.equals("C")) {
          isClipSquare = ! isClipSquare ;
          if (isClipSquare) {
            isClipCircle = false ;
          }
          println("isClipCircle is ",isClipCircle, " isClipSquare is ", isClipSquare);
        } else if (commandBuffer.equals("x")) {
          isReflectX = ! isReflectX ;
          isReflectZ = false ;
          if (isReflectX) {
            isReflectY = false ;
          }
        } else if (commandBuffer.equals("y")) {
          isReflectY = ! isReflectY ;
          isReflectZ = false ;
          if (isReflectY) {
            isReflectX = false ;
          }
        } else if (commandBuffer.equals("z")) {
          isReflectZ = ! isReflectZ ;
          if (isReflectZ) {
            isReflectX = isReflectY = true ;
          } else {
            isReflectX = isReflectY = false ;
          }
        } else if (commandBuffer.equals("p")) {
          isPainting = ! isPainting ;
          println("IS PAINTING? ", isPainting);
        } else if (commandBuffer.equals("e")) {
          isEchoing = ! isEchoing ;
          if (! isEchoing) {
            echoImage = null ;
          }
          println("IS ECHOING? ", isEchoing);
       }
      } catch (Exception exx) {
        System.err.println("ERROR PARSING COMMAND: " + commandBuffer + ", " + exx.getMessage());
        commandBuffer = "" ;
      }
      commandBuffer = "" ;
    }
  }
}

void zapAll() {
  rotateCanvasDegrees = 0.0; rotateForegroundDegrees = 0 ;
  scaleCanvasAmount = 1.0; scaleForegroundAmount = 1.0 ;
  rotateForegroundDegreesSpeed = 0; scaleForegroundAmountSpeed = 1 ;
  xloc = 0; yloc = 0; xspeed = 0; yspeed = 0 ;
  isPainting = false; isReflectX = false; isReflectY = false; isEchoing = false ;
  isForegroundPImage = true; isBackgroundPImage = true ;
  isForegroundDraw = false; isBackgroundDraw = false ;
  echoImage = null ;
  morphedImage = null ;
  zapMutators();
}

void zapMutators() {
  morphedImage = null ;
  if (task != null) {
    while (! task.isDone()) {
      task.cancel(true);
    }
    task = null ;
  }
  workManager.flushPendingTasks();
  threadMutatorQueue.clear();
}
