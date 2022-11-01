//#include <Arduino.h>
//#include <IRremoteESP8266.h>
#include <IRsend.h>
#include <IRrecv.h>
//#include <IRac.h>
#include <IRtext.h>
#include <IRutils.h>
#include <WiFi.h>
#include <Preferences.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <PubSubClient.h>

const char *mqtt_server = "192.168.1.97";
//String irCommand="";

WiFiClient espClient;
PubSubClient client(espClient);
void irSend(int irKod);

void reconnect() {
  while (!client.connected()) {

    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {

      Serial.println("connected");

    } else {

      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);

    }
      client.subscribe("topicIrCommand");

  }
}

BLECharacteristic *pCharacteristicRXssid = NULL;
BLECharacteristic *pCharacteristicRXpass = NULL;
BLECharacteristic *pCharacteristicTX = NULL;
bool deviceConnected = false;
bool btmod = false;
String ssidFromDev = "";
String passFromDev = "";

#define SERVICE_UUID            "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID_RXSSID  "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_UUID_RXPASS  "6166d89c-a276-41b1-8a4c-42344560e74c"
#define CHARACTERISTIC_UUID_TX  "f9235d1e-302d-4a10-b0d4-67d4384dc70c"

void setWifiInfo(String ssid, String pass);
class MyCallbacks: public BLECharacteristicCallbacks {
      
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      
      Serial.println("*********");
      
      if (String(String(value[0])+String(value[1])+String(value[2])+String(value[3])) == "SSID"){
        Serial.print("SSID: ");
        if (value.length() > 0) {
        for (int i = 4; i < value.length(); i++){
          Serial.print(value[i]);
          ssidFromDev = ssidFromDev + String(value[i]);
        }
        Serial.println();
        Serial.println("ssidFromDev: "+ ssidFromDev);
        Serial.println("*********");
        }
      }
      if (String(String(value[0])+String(value[1])+String(value[2])+String(value[3])) == "PASS"){
        Serial.print("PASS: ");
        if (value.length() > 0) {
        for (int i = 4; i < value.length(); i++){
          Serial.print(value[i]);
          passFromDev = passFromDev + String(value[i]);
        }
        Serial.println();
        Serial.println("passFromDev: "+ passFromDev);
        Serial.println("*********");
        }
      }

      if (passFromDev != "" && ssidFromDev != ""){
        setWifiInfo(ssidFromDev, passFromDev);
        ESP.restart();
      }

    }
};

class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  };
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};

Preferences preferences;

const uint16_t kCaptureBufferSize = 1024;

#if DECODE_AC
const uint8_t kTimeout = 50;
#else   // DECODE_AC
const uint8_t kTimeout = 15;
#endif  // DECODE_AC


IRsend irsend(18);
const uint16_t kRecvPin = 13;
IRrecv irrecv(kRecvPin, kCaptureBufferSize, kTimeout, true);
decode_results results; 
 
int x2i(char *s) 
{
  int x = 0;
  for(;;) {
    char c = *s;
    if (c >= '0' && c <= '9') {
      x *= 16;
      x += c - '0'; 
    }
    else if (c >= 'A' && c <= 'F') {
      x *= 16;
      x += (c - 'A') + 10; 
    }
    else break;
    s++;
  }
  return x;
}

void callback(char* topic, byte* payload, unsigned int length) {
 
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message:");

  if ((String)topic == "topicIrCommand")
  {
    char irCommand[length];
    for (int i = 0; i < length; i++) {
      //irCommand = irCommand + (char)payload[i];
      irCommand[i] = (char)payload[i];
    }
 //   Serial.println("irCommand: "+ irCommand);


    Serial.println(uint32_t(&payload));
    Serial.println(uint64_t(&payload));
    int code = x2i(irCommand);
    irsend.sendNEC(code,32);

    
//    Serial.println((uint32_t)irCommand);
    
//  irsend.sendNEC((uint32_t)irCommand, 32);
//    irSend((uint16_t)irCommand);
  }

  Serial.println("-----------------------");

}

void setup() {

  
  preferences.begin("SSID", false);
  preferences.begin("SSID_PASS", false);

  //setWifiInfo("Emir","Beyaz");
  String strSSID = preferences.getString("SSID", "");
  String strSSID_PASS = preferences.getString("SSID_PASS","");
  
  int ssid_len = strSSID.length() + 1;
  int pass_len = strSSID_PASS.length() + 1;
  
  char ssid[ssid_len];
  char password[pass_len];

  strSSID.toCharArray(ssid, ssid_len);
  strSSID_PASS.toCharArray(password, pass_len);
  
  irsend.begin();
  
  irrecv.enableIRIn();
  Serial.begin(115200);
  Serial.print("Connecting to ");
  Serial.println(preferences.getString("SSID", ""));

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  
  int i = 0;
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
    Serial.println(ssid);
    Serial.println(password);
    i++;
    if(i > 20){
      WiFi.disconnect(true);
      WiFi.mode(WIFI_OFF);
      btmod = true;
      Serial.println("Starting BLE work!");
      BLEDevice::init("ESP32");
      BLEServer *pServer = BLEDevice::createServer();
      BLEService *pService = pServer->createService(SERVICE_UUID);
    
      
      pCharacteristicRXssid = pService->createCharacteristic(
                                             CHARACTERISTIC_UUID_RXSSID,
                                             BLECharacteristic::PROPERTY_READ |
                                             BLECharacteristic::PROPERTY_WRITE
                                           );
                                           
      pCharacteristicRXpass = pService->createCharacteristic(
                                             CHARACTERISTIC_UUID_RXPASS,
                                             BLECharacteristic::PROPERTY_READ |
                                             BLECharacteristic::PROPERTY_WRITE
                                           );
    
      pCharacteristicTX = pService->createCharacteristic(
                                             CHARACTERISTIC_UUID_TX,
                                             BLECharacteristic::PROPERTY_NOTIFY
                                           );
    
      pCharacteristicTX->addDescriptor(new BLE2902());
      pService->start();
    
      pServer->getAdvertising()->start();
      
      pServer->setCallbacks(new MyServerCallbacks());
      pCharacteristicRXssid->setCallbacks(new MyCallbacks());
      pCharacteristicRXpass->setCallbacks(new MyCallbacks());
      break;
    }
  }
  
  if(WiFi.status() == WL_CONNECTED){
    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP()); 
  
    client.setServer(mqtt_server, 1883);
    client.setCallback(callback);
  }

}

void loop() {
  if(!btmod){
    if (!client.connected()) {
      reconnect();
    }
    client.loop();  
  }else{
    Serial.println("Setting Wifi");
    delay(1000);
  }

  irRecive();


  
}

void irSend(uint16_t irKod){  
  irsend.sendNEC(irKod, 32);
  Serial.print(irKod);
  Serial.println(" ir Kodu Gönderildi.");
}

void irRecive(){
    if (irrecv.decode(&results)) {
      char charTopic[resultToHumanReadableBasic(&results).length()+1];
      resultToHumanReadableBasic(&results).toCharArray(charTopic, resultToHumanReadableBasic(&results).length()+1);
      client.publish("topicIrToFlutter", charTopic);
      Serial.print(resultToHumanReadableBasic(&results));
      serialPrintUint64(results.value, HEX);
    }
}

void setWifiInfo(String ssid, String pass){
  preferences.putString("SSID", ssid);
  preferences.putString("SSID_PASS", pass);
}
