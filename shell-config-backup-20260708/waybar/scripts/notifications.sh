#!/usr/bin/env bash

count=$(makoctl list 2>/dev/null | grep -c '^Notification' 2>/dev/null || true)
count=${count:-0}

# Build history tooltip (last 10 entries, most recent first)
history=$(makoctl history 2>/dev/null | grep '^Notification' | sed 's/^Notification [0-9]*: /• /' | head -10)

if [[ "$count" -gt 0 ]]; then
  text="󰂚 $count"
  css_class="has-notifications"
  if [[ -n "$history" ]]; then
    tooltip="$count active — click to dismiss all"$'\n\n'"Recent:"$'\n'"$history"
  else
    tooltip="$count notification(s) — click to dismiss all"
  fi
else
  text="󰂚"
  css_class="empty"
  if [[ -n "$history" ]]; then
    tooltip="Recent:"$'\n'"$history"
  else
    tooltip="No notifications"
  fi
fi

jq -cn \
  --arg text "$text" \
  --arg tooltip "$tooltip" \
  --arg class "$css_class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
