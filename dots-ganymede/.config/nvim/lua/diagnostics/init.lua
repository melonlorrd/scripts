vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    local Float = vim.diagnostic.open_float
    if Float then
      Float(nil, { focus = false })
    end
  end,
})