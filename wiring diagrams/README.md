# USB Cleaner Box - Wiring Diagrams

This directory contains the complete wiring diagrams and schematics for building the USB Cleaner Box hardware.

## Power Options

The USB Cleaner Box can be built with **two different power configurations**:

1. **9V Battery Powered** - Portable, standalone operation
2. **USB Powered** - Direct power from USB port or wall adapter

Choose the configuration that best suits your needs.

---

## Option 1: 9V Battery Powered

This configuration uses a 9V battery for portable operation. Ideal for field use or when AC power is not available.

![9V Battery Powered Wiring Diagram](UCB_Wiring_diagram_9V.png)

### Power Specifications (9V)
- **Input**: 9V battery (alkaline or rechargeable)
- **Regulation**: 5V step-down converter/regulator required
- **Current Draw**: ~500mA typical, 1A peak
- **Battery Life**: 4-6 hours with standard 9V alkaline battery

---

## Option 2: USB Powered

This configuration uses a USB power input (5V). Ideal for desktop/lab use with consistent power.

![USB Powered Wiring Diagram](UCB_Wiring_diagram_USB.png)

### Power Specifications (USB)
- **Input**: 5V DC via USB Micro/Mini connector
- **Current Draw**: ~500mA typical, 1A peak
- **Power Source**: USB wall adapter (5V/2A recommended) or USB port

---

## Bill of Materials (BOM)

### Core Components

| Qty | Component | Description | Notes |
|-----|-----------|-------------|-------|
| 1 | Raspberry Pi Zero W | Main microcontroller | Or Pi Zero 2 W for better performance |
| 1 | 16x2 I2C LCD Display | Character display, I2C interface | I2C address: 0x27 |
| 3 | 5mm LEDs | Status indicators | 1x Green, 1x Orange, 1x Red |
| 3 | 220Ω Resistors | LED current limiting | 1/4W or 1/8W |
| 2 | Tactile Push Buttons | User input (YES/NO) | 6mm x 6mm momentary switches |
| 2 | 10kΩ Resistors | Button pull-up resistors | Optional if using internal pull-ups |
| 1 | Passive Buzzer | Audio feedback | 5V, 12mm diameter |
| 1 | NPN Transistor | Buzzer driver | 2N2222 or equivalent |
| 1 | 1kΩ Resistor | Transistor base resistor | For buzzer control |
| 1 | Diode | Flyback protection | 1N4148 or 1N4001 |

### Power Supply Components

#### For 9V Battery Configuration:
| Qty | Component | Description | Notes |
|-----|-----------|-------------|-------|
| 1 | 9V Battery Connector | Battery snap connector | With leads |
| 1 | 9V Battery | Power source | Alkaline or rechargeable NiMH |
| 1 | 5V Voltage Regulator | Step-down converter | LM7805 or DC-DC buck converter (more efficient) |
| 2 | Capacitors | Input/output filtering | 10µF and 100nF for LM7805 |
| 1 | Power Switch | On/Off control | SPST toggle or slide switch |

#### For USB Powered Configuration:
| Qty | Component | Description | Notes |
|-----|-----------|-------------|-------|
| 1 | USB Connector | Power input | Micro USB or Mini USB |
| 1 | USB Power Cable | 5V power supply | 5V/2A wall adapter recommended |
| 1 | Power Switch | On/Off control (optional) | SPST toggle or slide switch |

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

### Enclosure & Mounting

| Qty | Component | Description | Notes |
|-----|-----------|-------------|-------|
| 1 | Project Box | Enclosure | Recommended: 150x100x50mm |
| 1 | Acrylic/Plexiglass | LCD window | Cut to size, 80x36mm |
| 4 | M2.5 Screws | Pi mounting | 10mm length |
| 4 | M2.5 Standoffs | Pi standoffs | 10mm height |
| 1 | Prototype PCB or Breadboard | Component mounting | Optional, for permanent build |
| - | Jumper Wires | Connections | Male-to-female, various lengths |

### Tools Required

- Soldering iron and solder
- Wire strippers
- Multimeter
- Drill with bits (for enclosure mounting holes)
- Hot glue gun (optional, for securing components)
- Screwdrivers (Phillips and flathead)

---

## Assembly Notes

### General Guidelines

1. **Test Components First**: Verify all components work individually before final assembly
2. **Check Polarity**: LEDs, buzzer, and capacitors are polarized - observe polarity!
3. **Secure Connections**: Use solder for permanent builds, ensure no shorts
4. **Cable Management**: Keep wires organized and away from moving parts
5. **Test Incrementally**: Test after each major component is added

