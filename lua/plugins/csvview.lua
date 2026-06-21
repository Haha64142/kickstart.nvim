return {
  'hat0uma/csvview.nvim',
  ---@module "csvview"
  ---@type CsvView.Options
  opts = {
    parser = {
      comments = { '#', '//', '--' },
    },
    keymaps = {
      -- Text objects for selecting fields
      textobject_field_inner = { 'if', mode = { 'o', 'x' } },
      textobject_field_outer = { 'af', mode = { 'o', 'x' } },
      -- Excel-like navigation:
      -- Use <Tab> and <S-Tab> to move horizontally between fields.
      -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
      -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
      jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
      jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
    },
  },
  cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  ft = 'csv',
  config = function(_, opts)
    require('csvview').setup(opts)
    local csvview_group = vim.api.nvim_create_augroup('CsvViewEvents', { clear = true })
    local csvview = require 'csvview'
    local jump = require 'csvview.jump'

    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { desc = desc })
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'CsvViewAttach',
      group = csvview_group,
      callback = function(args)
        local bufnr = tonumber(args.data)
        map('<leader>ci', csvview.info, '[C]sv View [I]nfo')
        map('<S-w>', jump.next_field_start, '', { 'n', 'v' })
        map('<S-e>', jump.next_field_end, '', { 'n', 'v' })
        map('<S-b>', jump.prev_field_start, '', { 'n', 'v' })
      end,
    })

    vim.api.nvim_create_autocmd('FileType', {
      group = csvview_group,
      pattern = 'csv',
      callback = function(args)
        csvview.enable(args.buf)
      end,
    })
  end,
  keys = {
    {
      '<leader>tc',
      function()
        vim.cmd 'CsvViewToggle'
      end,
      desc = '[T]oggle [C]sv View',
    },
  },
}
