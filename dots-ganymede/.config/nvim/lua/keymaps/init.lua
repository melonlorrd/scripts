vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<leader><leader>', '<c-^>', { desc = 'Switch to alternate file' })

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result centering' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result centering' })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down half page' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up half page' })

vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Write buffer' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Close buffer' })

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste from clipboard before' })

vim.keymap.set('n', '<C-w>v', ':vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<C-w>s', ':split<CR>', { desc = 'Horizontal split' })

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })