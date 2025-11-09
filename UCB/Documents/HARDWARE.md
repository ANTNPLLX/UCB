# Hardware Guide

Complete hardware documentation for building the USB Cleaner Box.

## Wiring Diagrams

Detailed wiring diagrams with two power configuration options are available in:

📁 **[wiring diagrams/README.md](../../wiring%20diagrams/README.md)**

This includes:
- 9V battery powered configuration
- USB powered configuration
- Complete Bill of Materials (BOM) with pricing
- GPIO pin assignments
- Assembly instructions
- Safety guidelines

---

## Quick Reference

### GPIO Pin Assignments

| Component | GPIO Pin | BCM Number | Physical Pin |
|-----------|----------|------------|--------------|
| Green LED | GPIO16 | 16 | Pin 36 |
| Orange LED | GPIO20 | 20 | Pin 38 |
| Red LED | GPIO21 | 21 | Pin 40 |
| Left Button (NO) | GPIO23 | 23 | Pin 16 |
| Right Button (YES) | GPIO24 | 24 | Pin 18 |
| Buzzer | GPIO26 | 26 | Pin 37 |
| LCD Power Control | GPIO4 | 4 | Pin 7 |
| LCD SDA (I2C) | GPIO2 | 2 | Pin 3 |
| LCD SCL (I2C) | GPIO3 | 3 | Pin 5 |

---

## Component Specifications

### Raspberry Pi
- **Model**: Pi 3/4 or Pi Zero 2 W
- **Power**: 5V @ 2A minimum
- **OS**: Raspberry Pi OS (Raspbian)

### LCD Display
- **Type**: 16x2 character LCD
- **Interface**: I2C
- **I2C Address**: 0x27 (default)
- **Backlight**: Controlled via I2C
- **Power Control**: GPIO4 via transistor/MOSFET

### LEDs
- **Type**: 5mm standard LEDs
- **Colors**: Green, Orange (Amber), Red
- **Forward Voltage**: ~2.0-2.2V
- **Current**: ~20mA
- **Resistors**: 220-470Ω current limiting

### Buttons
- **Type**: Tactile momentary push buttons
- **Size**: 6mm x 6mm (or larger)
- **Configuration**: Active LOW (pulled up internally)
- **Debouncing**: Handled in software

### Buzzer
- **Type**: Passive piezo buzzer
- **Voltage**: 5V
- **Driver**: NPN transistor required
- **Frequency Range**: 200Hz - 5KHz

---

## Power Requirements

### Total Power Consumption

| State | Current Draw | Power @ 5V |
|-------|--------------|------------|
| Idle (waiting) | ~150mA | ~0.75W |
| Active (scanning) | ~400-500mA | ~2.0-2.5W |
| Peak (all LEDs + sound) | ~700mA | ~3.5W |

### Recommended Power Supplies

#### Option 1: 9V Battery
- **Type**: Alkaline or NiMH rechargeable
- **Capacity**: 500-600mAh (alkaline)
- **Runtime**: 4-6 hours typical use
- **Regulator**: 5V DC-DC buck converter (recommended)
  - OR: 7805 linear regulator (less efficient)

#### Option 2: USB Power
- **Input**: 5V DC via USB connector
- **Current**: 2A minimum (2.5A recommended)
- **Source**: USB wall adapter or power bank

---

## Assembly Tips

### LED Installation

1. **Check Polarity**
   - Long leg = Anode (+)
   - Short leg = Cathode (-)
   - Flat edge = Cathode side

2. **Resistor Calculation**
   - Formula: R = (Vsupply - Vled) / Iled
   - Example: (3.3V - 2.0V) / 0.020A = 65Ω
   - Use 220Ω for safety margin

3. **Wiring**
   - Anode → Resistor → GPIO pin
   - Cathode → Ground (GND)

### Button Installation

1. **Wiring**
   - One terminal → GPIO pin
   - Other terminal → Ground (GND)
   - Internal pull-up enabled in code

2. **Debouncing**
   - Handled in software
   - No external capacitors needed

### LCD I2C Connection

1. **Connections**
   ```
   LCD VCC → 5V (via GPIO4 control)
   LCD GND → Ground
   LCD SDA → GPIO2 (Pin 3)
   LCD SCL → GPIO3 (Pin 5)
   ```

2. **Power Control Circuit**
   - GPIO4 → 1kΩ resistor → MOSFET gate
   - MOSFET source → GND
   - MOSFET drain → LCD GND
   - LCD VCC → 5V direct

### Buzzer Circuit

1. **Transistor Driver**
   ```
   GPIO26 → 1kΩ resistor → NPN base
   Buzzer (+) → 5V
   Buzzer (-) → NPN collector
   NPN emitter → GND
   Flyback diode across buzzer (cathode to 5V)
   ```

2. **Component Values**
   - Base resistor: 1kΩ
   - Transistor: 2N2222, BC547, or similar
   - Diode: 1N4148 or 1N4001

---

## Enclosure Design

### Recommended Dimensions
- **Box**: 150mm x 100mm x 50mm
- **Material**: ABS plastic or acrylic

### Cutouts Required

1. **LCD Window**
   - Size: 80mm x 36mm
   - Position: Top face, centered

