-- Keyboard + pointer settings.
hl.config({
  input = {
    -- No compose/layout options (cleared from Omarchy's default).
    kb_options = "",

    -- Faster key repeat, longer initial delay.
    repeat_rate = 40,
    repeat_delay = 600,

    -- Start with numlock on.
    numlock_by_default = true,

    touchpad = {
      -- Two-finger click for right-click.
      clickfinger_behavior = true,

      -- Slower, more controllable scrolling.
      scroll_factor = 0.4,
    },
  },
})

-- Faster touchpad scroll in terminals.
o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
