#include <analogWrite.h>
#include <MPU6050_tockn.h>
#include <Wire.h>
#include "math.h"

#define CHANNEL 0
#define FREQ 1000
#define RESOLUTION 15

#define PWMPIN 12
#define PINCW 14
#define PINCCW 27

#define CHANNEL2 1
#define PWMPIN2 33
#define PINCW2 26
#define PINCCW2 25



// a calcular
#define Kp 90 
#define Kd 0
#define Ki  0
#define sampleTime  0.005  //timer a 5ms
#define targetAngle 0

MPU6050 mpu6050(Wire);


volatile int motorPower;
volatile float currentAngle, prevAngle = 0, error, prevError = 0, errorSum = 0;

volatile int interruptCounter; // volatile para usarla en varias funciones y se actualice constantemente

hw_timer_t * timer = NULL; //tipo de variable hw_timer_t, *timer coge el valor contenido en la direccion pointed by timer
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED; //tipo de variable portMUX_TYPE para sincronizar el loop y el ISR

// Interrupt Service Routine (ISR)
void IRAM_ATTR onTimer() {  //IRAM_ATTR attribute para que se compile en IRAM

  portENTER_CRITICAL_ISR(&timerMux); //parametro: direccion de timerMux
  interruptCounter++; //lo incrementa para que en el loop reconozcan la interrupcion
  portEXIT_CRITICAL_ISR(&timerMux); //entra y sale de la seccion critica

}


void setup() {
  
  Wire.begin();

  // Motor 1
  pinMode(PINCW,OUTPUT); // Se configura el pin que activa el giro CW como salida
  pinMode(PINCCW,OUTPUT); // Se configura el pin que activa el giro CCW como salida
  digitalWrite(PINCW,HIGH); // Se configura inicialmente 
  digitalWrite(PINCCW,LOW); //                    el giro CW
  ledcSetup(CHANNEL, FREQ, RESOLUTION); // Se configura el canal 0 con una frec de 1kHz y res. de 15 bits
  ledcAttachPin(PWMPIN,CHANNEL); // Se asocia el canal PWM 0 con el pin 12

  // Motor 2
  pinMode(PINCW2,OUTPUT); // Se configura el pin que activa el giro CW como salida
  pinMode(PINCCW2,OUTPUT); // Se configura el pin que activa el giro CCW como salida
  digitalWrite(PINCW2,HIGH); // Se configura inicialmente 
  digitalWrite(PINCCW2,LOW); //                    el giro CW
  ledcSetup(CHANNEL2, FREQ, RESOLUTION); // Se configura el canal 1 con una frec de 1kHz y res. de 15 bits
  ledcAttachPin(PWMPIN2,CHANNEL2); // Se asocia el canal PWM 0 con el pin 26

  // inicializa mpu y offsets
  mpu6050.begin();
  // comentar una de las siguientes
   //mpu6050.calcGyroOffsets(true);
   mpu6050.setGyroOffsets(-1.62, -1.59, 1.96);

  timer = timerBegin(0, 8000, true);  //inicia el timer 0 (de 0 a 3),
  // 8000=valor del prescalar, true = conteo hacia arriba)
  // freqESP32=80 MHz, dividing by 8000 -> signal of 10.000 Hz freq that will
  // increment the timer counter 10.000 times per second
  // si lo invertimos, el counter se incrementara cada 0.0001 s

  timerAttachInterrupt(timer, &onTimer, true);  //funcion  que se ejecuta cuando se geenera elinterruptor
  // & indica la direccion de la funcion onTimer
  // true= interruptor de tipo edge (se genera al intercambiar el estado)
  // false= interruptor tipo level (se activa con un determinado estado)

  timerAlarmWrite(timer, 50, true);  //especifica el valor de counter para que se active el interrupt
  // true = counter will reload al generar el interruptor para repetirse periodicamente
  // queremos interruptor de 5ms  (con un prescaler de 8000)

  timerAlarmEnable(timer); //enable the timer
}

void loop() {
  mpu6050.update();
  // set motor power after constraining it
  motorPower = constrain(motorPower, -100 , 100);
  setMotors(motorPower, motorPower);

  if (interruptCounter > 0) {

    portENTER_CRITICAL(&timerMux); //argument=address de la variable global portMUX_TYPE (timerMux)
    interruptCounter--; //decrementar para ver que se vuelva a reconocer el siguiente interrupt
    portEXIT_CRITICAL(&timerMux);

    //angle of inclination
    currentAngle = mpu6050.getAngleX();
    //error and sum of errors
    error = currentAngle - targetAngle;
    errorSum = errorSum + error;
    errorSum = constrain(errorSum, -300, 300);
    // output from P,I and D values
    motorPower = Kp * (error) + Ki * (errorSum) * sampleTime - Kd * (currentAngle - prevAngle) / sampleTime;
    prevAngle = currentAngle;
  }
}


void setMotors(int leftMotorSpeed, int rightMotorSpeed) {
  unsigned int Ton,Ton2;
  if (leftMotorSpeed >= 0) {
      digitalWrite(PINCW,HIGH); // Se configura 
      digitalWrite(PINCCW,LOW); //       el sentido de giro CW    
  }
  else {
      digitalWrite(PINCW,LOW);   // Se configura 
      digitalWrite(PINCCW,HIGH); //       el sentido de giro CCW    
  }
  if (rightMotorSpeed >= 0) {
      digitalWrite(PINCW2,HIGH); // Se configura 
      digitalWrite(PINCCW2,LOW); //       el sentido de giro CW      
  }
  else {
      digitalWrite(PINCW2,LOW);   // Se configura 
      digitalWrite(PINCCW2,HIGH); //       el sentido de giro CCW   
  }
  Ton=(motorPower)*32767/100; // Se establece el nº de cuentas de Ton a partir de 
 ledcWrite(CHANNEL,Ton);    // los 7 bits menos significativos del byte recibido

  Ton2=(motorPower)*32767/100; // Se establece el nº de cuentas de Ton a partir de 
 ledcWrite(CHANNEL2,Ton2);    // los 7 bits menos significativos del byte recibido
}
