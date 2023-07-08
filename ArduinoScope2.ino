/* 
 * Arduino Scope 2
 * 4 channel analog oscilloscope
 * Based on project: https://randomnerdtutorials.com/arduino-poor-mans-oscilloscope/
*/

const uint8_t analog_pins[] = {A0, A1, A2, A3};  
 
void setup() {
  Serial.begin(9600); 
}
 
void loop() {
  for(int i = 0; i < 4; i++){ 
    int val = analogRead(analog_pins[i]);                                              
    Serial.write( 0xff ); 
    Serial.write( i );                                                         
    Serial.write( (val >> 8) & 0xff );                                            
    Serial.write( val & 0xff );
  }
}
