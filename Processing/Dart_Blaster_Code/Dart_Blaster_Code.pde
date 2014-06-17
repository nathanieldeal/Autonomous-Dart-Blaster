import codeanticode.gsvideo.*; 
import monclubelec.javacvPro.*; 
import java.awt.*; 
import processing.serial.*;

Rectangle[] faceRect; 
GSCapture cam; 
PImage img;
OpenCV opencv; 

int sketchWidth=640; 
int sketchHeight=480;
int fps=30; 
int targetCenterX;
int targetCenterY;
int xpos=90;
int ypos=90;

int threshold = 50;
int thresholdLeft;
int thresholdRight;
int thresholdUp;
int thresholdDown;
int moveIncrement = 3;

int circleWidth = 3;
int circleExpand = 20;

boolean isFiring = false;
boolean isFound = false;

Serial port;

void setup()
{ 
  size (sketchWidth, sketchHeight); 
  frameRate(fps); 
  
  //cam = new Capture(this, cameras[18]);
  cam = new GSCapture(this, sketchWidth, sketchHeight, "1"); 
  cam.start(); 
  
  opencv = new OpenCV(this); 
  opencv.allocate(sketchWidth, sketchHeight); 
  
  //Comment or delete the platform you're NOT on.
  //opencv.cascade("FRONTALFACE_ALT", true);    //Windows location
  opencv.cascade("/usr/local/share/OpenCV/haarcascades/","haarcascade_frontalface_alt.xml");    //Mac location
  
  port = new Serial(this, Serial.list()[5], 57600); 
  port.write(90 + "a");
  delay(1000);              
}

void  draw() 
{
  if (cam.available() == true) 
  { 
    cam.read();  
    img = cam.get(); 
    opencv.copy(img);
    image(img,0,0);
    faceRect = opencv.detect(false);
    
    if(isFiring) 
    {
      tint(255, 0, 0);
    }
    else
    {
      noTint();
    }
    
    stroke(255,255,255);
    strokeWeight(1);
    thresholdLeft = (sketchWidth/2)-threshold;
    thresholdRight =  (sketchWidth/2)+threshold;
    thresholdUp = (sketchHeight/2)-threshold;
    thresholdDown =  (sketchHeight/2)+threshold;
    
    stroke(255,255,255, 128);
    strokeWeight(1);
    line(thresholdLeft, 0, thresholdLeft, sketchHeight); //left side
    line(thresholdRight, 0, thresholdRight, sketchHeight); //right side
  }

  if((faceRect != null) && (faceRect.length != 0))
  {
    
    isFound = true;
    //Get center point of identified target
    targetCenterX = faceRect[0].x + (faceRect[0].width/2);
    targetCenterY = faceRect[0].y + (faceRect[0].height/2);    
        
    //Draw circle around face
    noFill();
    strokeWeight(circleWidth);
    stroke(255,255,255);
    ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand, faceRect[0].height+circleExpand);
    
    //Handle rotation
    if(targetCenterX < thresholdLeft)
    {
        xpos = xpos-moveIncrement;
        //delay(50);
    }
    if(targetCenterX > thresholdRight)
    {
        xpos = xpos+moveIncrement;
        //delay(50);
    }
    
    //Handle pan
    if(targetCenterY < thresholdUp)
    {
        ypos = ypos-moveIncrement;
        //delay(50);
    }
    if(targetCenterY > thresholdDown)
    {
        ypos = ypos+moveIncrement;
        //delay(50);
    }
    
    
    
    //Fire
    if((targetCenterX >= thresholdLeft) && (targetCenterX <= thresholdRight))
    {
      port.write("f");
      isFiring = true;
      noFill();
      strokeWeight(2);
      stroke(255,255,255, 128);
      ellipse(targetCenterX, targetCenterY, faceRect[0].width+circleExpand+15, faceRect[0].height+circleExpand+ 15);

    }
    else
    {
      isFiring = false;
    }
  }
  
  port.write(xpos + "a");
  port.write(ypos + "b");
  delay(20);

}
