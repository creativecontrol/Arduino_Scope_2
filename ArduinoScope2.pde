/*
 * Oscilloscope
 * Gives a visual rendering of analog pin 0-4 in realtime.
 *
 * Updated to 4 analog values by Thadeus Frazier-Reed 2023
 * t@creativecontrol.cc
 * 
 * to be used with arduino code
 *
 * -----------------------------------------
 * // Arduino Scope 2 - 4 channel analog oscilloscope
 *
 * const uint8_t analog_pins[] = {A0, A1, A2, A3};  
 *
 * void setup() {
 *   Serial.begin(9600); 
 *   
 * }
 *
 * void loop() {
 *  for(int i = 0; i < 4; i++){ 
 *   int val = analogRead(analog_pins[i]);                                              
 *   Serial.write( 0xff ); 
 *   Serial.write( i );                                                         
 *   Serial.write( (val >> 8) & 0xff );                                            
 *   Serial.write( val & 0xff );
 *  }
 * }
 * 
 * -------------------------------------------
 * Modified from code originally by Sofian Audry
 *
 * This project is part of Accrochages
 * See http://accrochages.drone.ws
 * 
 * (c) 2008 Sofian Audry (info@sofianaudry.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 
import processing.serial.*;
 
Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[][] values = {{}, {}, {}, {}};
float zoom;
int squish = 25;
color colors[] = {#FFFFFF, #4ad7ed, #d4f542, #e342f5 };
 
void setup() 
{
  size(1280, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, Serial.list()[0], 9600);
  port.buffer(4);
  values[0] = new int[width];
  values[1] = new int[width];
  values[2] = new int[width];
  values[3] = new int[width];
  zoom = 1.0f;
  smooth();
}
 
int getY(int val) {
  float highest_value = 1023.0f;
  return (int)(height - ((val / highest_value) * (height - squish*2))) - squish;
}
 
void serialEvent(Serial p) {
  try {
    int address = -1;
    int value = -1;
    while (p.available() >= 4) {
      if (p.read() == 0xff) {
        address = p.read();
        value = (p.read() << 8) | (p.read());
      }
    }
    if (address != -1 && value != -1) {
      pushValue(address, value);
    }
  }
  catch(RuntimeException e) {
    e.printStackTrace();
  }
  
}
 
void pushValue(int address, int value) {
  for (int i=0; i<width-1; i++)
    values[address][i] = values[address][i+1];
  values[address][width-1] = value;
}
 
void drawLines() {
  for(int analog = 0; analog< values.length; analog++) {
    stroke(colors[analog]);
    
    int displayWidth = (int) (width / zoom);
    
    int k = values[analog].length - displayWidth;
    
    int x0 = 0;
    int y0 = getY(values[analog][k]);
    for (int i=1; i<displayWidth; i++) {
      k++;
      int x1 = (int) (i * (width-1) / (displayWidth-1));
      int y1 = getY(values[analog][k]);
      line(x0, y0, x1, y1);
      x0 = x1;
      y0 = y1;
    }
  }
}
 
void drawGrid() {
  stroke(255, 0, 0);
  line(0, height/2, width, height/2);
  // max
  line(0, squish , width, squish);
  // min
  line(0, height-squish , width, height-squish);
}
 
void keyReleased() {
  switch (key) {
    case '+':
      zoom *= 2.0f;
      println(zoom);
      if ( (int) (width / zoom) <= 1 )
        zoom /= 2.0f;
      break;
    case '-':
      zoom /= 2.0f;
      if (zoom < 1.0f)
        zoom *= 2.0f;
      break;
  }
}
 
void draw()
{
  background(0);
  drawGrid();
  drawLines();
}
