-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Asymmetric outer gaps: top/bottom 5, left/right 10.
    gaps_out = { top = 5, right = 10, bottom = 5, left = 10 },
  },

  decoration = {
    rounding = 10,
    rounding_power = 3,
  },
})
