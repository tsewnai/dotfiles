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

-- >>> omaland managed block >>>
-- Written by Omaland. Safe to hand-edit: Omaland re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
hl.config({
  decoration = {
    border_part_of_window = true,
    inactive_opacity = 0.95,
  },

  group = {
    groupbar = {
      disable_when_only = false,
      font_size = 12,
      gradients = true,
      height = 15,
      indicator_height = 0,
      render_titles = true,
      rounding = 6,
      stacked = false,
    },
  },
})
-- <<< omaland managed block <<<
