abstract class PImageMutator implements Callable<PImage> {
  public final List<PImage> images ;
  public volatile PImage morphedImage = null ;
  public PImageMutator(List<PImage> images, PImage morphedImage) {
    this.images = images ;
    this.morphedImage = morphedImage ;
  }
  void setMorphedImage(PImage replacement) {
    this.morphedImage = replacement ;
  }
  public PImage call() {
    // A derived class call() can call here to certify morphedImage != null ;
    if (morphedImage == null && images.size() > 0) {
      morphedImage = images.get(0).copy();
    }
    return morphedImage ;
  }
}

class PImageMutatorWorkerThread implements Runnable {
  final LinkedBlockingQueue<FutureTask<PImage>> mutators
    = new LinkedBlockingQueue<FutureTask<PImage>>();
  void scheduleMutator(FutureTask<PImage> mutator) {
    boolean worked = mutators.offer(mutator);
    if (! worked) {
      System.err.println("scheduleMutator failed to enqueue!");
      System.err.flush();
    }
  }
  void run() {
    while (true) {
      try {
        FutureTask<PImage> task = mutators.take();
        task.run();  // Run this task in this worker thread.
      } catch (InterruptedException iex) {
        // println("INFO, Mutator InterruptedException");
        System.err.flush();
        workManager.flushPendingTasks();
      }
    }
  }
}

// Following ported from noThingJuly2021
volatile int etchLowerThreshold = -1,  etchUpperThreshold = -1 ;
import java.io.FileNotFoundException ;
class FileReaderActiveClass implements java.lang.Runnable {
  private final List<String> filenames = new CopyOnWriteArrayList<String>();
  private volatile int fileindex = -1 ;
  private final String sp = sketchPath("");

  public FileReaderActiveClass() throws FileNotFoundException {
    Scanner fileNameReader = new Scanner(new File(sp + "/CSC220Fall2023PaintingAssn5.txt"));
    while (fileNameReader.hasNextLine()) {
      String fname = fileNameReader.nextLine().trim();
      if (fname.length() > 0 && ! (fname.startsWith("#") || fname.startsWith("//"))) {
        filenames.add(fname);
      }
    }
    fileNameReader.close();
    if (filenames.size() > 0) {
      fileindex = 0 ;
    }
  }
  public void run() {
    final float screenAspect = float(width) / float(height);
    while (true) {
      synchronized(this) {
        try {
          while (imageQueue.size() >= imageLimit) {
            //println("DEBUG ENTER WAIT");
            wait();
            //println("DEBUG LEAVE WAIT");
          }
          String nm = filenames.get(fileindex);
          //println("DEBUG ABOUT TO READ", nm);
          PImage thing = loadImage(sp + "/" + nm) ;
          float thingAspect = float(thing.width) / float(thing.height);
          // println("DEBUG 1 screenAspect ", screenAspect, " thingAspect ", thingAspect);
          if (screenAspect > thingAspect) {
            // println("DEBUG 2 screenAspect ", screenAspect, " thingAspect ", thingAspect);
            // Use height of screen and reduced width on thing.
            // int thingwd = round(thing.width*float(thing.height)/float(height));
            // thing.resize(thingwd, height);
            float multiplier = float(height) / float(thing.height);
            thing.resize(round(thing.width*multiplier),height);
            // println("DEBUG 3 W ", round(thing.width*multiplier), " H " , height, " R ", thing.width*multiplier / height);
            // thing.resize(round(thing.width*thingAspect/screenAspect),height);
            // thing.resize(round(thing.width*screenAspect/thingAspect),height);
          } else if (screenAspect < thingAspect) {
            float multiplier = float(width) / float(thing.width);
            thing.resize(width, round(thing.height*multiplier));
            // int thinght = round(thing.height*float(width)/float(thing.width));
            // thing.resize(width, thinght);
            // thing.resize(width, round(thing.height*screenAspect/thingAspect));
            // thing.resize(width, round(thing.height*thingAspect/screenAspect));
          } else {
            thing.resize(width, height);  // DEBUG
          }
          PImage thingWithAlpha = createImage(thing.width, thing.height, ARGB);
          thing.loadPixels();
          thingWithAlpha.loadPixels();
          System.arraycopy(thing.pixels, 0, thingWithAlpha.pixels, 0, thingWithAlpha.pixels.length);
          thing = thingWithAlpha ;
          /* LEAVE SQUARING TO THE STUDENT / IMAGE
          int useWidth = min(thing.width, thing.height);
          // Carve out center square only.
          int left = (thing.width - useWidth) / 2 ;
          int top = (thing.height - useWidth) / 2 ;
          for (int col = 0 ; col < thing.width ; col++) {
            for (int row = 0 ; row < thing.height ; row++) {
              if (col < left || col > (thing.width-left)
                  || row < top || row > (thing.height-top)) {
                int pix = row * thing.width + col ;
                thing.pixels[pix] = 0 ;
              }
            }
          }
          */
          if (etchLowerThreshold > -1 && etchUpperThreshold > -1
              && etchLowerThreshold <= etchUpperThreshold) {
            thing = etchBrightnessRange(thing, etchLowerThreshold, etchUpperThreshold);
          }
          thing.updatePixels();
          imageQueue.add(thing);
          fileindex = (fileindex+1) % filenames.size() ;
          // println("DEBUG THREAD RECVD ", nm);
        } catch (InterruptedException iex) {
          println("InterruptedException: " + iex.getMessage());
        } 
        catch (Exception xxx) {
          println("Image File Reading Exception on '" + filenames.get(fileindex)
            + "': " + xxx.getMessage());
          exit();
          fileindex = (fileindex+1) % filenames.size() ;
        }
      }
    }
  }
  public synchronized void triggerLoadImage(int advance) {
    // println("DEBUG TRIGGER SENT! ", advance);
    advance = abs(advance);
    // advance of 0 when resizing imageQueue
    if (advance > 0) {
      if (advance <= imageLimit) {
        while (advance > 0 && imageQueue.size() > 0) {
          imageQueue.remove(0);
          advance-- ;
        }
      } else {
        imageQueue.clear();
      }
    }
    //if (advance > 0) {
      fileindex = (fileindex+advance/*-1+filenames.size()*/) // +filenames.size()-imageLimit)
        % filenames.size() ;
          // The -imageLimit compensates for over-shoot.
    //} else {
    //  // step back to one that was being displayed.
    //  fileindex = (fileindex+filenames.size()-1)
    //    % filenames.size() ;
    //}
    notifyAll();
    
  }
}

PImage etchBrightnessRange(PImage original, int etchLowerThreshold, int etchUpperThreshold) {
  PImage result = original.copy();
  if (etchLowerThreshold > -1 && etchUpperThreshold > -1
      && etchLowerThreshold <= etchUpperThreshold) {
    PImage graybee = createImage(result.width, result.height, ARGB);
    graybee.loadPixels();
    result.loadPixels();
    System.arraycopy(result.pixels, 0, graybee.pixels, 0, result.pixels.length);
    result.updatePixels();
    graybee.updatePixels();
    graybee.filter(GRAY);
    graybee.loadPixels();
    for (int i = 0 ; i < result.pixels.length ; i++) {
      int p = graybee.pixels[i] & 0x0ff ;
      if (p >= etchLowerThreshold && p <= etchUpperThreshold) {
        graybee.pixels[i] = 0 ;
      }
    }
    result.mask(graybee);
  }
  return result ;
}
    
