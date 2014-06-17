#include <Servo.h>

Servo servo1; //rotation
Servo servo2; //pan

int time;
int flywheelPin = 8;
int pusherPin = 9;
int wait = 500; // how long to hold the trigger
boolean isFiring = false;

void setup() {
  servo1.attach(4);
  servo2.attach(7);
  
  pinMode(flywheelPin, OUTPUT);
  pinMode(pusherPin, OUTPUT);

  Serial.begin(57600);
  servo1.write(90);
  servo2.write(70);
  
}

void loop() {
  static int v = 0;
  
  if(Serial.available() >= 0) {
        
    char ch = Serial.read();
    //Serial.println(ch);
    
    switch(ch) { 
    
      case '0'...'9':
      v = v * 10 + ch - '0';
      break;
        
      case 'a':
      servo1.write(v);
      //Serial.println(v);
      v = 0;
      break;
      
      case 'b':
      //servo2.write(v);
      //Serial.println(v);
      v = 0;
      break;
      
      case 'f':
        if(isFiring == false) {
          time = millis(); //save current time value
          isFiring == true;
          digitalWrite(pusherPin, HIGH); 
       
        }
      break;
    }
  }
    // check if stop firing
    if(millis() - time >= wait) {
      digitalWrite(pusherPin, LOW);
      isFiring == false; 
    }
  
}

