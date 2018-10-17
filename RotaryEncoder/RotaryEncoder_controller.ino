/*-------------------------------------------------------------------------------------------------
 * 2-PHOTON POSITION ENCODER CODE
 * ------------------------------------------------------------------------------------------------
 * This code reads the movement of a rotary encoder and translates the angular position into
 * an analog voltage. This code has been written to work with a LPD3806-600BM-G5-24C Rotary encoder
 * and on an Arduino Zero board (in order to have a true AnalogOut without PWM).
 * The code outputs a variable analog signal (10bit DAC on the Arduino Zero) which represents
 * the angular position of the shaft and that resets to 0V every full turn.
 * If you use a rotary encoder with different pulses per revolution (PPR) please change the variable
 * accordingly.
 * Parts of the code labelled as OPTIONAL provide serial communication to plot the angular position
 * through USB and may be used for debugging. Comment these parts for the final build.
 * 
 * Encoder wiring:
 * RED: VCC
 * BLACK: Gnd
 * GREEN: A
 * WHITE: B
 * 
 * Leonardo Lupori - 2018
 */


volatile unsigned int temp, counter = pow(2,31); // This variable will increase or decrease depending on the rotation of encoder
const int outPin = A0;                           // The pin for the output signal. Make sure it has AnalogOutput capabilities without PWM
const int PPR = 600;                             // Pulses Per Revolution. Put here the specific of your rotary encoder of choice
const int pinA = 2;                              // Pin to connect the A channel of the encoder. NOTE, this pin has to support interrupts. Pin 2 on most boards
const int pinB = 3;                              // Pin to connect the B channel of the encoder. Pin 3 on most boards
const int bitDepthDAC = 10;                      // Bit depth of the DAC of the arduino board of your choice. 10 bit on arduino Zero.

   
void setup() {
  // OPTIONAL - Serial Communication
  //--------------------------------
//  Serial.begin (9600);
  //--------------------------------
  
  pinMode(pinA, INPUT_PULLUP);              // internal pullup input pin A 
  pinMode(pinB, INPUT_PULLUP);              // internal pullup input pin B
  analogWriteResolution(bitDepthDAC);       // Allows more than the standard 8 bit DAC on the compatible boards
  //Setting up interrupt
  //A rising pulse from encodenren activated ai0(). AttachInterrupt 0 is DigitalPin nr 2 on moust Arduino.
  attachInterrupt(digitalPinToInterrupt(pinA), ai0, RISING);
}
   
void loop() {
  // OPTIONAL - Send the angular position through serial communication
  //------------------------------------------------------------------
//  if( counter != temp ){
//    Serial.println (counter);
//    temp = counter;
//  }
  //------------------------------------------------------------------
  
  analogWrite(outPin,map(counter%PPR, 0, PPR, 0, pow(2,bitDepthDAC)));
}
   
void ai0() {
  // ai0 is activated if DigitalPin nr 2 is going from LOW to HIGH
  // Check pin 3 to determine the direction
  if(digitalRead(pinB)==LOW) {
    counter++;
  }else{
    counter--;
  }
}
