#!/usr/bin/env bash

TODO_FILE="$HOME/Documents/vault/todos.md"

# Create file if missing
if [[ ! -f "$TODO_FILE" ]]; then
    printf '# Todos\n\n- [ ] My first todo\n' > "$TODO_FILE"
fi

pending=$(grep -c '^- \[ \]' "$TODO_FILE" 2>/dev/null || true)
pending=${pending:-0}

if [[ "$pending" -eq 0 ]]; then
    text="󰄳"
    css_class="done"
else
    text="󰄱 $pending"
    css_class="pending"
fi

# Pending todos for tooltip (up to 10 items)
tooltip_items=$(grep '^- \[ \]' "$TODO_FILE" 2>/dev/null | head -10 | sed 's/^- \[ \] /• /')

if [[ -z "$tooltip_items" ]]; then
    tooltip_text="All done! ✓\nLeft-click to add  •  Right-click to edit file"
else
    tooltip_text="${tooltip_items}"$'\n\n'"Left-click to toggle/add  •  Right-click to edit file"
fi

jq -cn \
    --arg text "$text" \
    --arg tooltip "$tooltip_text" \
    --arg class "$css_class" \
    '{text: $text, tooltip: $tooltip, class: $class}'
