-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- Longer wait before key repeat kicks in (default: 250).
    repeat_delay = 600,
  },
})

-- MX Master 3S wheel scrolls too fast at libinput's default rate.
hl.device({
  name = "logitech-usb-receiver-mouse",
  scroll_factor = 0.6,
})
