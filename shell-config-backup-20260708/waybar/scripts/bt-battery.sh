#!/bin/bash
# Shows battery levels for connected Bluetooth peripherals
# Queries BlueZ via D-Bus for device name, connection status, and battery

get_icon() {
  local model="$1"
  local model_lower="${model,,}"
  if [[ "$model_lower" == *"mouse"* || "$model_lower" == *"mx"* || "$model_lower" == *"master"* ]]; then
    echo "󰍽"
  elif [[ "$model_lower" == *"key"* || "$model_lower" == *"keychron"* ]]; then
    echo "󰌌"
  elif [[ "$model_lower" == *"airpod"* || "$model_lower" == *"pod"* || "$model_lower" == *"headphone"* || "$model_lower" == *"headset"* || "$model_lower" == *"buds"* ]]; then
    echo "󰋋"
  else
    echo "󰂱"
  fi
}

get_warning_class() {
  local pct="$1"
  if (( pct <= 10 )); then
    echo "critical"
  elif (( pct <= 20 )); then
    echo "warning"
  fi
}

# Get all BlueZ managed objects in one call
dbus_output=$(dbus-send --system --dest=org.bluez --print-reply \
  / org.freedesktop.DBus.ObjectManager.GetManagedObjects 2>/dev/null)

# Extract device paths (e.g. /org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX)
dev_paths=$(echo "$dbus_output" | grep -oP 'object path "/org/bluez/hci0/dev_[^"/]+"' | grep -oP '"/[^"]+"' | tr -d '"' | sort -u)

devices=()
tooltip_lines=()
worst_class=""

for path in $dev_paths; do
  # Get connection status
  connected=$(dbus-send --system --dest=org.bluez --print-reply \
    "$path" org.freedesktop.DBus.Properties.Get \
    string:"org.bluez.Device1" string:"Connected" 2>/dev/null \
    | grep -oP 'boolean \K\w+')

  [[ "$connected" != "true" ]] && continue

  # Get device name
  name=$(dbus-send --system --dest=org.bluez --print-reply \
    "$path" org.freedesktop.DBus.Properties.Get \
    string:"org.bluez.Device1" string:"Name" 2>/dev/null \
    | grep -oP 'string "\K[^"]+')

  [[ -z "$name" ]] && continue

  icon=$(get_icon "$name")

  # Try to get battery percentage
  pct=$(dbus-send --system --dest=org.bluez --print-reply \
    "$path" org.freedesktop.DBus.Properties.Get \
    string:"org.bluez.Battery1" string:"Percentage" 2>/dev/null \
    | grep -oP 'byte \K\d+')

  if [[ -n "$pct" ]]; then
    devices+=("${icon} ${pct}%")
    tooltip_lines+=("${name}: ${pct}%")
    c=$(get_warning_class "$pct")
    if [[ "$c" == "critical" ]]; then
      worst_class="critical"
    elif [[ "$c" == "warning" && "$worst_class" != "critical" ]]; then
      worst_class="warning"
    fi
  else
    # Connected but no battery info (e.g. AirPods)
    devices+=("${icon}")
    tooltip_lines+=("${name}: connected")
  fi
done

if (( ${#devices[@]} == 0 )); then
  echo '{"text": "", "tooltip": "", "class": "empty"}'
  exit 0
fi

text=$(IFS='  '; echo "${devices[*]}")
tooltip=$(printf '%s\\n' "${tooltip_lines[@]}")
tooltip="${tooltip%\\n}"

echo "{\"text\": \"${text}\", \"tooltip\": \"${tooltip}\", \"class\": \"${worst_class}\"}"
