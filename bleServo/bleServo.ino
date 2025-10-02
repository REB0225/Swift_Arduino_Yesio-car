#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ESP32Servo.h>

Servo servoLB;
Servo servoLT;
Servo servoRB;
Servo servoRT;
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool sending = false;


#define SERVICE_UUID        "3939acbb-1139-abcd-3939-39390e012345"
#define CHARACTERISTIC_UUID "0e0390e0-39ea-5678-1010-0e0390e03930"


#define LB_Servo 12
#define LT_Servo 14
#define RB_Servo 4
#define RT_Servo 16

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
    }

    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        pServer->startAdvertising();
    }
};

class MyCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic* pCharacteristic) {
        std::string value = std::string(pCharacteristic->getValue().c_str());
        if (value.length() > 0) {
            int LBValue = 0, LTValue = 0, RBValue = 0, RTValue = 0, callValue = 1;

            int firstComma = value.find(",");
            int secondComma = value.find(",", firstComma + 1);
            int thirdComma = value.find(",", secondComma + 1);

            if (firstComma != std::string::npos && secondComma != std::string::npos) {
                LBValue = atoi(value.substr(0, firstComma).c_str());
                LTValue = atoi(value.substr(firstComma + 1, secondComma - firstComma - 1).c_str());
                RBValue = atoi(value.substr(secondComma + 1, thirdComma - secondComma - 1).c_str());
                RTValue = atoi(value.substr(thirdComma + 1).c_str());

                servoLB.write(LBValue);
                servoLT.write(LTValue);
                servoRB.write(RBValue);
                servoRT.write(RTValue);

                String response = String(RTValue);
                pCharacteristic->setValue(response.c_str());
                pCharacteristic->notify();
            }
        }
    }
};

void setup() {
    Serial.begin(115200);

    // Setup PWM for LEDs
    servoLB.attach(LB_Servo);
    servoLT.attach(LT_Servo);
    servoRB.attach(RB_Servo);
    servoRT.attach(RT_Servo);

    BLEDevice::init("MagLev_004");
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    BLEService *pService = pServer->createService(SERVICE_UUID);
    pCharacteristic = pService->createCharacteristic(
                        CHARACTERISTIC_UUID,
                        BLECharacteristic::PROPERTY_READ |
                        BLECharacteristic::PROPERTY_WRITE |
                        BLECharacteristic::PROPERTY_NOTIFY 
                      );

    pCharacteristic->addDescriptor(new BLE2902()); 
    pCharacteristic->setCallbacks(new MyCallbacks());
    pService->start();

    pServer->getAdvertising()->start();
    Serial.println("Waiting for a client connection...");
}

void loop() {
}
