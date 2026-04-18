require('nvim-treesitter').setup({
  ensure_installed = { 'lua', 'typescript', 'go', 'javascript', 'tsx', 'json', 'yaml', 'markdown' },
  highlight = { enable = true },
  indent = { enable = true },
})