# mqtt-broker

A self-hosted **Eclipse Mosquitto 2.x** MQTT broker running on AWS EC2 (t3.micro), deployable from any network. Built for ESP32 fleets and any MQTT client.

## Architecture

```
ESP32 / any client
        │
        ▼
  Elastic IP (static)
        │
   EC2 t3.micro
   Ubuntu 22.04
   Docker → eclipse-mosquitto:2
        │
   ┌────┴────────────┐
 :1883            :8080
 MQTT plain    MQTT WebSocket
```

## Ports

| Port | Protocol       | Use case                        |
|------|----------------|---------------------------------|
| 1883 | MQTT           | ESP32, any native MQTT client   |
| 8080 | MQTT WebSocket | Browsers, Node-RED, dashboards  |

## Connecting from ESP32 (Arduino / PlatformIO)

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

const char* mqtt_server   = "<YOUR_ELASTIC_IP>";
const int   mqtt_port     = 1883;
const char* mqtt_user     = "opsagent";
const char* mqtt_password = "<YOUR_MQTT_PASSWORD>";

WiFiClient   espClient;
PubSubClient client(espClient);

void setup() {
  WiFi.begin("<SSID>", "<WIFI_PASSWORD>");
  while (WiFi.status() != WL_CONNECTED) delay(500);

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void reconnect() {
  while (!client.connected()) {
    if (client.connect("esp32-device-1", mqtt_user, mqtt_password)) {
      client.subscribe("home/sensors/#");
    } else {
      delay(5000);
    }
  }
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // Publish sensor data
  client.publish("home/sensors/temp", "23.5");
}

void callback(char* topic, byte* payload, unsigned int length) {
  // Handle incoming messages
}
```

> Replace `<YOUR_ELASTIC_IP>` with the Elastic IP shown after deploy, and `<YOUR_MQTT_PASSWORD>` with the value you set for the `MQTT_PASSWORD` secret.

## Credentials

Authentication is **required** — anonymous connections are rejected.

| Field    | Value                             |
|----------|-----------------------------------|
| Username | `opsagent`                        |
| Password | The `MQTT_PASSWORD` pipeline secret |

### Adding more users

SSH into the instance and run:

```bash
docker exec mosquitto mosquitto_passwd /mosquitto/config/passwd <new_username>
docker restart mosquitto
```

## Cost

| Resource    | Cost                                      |
|-------------|-------------------------------------------|
| EC2 t3.micro | ~$8/mo (free for 12 mo on AWS Free Tier) |
| Elastic IP  | Free while attached to running instance   |
| Egress      | ~$0.09/GB after 100 GB/mo free            |

## Optional enhancements

- **TLS on port 8883** — add Let's Encrypt cert via certbot on the host
- **Node-RED dashboard** — connect via WebSocket on port 8080
- **More MQTT users** — managed via `mosquitto_passwd` on the container
- **CloudWatch logs** — forward Docker logs to CloudWatch for monitoring
