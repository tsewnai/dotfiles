return {
  desc = "Open browser when server prints 'Now listening on:'",
  constructor = function()
    return {
      on_output_lines = function(self, task, lines)
        for _, line in ipairs(lines) do
          local url = line:match("Now listening on: (https?://%S+)")
          if url then
            local scalar_url = url .. "/scalar/v1"
            vim.notify("Opening " .. scalar_url, vim.log.levels.INFO)
            vim.fn.jobstart({ "xdg-open", scalar_url }, { detach = true })
          end
        end
      end,
    }
  end,
}
