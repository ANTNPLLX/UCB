# USB Cleaner Box - Bill of materials 

This directory contains the list of material needed for building the USB Cleaner Box hardware.

## Bill of Materials (BOM)

### Core Components

| Qty | Component | Description | Notes | Avg Price |
|-----|-----------|-------------|-------|-----------|
| 1 | Raspberry Pi 3 | Main microcontroller | Or Pi Zero 2 W for better performance | 47.00€ |
| 1 | 16x2 I2C LCD Display | Character display, I2C interface | I2C address: 0x27 | 9.00€ |
| 3 | 5mm LEDs | Status indicators | 1x Green, 1x Orange, 1x Red | 0.10€ |
| 3 | 220Ω Resistors | LED current limiting | 1/4W or 1/8W | 0.05€ |
| 2 | Metal Push Buttons | User input (YES/NO) | 12mm x 12mm momentary switches | 3.00€ |
| 1 | Passive Buzzer | Audio feedback | 5V, 12mm diameter | 0.50€ |

**Core Components Subtotal: 62.95€**


### Power Supply Components

#### For 9V Battery Configuration:
| Qty | Component | Description | Notes | Avg Price |
|-----|-----------|-------------|-------|-----------|
| 1 | 9V Battery Connector | Battery snap connector | With leads | 0.50€ |
| 1 | 9V Battery | Power source | Alkaline or rechargeable NiMH | 3.00€ |
| 1 | 5V Voltage Regulator | Step-down converter |  DC-DC buck converter (more efficient) | 1.50€ |
| 1 | Metal Power Switch | On/Off control | SPST toggle or slide switch | 4.00€ |

**9V Battery Configuration Subtotal: 9.00€**

#### For USB Powered Configuration:
| Qty | Component | Description | Notes | Avg Price |
|-----|-----------|-------------|-------|-----------|
| 1 | USB Connector | Power input | Micro USB or Mini USB | 1.50€ |
| 1 | USB Power Cable | 5V power supply | 5V/2A wall adapter recommended | 10.00€ |
| 1 | Power Switch | On/Off control (optional) | SPST toggle or slide switch | 4.00€ |

**USB Configuration Subtotal: 15.50€**

### Enclosure & Mounting

| Qty | Component | Description | Notes | Avg Price |
|-----|-----------|-------------|-------|-----------|
| 1 | Project Box | Enclosure | Recommended: 150x100x50mm | 30.00€ |
| 4 | M2.5 Screws | Pi mounting | 10mm length | 0.50€ |
| 4 | M2.5 Standoffs | Pi standoffs | 10mm height | 0.40€ |
| 1 | Prototype PCB or Breadboard | Component mounting | Optional, for permanent build | 3.00€ |
| 1 | Jumper Wires Set | Connections | Male-to-female, various lengths | 5.00€ |

**Enclosure & Mounting Subtotal: 38.9€**


---

## Total Cost Summary

### 9V Battery Powered Configuration:
- Core Components: **62.95€**
- Power Supply (9V): **9.00€**
- Enclosure & Mounting: **38.9€**

**Total: ~110.85€** (excluding tools)

### USB Powered Configuration:
- Core Components: **62.95€**
- Power Supply (USB): **15.50€**
- Enclosure & Mounting: **38.9€**

**Total: ~117.35€** (excluding tools)

> *Prices are approximate averages in Euros and may vary by supplier, location, and time. Bulk purchases or existing component inventory can reduce costs significantly.*

---

## License

Hardware designs are open source. Feel free to modify and adapt for your needs.

## Contributing

Found an issue or have an improvement? Please open an issue or submit a pull request!
