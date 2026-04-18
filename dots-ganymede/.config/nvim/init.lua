vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.updatetime = 300
vim.opt.timeoutlen = 400

vim.opt.termguicolors = true

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

require('plugins.init')
require('treesitter')
require('lsp')
require('diagnostics')
require('keymaps.init')

vim.opt.background = 'dark'
require('nightfox').setup({
  options = {
    transparent = true,
  }
})
require('nightfox').load({ name = 'carbonfox' })

if #vim.api.nvim_list_uis() > 0 and vim.fn.argc() == 0 then
  vim.cmd('enew')
  vim.bo.bufhidden = 'delete'
  vim.cmd('echo "Welcome! Open a file to edit."')
end