### Power Supply Tips

#### 9V Battery Configuration:
- Use a DC-DC buck converter instead of LM7805 for better efficiency (longer battery life)
- Add a low battery indicator LED if desired
- Consider rechargeable 9V NiMH batteries for cost savings
- Ensure voltage regulator can handle 1A continuous current

#### USB Configuration:
- Use a quality USB power adapter (5V/2A minimum)
- Add a power LED indicator near USB connector
- Consider adding a USB power bank for portability
- Ensure USB cable is rated for at least 2A

### LCD Connection

The LCD uses I2C communication:
- **SDA** (GPIO2/Pin 3) - Data line
- **SCL** (GPIO3/Pin 5) - Clock line
- **VCC** - 5V power
- **GND** - Ground
- **Power Control** (GPIO4/Pin 7) - Controls LCD power via MOSFET/transistor

### LED Wiring

Each LED requires a current-limiting resistor:
- LED Anode (+) → GPIO pin (through transistor/MOSFET if needed)
- LED Cathode (-) → 220Ω resistor → GND

### Button Wiring

Buttons use internal pull-up resistors:
- One terminal → GPIO pin
- Other terminal → GND
- Press button = GPIO goes LOW

### Buzzer Circuit

The buzzer requires a transistor driver:
- GPIO26 → 1kΩ resistor → NPN base
- Buzzer (+) → 5V
- Buzzer (-) → NPN collector
- NPN emitter → GND
- Diode across buzzer (cathode to +5V) for flyback protection

---

## Safety & Precautions

⚠️ **Important Safety Information**:

1. **Power Safety**
   - Never exceed 5V on Raspberry Pi GPIO pins
   - Ensure proper polarity on all components
   - Use appropriate fuses for battery-powered builds
   - Disconnect power before making wiring changes

2. **Electrostatic Discharge (ESD)**
   - Handle Raspberry Pi with ESD precautions
   - Use anti-static wrist strap when possible
   - Avoid touching component pins unnecessarily

3. **Thermal Considerations**
   - Ensure adequate ventilation in enclosure
   - Voltage regulators may require heatsinks
   - Avoid blocking Raspberry Pi ventilation

4. **Testing**
   - Always test with multimeter before connecting to Pi
   - Verify voltage levels at all connection points
   - Check for shorts before powering on

---

## Troubleshooting

### Power Issues

| Problem | Possible Cause | Solution |
|---------|---------------|----------|
| Pi won't boot | Insufficient current | Use higher-rated power supply (2A) |
| Random reboots | Voltage drop | Check connections, use thicker wires |
| Battery drains fast | Inefficient regulator | Use DC-DC buck converter |

### Component Issues

| Problem | Possible Cause | Solution |
|---------|---------------|----------|
| LED won't light | Wrong polarity | Swap LED connections |
| Buzzer silent | No transistor | Add NPN transistor driver |
| LCD blank | No power/wrong I2C | Check GPIO4, verify I2C address |
| Buttons don't respond | Wrong pull-up | Enable internal pull-ups in code |

---

## Design Files

This directory contains:

- `UCB_Wiring_diagram_9V.png` - 9V battery configuration
- `UCB_Wiring_diagram_USB.png` - USB powered configuration
- `UCB_9V_power.fzz` - Fritzing source file (9V)
- `UCB_usb_power.fzz` - Fritzing source file (USB)

**Note**: `.fzz` files can be opened and edited with [Fritzing](https://fritzing.org/)

---

## Recommended Suppliers

### Electronics Components
- [Adafruit](https://www.adafruit.com/)
- [SparkFun](https://www.sparkfun.com/)
- [Pimoroni](https://shop.pimoroni.com/)
- [DigiKey](https://www.digikey.com/)
- [Mouser](https://www.mouser.com/)

### Raspberry Pi
- [Raspberry Pi Official](https://www.raspberrypi.com/)
- [CanaKit](https://www.canakit.com/)
- [Adafruit](https://www.adafruit.com/)

---

## Additional Resources

- [Raspberry Pi GPIO Pinout](https://pinout.xyz/)
- [I2C LCD Tutorial](https://www.circuitbasics.com/raspberry-pi-i2c-lcd-set-up-and-programming/)
- [Fritzing Software](https://fritzing.org/)

---

## License

Hardware designs are open source. Feel free to modify and adapt for your needs.

## Contributing

Found an issue or have an improvement? Please open an issue or submit a pull request!