2. **Buttons**
   - Size: 6mm holes
   - Position: Front face, spaced 40mm apart
   - Labels: "NO" and "YES"

3. **LEDs**
   - Size: 5mm holes
   - Position: Top face, in row
   - Spacing: 15-20mm apart
   - Order: Green, Orange, Red

4. **Power**
   - USB connector: 10mm x 6mm (side panel)
   - OR Battery compartment: Rear panel
   - Power switch: Side panel

5. **USB Port Access**
   - Cutout for Raspberry Pi USB ports
   - Position: Side panel

---

## Testing Procedures

### Pre-Power Tests

1. **Visual Inspection**
   - Check all solder joints
   - Verify no shorts between traces
   - Confirm component polarities

2. **Continuity Tests**
   - Test GND connections
   - Verify power rail continuity
   - Check GPIO connections

3. **Resistance Tests**
   - Measure LED resistor values
   - Check button pull-ups (if external)

### Power-On Tests

1. **Power Supply**
   - Measure 5V rail voltage
   - Check for voltage drops
   - Monitor current draw

2. **Component Tests**
   - LCD backlight turns on
   - LEDs light when GPIO set HIGH
   - Buttons register when pressed
   - Buzzer sounds when driven

### System Tests

1. **I2C Communication**
   ```bash
   sudo i2cdetect -y 1
   ```
   Should show address 0x27

2. **GPIO Test Script**
   Test each component individually

3. **Full Application Test**
   Run main application and verify all functions

---

## Troubleshooting Hardware

### LCD Issues

| Problem | Check | Solution |
|---------|-------|----------|
| Blank display | Power | Verify GPIO4 is HIGH, check 5V |
| No backlight | I2C connection | Check SDA/SCL wiring |
| Random characters | I2C address | Verify address is 0x27 |
| Flickering | Poor connection | Re-solder I2C connections |

### LED Issues

| Problem | Check | Solution |
|---------|-------|----------|
| LED doesn't light | Polarity | Swap LED connections |
| LED too dim | Resistor | Use lower value resistor |
| LED too bright | Resistor | Use higher value resistor |
| LED burns out | No resistor | Always use current-limiting resistor |

### Button Issues

| Problem | Check | Solution |
|---------|-------|----------|
| No response | Wiring | Check GPIO and GND connections |
| Bouncing | Software | Increase debounce delay in code |
| Stuck press | Hardware | Replace button |

### Buzzer Issues

| Problem | Check | Solution |
|---------|-------|----------|
| No sound | Driver circuit | Verify transistor connections |
| Weak sound | Power | Check 5V supply, use active buzzer |
| Continuous beep | GPIO stuck | Check software, verify transistor |

### Power Issues

| Problem | Check | Solution |
|---------|-------|----------|
| Won't power on | Voltage | Measure 5V at Pi, check regulator |
| Random reboots | Current | Use higher-rated power supply |
| Battery drains fast | Efficiency | Use DC-DC converter instead of 7805 |

---

## Modifications & Upgrades

### Optional Enhancements

1. **Status LED**
   - Add power indicator LED
   - Use GPIO with current-limiting resistor

2. **External Antenna**
   - For better WiFi (if using wireless)
   - Connect to Pi Zero W antenna pads

3. **Cooling**
   - Add small heatsink to voltage regulator
   - Optional fan for extended use

4. **Battery Level Indicator**
   - Add voltage divider to ADC
   - Monitor battery voltage

5. **OLED Display Upgrade**
   - Replace 16x2 LCD with 128x64 OLED
   - More display options, same I2C interface

---

## Safety Considerations

### Electrical Safety

⚠️ **Warnings**:
- Never exceed 5V on GPIO pins
- Use proper current-limiting resistors
- Ensure correct polarity on all components
- Fuse the power supply (recommended)

### ESD Protection

- Use anti-static wrist strap during assembly
- Store components in anti-static bags
- Avoid touching component pins

### Thermal Safety

- Ensure adequate ventilation
- Don't block airflow around Pi
- Add heatsink to voltage regulator if warm
- Monitor temperatures during extended use

---

## Maintenance

### Regular Checks

- Inspect solder joints for cracks
- Clean dust from enclosure
- Check battery voltage (if battery powered)
- Tighten loose connections
- Verify all LEDs working

### Cleaning

- Power off before cleaning
- Use dry cloth for exterior
- Compressed air for dust removal
- Avoid liquid cleaners near electronics

---

## Resources

### Datasheets
- [Raspberry Pi GPIO](https://pinout.xyz/)
- [16x2 LCD I2C Module](https://www.handsontec.com/dataspecs/module/I2C_1602_LCD.pdf)
- [2N2222 Transistor](https://www.onsemi.com/pdf/datasheet/p2n2222a-d.pdf)

### Tools
- [Fritzing](https://fritzing.org/) - Circuit design software
- [GPIO Reference](https://pinout.xyz/) - Pin reference

### Calculators
- [LED Resistor Calculator](https://www.digikey.com/en/resources/conversion-calculators/conversion-calculator-led-series-resistor)
- [Ohm's Law Calculator](https://www.calculator.net/ohms-law-calculator.html)

---

For complete wiring diagrams with BOM and pricing, see **[wiring diagrams/README.md](../../wiring%20diagrams/README.md)**.
