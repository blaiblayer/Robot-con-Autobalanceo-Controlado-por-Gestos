#include "BluetoothSerial.h"

#define CHANNEL 0
#define FREQ 1000
#define RESOLUTION 15
#define PWMPIN 12
#define PINCW 14
#define PINCCW 27

#define CHANNEL2 1
// freq y resol igual para ambos motores
#define PWMPIN2 33
#define PINCW2 26
#define PINCCW2 25

BluetoothSerial SerialBT; // Se crea un objeto de tipo BluetoothSerial

void setup()
{
  SerialBT.begin("ESP32MotoresDC"); // Se inicializa el objeto Bluetooth con el nombre

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
}
 
//=======================================================================
//                    Main Program Loop
//=======================================================================
void loop() {
  unsigned char duty,duty2,NBytesLeidos;
  unsigned int Ton,Ton2;
  unsigned char Buf_Rx[2];

  if (SerialBT.available()>1) // Se comprueba si se ha recibido más de 1 byte por Bluetooth (2)
  {
    NBytesLeidos=SerialBT.readBytes(Buf_Rx,2); // Se almacena en Buf_Rx los 2 bytes
                                         // recibidos. NBytesLeidos toma el valor 2
    duty=Buf_Rx[0];
    duty2=Buf_Rx[1];   

    // Motor 1
    if (duty&0x80) // Si el bit más significativo del dato recibido está a '1'
    {
      digitalWrite(PINCW,HIGH); // Se configura 
      digitalWrite(PINCCW,LOW); //       el sentido de giro CW
    }
    else          // // Si el bit más significativo del dato recibido está a '0'
    {
      digitalWrite(PINCW,LOW);   // Se configura 
      digitalWrite(PINCCW,HIGH); //       el sentido de giro CCW
    }

     // Motor 2
    if (duty2&0x80) // Si el bit más significativo del dato recibido está a '1'
    {
      digitalWrite(PINCW2,HIGH); // Se configura 
      digitalWrite(PINCCW2,LOW); //       el sentido de giro CW
    }
    else          // // Si el bit más significativo del dato recibido está a '0'
    {
      digitalWrite(PINCW2,LOW);   // Se configura 
      digitalWrite(PINCCW2,HIGH); //       el sentido de giro CCW
    }
    
    Ton=(duty&0x7F)*32767/100; // Se establece el nº de cuentas de Ton a partir de 
    ledcWrite(CHANNEL,Ton);    // los 7 bits menos significativos del byte recibido

    Ton2=(duty2&0x7F)*32767/100; // Se establece el nº de cuentas de Ton a partir de 
    ledcWrite(CHANNEL2,Ton2);    // los 7 bits menos significativos del byte recibido

    // delay(3000);
    // ledcWrite(CHANNEL,Ton);
    // ledcWrite(CHANNEL2,Ton2);
  } 
}
