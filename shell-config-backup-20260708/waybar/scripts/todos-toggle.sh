#!/usr/bin/env bash

TODO_FILE="$HOME/Documents/vault/todos.md"

if [[ ! -f "$TODO_FILE" ]]; then
    printf '# Todos\n\n- [ ] My first todo\n' > "$TODO_FILE"
fi

# Get pending todos with their line numbers (grep -n produces "linenum:- [ ] text")
mapfile -t pending_raw < <(grep -n '^- \[ \]' "$TODO_FILE" 2>/dev/null)

# Extract just the todo text for display
display_items=()
for item in "${pending_raw[@]}"; do
    display_items+=("${item#*- \[ \] }")
done

# Prompt hints at both actions
if [[ ${#display_items[@]} -eq 0 ]]; then
    prompt="All done! Type a new todo to add it"
else
    prompt="Select to check off  |  type new to add"
fi

# wofi dmenu: show existing pending todos; user can also type something new
selected=$(printf '%s\n' "${display_items[@]}" | wofi \
    --dmenu \
    --prompt "$prompt" \
    --lines "${#display_items[@]}" \
    --width 450 \
    --insensitive \
    --hide-scroll)

[[ -z "$selected" ]] && exit 0

# Check if the selection matches an existing pending todo (exact match)
found=false
for i in "${!display_items[@]}"; do
    if [[ "${display_items[$i]}" == "$selected" ]]; then
        found=true
        line_num="${pending_raw[$i]%%:*}"
        # Mark as done by replacing [ ] with [x]
        sed -i "${line_num}s/^- \[ \] /- [x] /" "$TODO_FILE"
        break
    fi
done

# If no match, treat as a new todo
if [[ "$found" == "false" ]]; then
    echo "- [ ] $selected" >> "$TODO_FILE"
fi

# Signal waybar to refresh this widget immediately (signal 11 = SIGRTMIN+11)
pkill -RTMIN+11 waybar

# Sync to GitHub in the background (don't block waybar)
VAULT="$HOME/Documents/vault"
git -C "$VAULT" add todos.md && \
  git -C "$VAULT" commit -m "todos: quick update" && \
  git -C "$VAULT" push &
