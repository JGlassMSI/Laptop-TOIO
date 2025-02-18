import oscP5.*;
import netP5.*;


//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection
int nCubes = 5;
int cubesPerHost = 12;
int maxMotorSpeed = 115;
int xOffset;
int yOffset;

// lemniscate
int CENTER_X = 250;
int CENTER_Y = 250;
int PERIOD = 8000;
boolean run = true;
long start_time = 0;

int a = 125;  
float V_SCALE = 1.25;
float[] last_x;
float[] last_y;

//// Instruction for Windows Users  (Feb 2. 2025) ////
// 1. Enable WindowsMode and set nCubes to the exact number of toio you are connecting.
// 2. Run Processing Code FIRST, Then Run the Rust Code. After running the Rust Code, you should place the toio on the toio mat, then Processing should start showing the toio position.
// 3. When you re-run the processing code, make sure to stop the rust code and toios to be disconnected (switch to Bluetooth stand-by mode [blue LED blinking]). If toios are taking time to disconnect, you can optionally turn off the toio and turn back on using the power button.
// Optional: If the toio behavior is werid consider dropping the framerate (e.g. change from 30 to 10)
// 
boolean WindowsMode = false; //When you enable this, it will check for connection with toio via Rust first, before starting void loop()

int framerate = 30;

int[] matDimension = {45, 45, 455, 455};

//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;

//we'll keep the cubes here
Cube[] cubes;

void settings() {
  size(1000, 1000);
}


void setup() {
  //launch OSC sercer
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);

  //create cubes
  cubes = new Cube[nCubes];
  last_x = new float[nCubes];
  last_y = new float[nCubes];
  for (int i = 0; i< nCubes; ++i) {
    cubes[i] = new Cube(i);
    last_x[i] = 0;
    last_y[i] = 0;
  }

  xOffset = matDimension[0] - 45;
  yOffset = matDimension[1] - 45;

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  frameRate(framerate);
  if(WindowsMode){
  check_connection();
  }
}

long last = 0;
int index = 0;

int triangle_positions[][] = { {200, 200}, {300, 200}, {250, 286} };
int square_positions[][] = {{200, 200}, {200, 300}, {300, 300}, {300, 200}};
int positions[][] = square_positions;
int num_positions = 4;
int counter = 0;

void draw() {
  //START TEMPLATE/DEBUG VIEW  
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  //draw the "mat"
  fill(255);
  rect(matDimension[0] - xOffset, matDimension[1] - yOffset, matDimension[2] - matDimension[0], matDimension[3] - matDimension[1]);

  //draw the cubes
  pushMatrix();
  translate(xOffset, yOffset);   
  
  for (int i = 0; i < nCubes; i++) {
    cubes[i].checkActive(now);
    
    if (cubes[i].isActive) {
      pushMatrix();
      translate(cubes[i].x, cubes[i].y);
      fill(0);
      textSize(15); 
      text(i, 0, -20);
      noFill();
      rotate(cubes[i].theta * PI/180);
      rect(-10, -10, 20, 20);
      line(0, 0, 20, 0);
      popMatrix();
    }
  }
  popMatrix();
  //END TEMPLATE/DEBUG VIEW
  

  if (false){
    println(cubes[0].x, ",", cubes[0].y);;
  }
  else if (false){ //tiangle
    //INSERT YOUR CODE HERE!
    if (now - last > 3000){  
        for (int i = 0; i < nCubes; i++){
          cubes[i].target(positions[(i + index) % num_positions][0], positions[(i + index) % num_positions][1], 0);
        }
       index = (index + 1) % num_positions;
       last = now;
    }
  }
  else if (false){ //square
    if (now - last > 1){
      counter+= 1;
      if (counter > 450) counter = 80;
      last = now;
    }
    for (int i = 0; i < nCubes; i++){
      if (cubes[i].x  == counter){
          cubes[i].midi(100, round((400-cubes[i].y)/10)+40, 255); 
          println(i, ":", cubes[i].x);
      }  
    }
  }
  else if (true && run){
    //if (now - last > 200){
      float global_t = 2 * PI * ((now % PERIOD) * 1.0) / PERIOD;
      
      for (int i = 0; i < nCubes; i++){
        float t = (global_t + (2 * PI) * ((i * 1.0) / nCubes)) % (2 * PI);
        float x = (a * cos(t)) / (1 + (sin(t) * sin(t)));
        float y = V_SCALE * (a * sin(t) * cos(t)) / (1 + (sin(t)*sin(t)));
        
        float theta = 180 + atan2((y-last_y[i]), (x - last_x[i])) * 180 / PI ;
        //cubes[i].target(CENTER_X + round(x), CENTER_Y + round(y), int(theta));
        cubes[i].velocityTarget(CENTER_X + round(x), CENTER_Y + round(y));
        println(i, ": ", round(x), ", ", round(y), ", ", theta);
        
        last_x[i] = x;
        last_y[i] = y;
        
      }
      
      last = now;
    //}
  }

}
