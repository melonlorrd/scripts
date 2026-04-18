local function get_plugin(name)
  local package = vim.fn.stdpath('config') .. '/pack/plugins/start/' .. name
  return package
end

local function add_plugin(name)
  local package = get_plugin(name)
  if vim.fn.isdirectory(package) == 0 then
    vim.fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/' .. name .. '.git',
      package,
    })
  end
end

local plugins = {
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'nvim-treesitter/nvim-treesitter',
  'EdenEast/nightfox.nvim',
}

for _, plugin in ipairs(plugins) do
  add_plugin(plugin)
end

vim.opt.runtimepath:prepend(vim.fn.stdpath('config') .. '/pack/plugins/start/nvim-treesitter')
vim.opt.runtimepath:prepend(vim.fn.stdpath('config') .. '/pack/plugins/start/EdenEast/nightfox.nvim')
vim.opt.runtimepath:prepend(vim.fn.stdpath('config') .. '/pack/plugins/start/EdenEast/nightfox.nvim/lua')