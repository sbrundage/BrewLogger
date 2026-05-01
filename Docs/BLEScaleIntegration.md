# BLE Scale Integration

Documentation for the Coffee Scale (ESP32) ↔ BrewLogger integration.

---

## Hardware

The scale is an ESP32 microcontroller with:
- **HX711** load cell amplifier — measures weight
- **BME280** sensor — measures ambient temperature and humidity
- Broadcasts over **Bluetooth Low Energy (BLE)**

The ESP32 firmware lives at: `~/code/github/BLEScale-esp32/src/main.cpp`

---

## Sample Rate (10 Hz)

The HX711 chip defaults to **10 SPS (samples per second)** at the hardware level.
The firmware reads it and broadcasts a BLE notification every **100ms**:

```cpp
#define WEIGHT_INTERVAL_MS 100
```

```
1000ms ÷ 100ms per reading = 10 readings/second = 10 Hz
```

Temperature and humidity update at **1 Hz** (every 1000ms) — they change slowly.

To increase to 80 Hz: tie the HX711 RATE pin HIGH. Not currently needed.

---

## BLE Services & Characteristics

### Environmental Sensing Service (standard GATT)
UUID: `181A`

| Characteristic | UUID   | Type   | Encoding              | Example            |
|----------------|--------|--------|-----------------------|--------------------|
| Temperature    | `2A6E` | sint16 | value × 100 (°F)      | 75.63°F → `7563`   |
| Humidity       | `2A6F` | uint16 | value × 100 (% RH)    | 55.20% → `5520`    |

Uses standard GATT UUIDs so BLE scanner apps (nRF Connect, LightBlue) label them automatically.

### Scale Service (custom)
UUID: `12345678-1234-1234-1234-1234567890AB`

| Characteristic | UUID               | Type   | Encoding              | Example           |
|----------------|--------------------|--------|-----------------------|-------------------|
| Weight         | `...90AC`          | sint16 | value × 10 (grams)    | 154.3g → `1543`   |
| Tare           | `...90AD`          | write  | any byte triggers tare | `0x01` → tare    |

Weight is **signed** (`sint16`) to handle small negative readings near zero after tare.
Range: –3276.7g to +3276.7g.

---

## Data Flow (iOS side)

```
ESP32 hardware
  └─ BLE NOTIFY every 100ms (weight) / 1000ms (temp, humidity)
       │
       ▼
CBCentralManager / CBPeripheral   (CoreBluetooth)
  └─ peripheral(_:didUpdateValueFor:)  in BLEScaleManager
       │  decodes raw Int16/UInt16 bytes
       │  assembles ScaleReading(weight:temperature:humidity:)
       │
       ▼
AsyncStream<ScaleReading>         (multicast — one stream per subscriber)
  └─ readingsContinuations[id].yield(reading)
       │
       ▼
BleScaleViewModel.processReading()
  ├─ guards: isArmed == true
  ├─ detects brew start (weight > 0.2g)
  ├─ appends WeightSample(elapsed:weight:) to samples[]
  ├─ hard stop at 35s elapsed
  └─ detectFinalYield() — watches rate of change for shot-done signal
       │
       ▼
BleLiveScaleView (SwiftUI Charts)
  └─ re-renders on samples[] change → live chart update
```

---

## Connection Lifecycle

```
App launch
  └─ BleScaleConnectionManager.startConnecting()
       └─ BLEScaleManager.connect()
            └─ CBCentralManager init → centralManagerDidUpdateState()
                 └─ .poweredOn → scanForPeripherals()
                      └─ didDiscover "Coffee Scale" → connect()
                           └─ didConnect → discoverServices()
                                └─ discoverCharacteristics()
                                     └─ setNotifyValue(true) for each NOTIFY char
                                          └─ readings stream is now live
```

Auto-reconnect: if the peripheral disconnects, `didDisconnectPeripheral` immediately resumes scanning.

---

## AsyncStream: Why Multicast

Swift's `AsyncStream` terminates when its consuming `Task` is cancelled. A single stored
stream instance is therefore single-use — once the task ends (e.g. modal dismissed), the
stream is dead and future `yield()` calls are silently dropped.

**Solution:** `readings` and `stateChanges` are computed properties. Each call returns a
fresh `AsyncStream` with its own continuation, stored in a dictionary keyed by UUID.
When the subscriber's task is cancelled, `onTermination` removes its entry.

This allows the modal to be dismissed and re-opened any number of times.

---

## isArmed Gate

`BleScaleViewModel.isArmed` is a boolean gate that delays recording until after tare.

1. Scale broadcasts readings continuously — including pre-tare weight
2. User taps "Tare" → tare command sent to ESP32 via BLE write
3. 400ms delay (ESP32 needs ~100ms to process tare + margin)
4. `isArmed = true` → `processReading` begins appending to `samples[]`

Without the delay, the brief pre-tare weight spike would appear at the start of the chart.

The delay task uses `try await Task.sleep(...)` (not `try?`) so that if the modal is
dismissed during the 400ms window, cancellation propagates correctly and `isArmed`
is never set.

---

## Shot Timing

Timing starts at **first drop of coffee** (weight crosses 0.2g threshold).

This is **extraction time** — the variable most relevant to grind adjustment.
"Machine-on" timing (includes pre-infusion) is a future consideration; it would be
stored as a separate `preInfusionSeconds` field per brew, not tied to the chart.

---

## Wire Encoding Example

Weight characteristic raw read for 23.4g:

```
Raw value:  234  (Int16, little-endian: 0xEA 0x00)
Decode:     Int16(0x00EA) = 234
Scale:      234 / 10.0 = 23.4g
```

Temperature characteristic raw read for 72.15°F:

```
Raw value:  7215  (Int16, little-endian: 0x2F 0x1C)
Decode:     Int16(0x1C2F) = 7215
Scale:      7215 / 100.0 = 72.15°F
```
