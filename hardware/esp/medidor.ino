#include <TimeLib.h>
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecureBearSSL.h>
#include <Wire.h>
#include <WiFiClient.h>
#include "ArduinoJson.h"

#define SSID "********"
#define PASSWD "f35f22kc390"
ESP8266WiFiMulti WiFiMulti;

const char fingerprint[] PROGMEM =  "dd e7 6b 0a 78 9f da 46 ab 84 3e d7 f4 02 75 41 76 62 ca d3";
char json[400] = {0};
String host = "script.google.com";
String GAS_ID = "AKfycbzI13KJEJch_4nFqhEZQTbWP_4ZHlmahaKWc3blIk-JQLE5RvhqY8kcFQFBaqQkN6U1wA"; 

////////////////Entrada dos sensores///////////////////////
float tensao = 125.12;
float corrente_s1 = 0;
float calibracao = 0.0146484375;
float sinal = 0;
float sina2 =0;
/////////////////////////////////////////////////////////

StaticJsonDocument<256> doc;

void resultOfGet(String msg){
    memset(json,0,sizeof(json));
    msg.toCharArray(json, 400);
    deserializeJson(doc, json);

    JsonObject ticker = doc["ticker"];
    const char* ticker_high = ticker["high"]; // "33395.00000000"
    const char* ticker_low = ticker["low"]; // "32911.01001000"
    const char* ticker_vol = ticker["vol"]; // "29.80139592"
    const char* ticker_last = ticker["last"]; // "33146.89715000"
    const char* ticker_buy = ticker["buy"]; // "33005.10011000"
    const char* ticker_sell = ticker["sell"]; // "33146.89715000"
    const char* ticker_open = ticker["open"]; // "33094.94851000"
    long ticker_date = ticker["date"]; // 1578889119
    Serial.println(ticker_last);
}

void setup() {
  //1 - Para testar, vamos usar a serial
  Serial.begin(9600);

  //2 - iniciamos a conexão WiFi...
  WiFi.mode(WIFI_STA);
  WiFiMulti.addAP(SSID, PASSWD);

  //3 - acesse arduinojson.org/v6/assistant e passe uma amostra pra calcular a capacidade
  const size_t capacity = JSON_OBJECT_SIZE(1) + JSON_ARRAY_SIZE(8) + 146;
  DynamicJsonDocument doc(capacity);
 
}

void loop() {
 
//////////////Sensores/////////////////
sinal = (analogRead(A0)*calibracao);
delay(1000);
corrente_s1 = sinal;  
/////////////Sensores/////////////////
  
float potencia_s1 = 0;
String circuito_s1 = "circuito01";
float corrente_s2 = (corrente_s1-(corrente_s1*0.32));
float potencia_s2 = 0;
String circuito_s2 = "circuito02";
  
  ///////////////////////Varáveis do ambiente//////////////////////////
  Serial.println("A corrente do medidor 1 é :");           
  Serial.println(corrente_s1);
  delay(2000);
  potencia_s1 = (((corrente_s1*tensao)*592)/1000);  //Kw/10min           
  Serial.println("A corrente do medidor 2 é :");           
  Serial.println(corrente_s2);
  potencia_s2 = (((corrente_s2*tensao)*592)/1000);  //Kw/10min                        
  delay(592000);
  ///////////////////////Fins dos cálculos//////////////////////////////
 //Plotagem
  Serial.println("A potencia do medidor 1 é:");
  Serial.println(potencia_s1);
  delay(2000);
  Serial.println("A potencia do medidor 2 é:");
  Serial.println(potencia_s2);
  delay(2000);
  /// Sobe os dados do circuito 1///////////////////
  Serial.println("loop started...");
        String string_corrente_s1 =  String(corrente_s1); 
        String string_tensao =  String(tensao); 
        String string_potencia_s1 =  String(potencia_s1);
        String string_circuito_s1 = String(circuito_s1);
        String url = "https://" +host + "/macros/s/" + GAS_ID + "/exec?circuito=" + string_circuito_s1 + "&corrente=" + string_corrente_s1 + "&tensao=" + string_tensao+ "&potencia=" + string_potencia_s1;
        Serial.println(url);
       
        if ((WiFiMulti.run() == WL_CONNECTED)){
          std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
          client->setFingerprint(fingerprint);
          Serial.println("connected...");
          //WiFiClient client;

          HTTPClient http;

        //3 - iniciamos a URL alvo, pega a resposta e finaliza a conexão
        if (http.begin(*client,url)){
          Serial.println("http.begin ok");
        }
        int httpCode = http.GET();
        if (httpCode > 0) { //Maior que 0, tem resposta a ser lida
            String payload = http.getString();
            Serial.println(httpCode);
            Serial.println(payload);
            resultOfGet(payload);
        }
        else {
          Serial.println(httpCode);
            Serial.println("Falha na requisição");
        }
        http.end();
        }
/// Sobe os dados do circuito 2///////////////////
delay(1000);
Serial.println("loop started...");
        String string_corrente_s2 =  String(corrente_s2); 
        String string_potencia_s2 =  String(potencia_s2);
        String string_circuito_s2 = String(circuito_s2);
        String url_2 = "https://" +host + "/macros/s/" + GAS_ID + "/exec?circuito=" + string_circuito_s2 + "&corrente=" + string_corrente_s2 + "&tensao=" + string_tensao+ "&potencia=" + string_potencia_s2;
        Serial.println(url_2);
        if ((WiFiMulti.run() == WL_CONNECTED)){
          std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);
          client->setFingerprint(fingerprint);
          Serial.println("connected...");
          //WiFiClient client;

          HTTPClient http;

        //3 - iniciamos a URL alvo, pega a resposta e finaliza a conexão
        if (http.begin(*client,url_2)){
          Serial.println("http.begin ok");
        }
        int httpCode = http.GET();
        if (httpCode > 0) { //Maior que 0, tem resposta a ser lida
            String payload = http.getString();
            Serial.println(httpCode);
            Serial.println(payload);
            resultOfGet(payload);
        }
        else {
          Serial.println(httpCode);
            Serial.println("Falha na requisição");
        }
        http.end();
        }
  }
  
