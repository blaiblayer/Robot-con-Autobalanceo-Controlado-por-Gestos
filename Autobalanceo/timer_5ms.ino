volatile int interruptCounter; // volatile para usarla en varias funciones y se actualice constantemente
int totalInterruptCounter; //para contar el numero de interrupciones

hw_timer_t * timer = NULL; //tipo de variable hw_timer_t, *timer coge el valor contenido en la direccion pointed by timer
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED; //tipo de variable portMUX_TYPE para sincronizar el loop y el ISR

// Interrupt Service Routine (ISR)
void IRAM_ATTR onTimer() {  //IRAM_ATTR attribute para que se compile en IRAM
   
  portENTER_CRITICAL_ISR(&timerMux); //parametro: direccion de timerMux
  interruptCounter++; //lo incrementa para que en el loop reconozcan la interrupcion
  portEXIT_CRITICAL_ISR(&timerMux); //entra y sale de la seccion critica
}

 
void setup() {
 
  Serial.begin(115200);
 
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
 
  if (interruptCounter > 0) {
 
    portENTER_CRITICAL(&timerMux); //argument=address de la variable global portMUX_TYPE (timerMux)
    interruptCounter--; //decrementar para ver que se ha reconocido el interrupt
    portEXIT_CRITICAL(&timerMux);
 
    totalInterruptCounter++; // numero de interrupciones totales
    
    if (totalInterruptCounter%200==0) {
      Serial.print("Total seconds: ");
      Serial.println(totalInterruptCounter/200);
    }
 
  }
}
