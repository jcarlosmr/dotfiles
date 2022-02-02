local action_state = require('telescope.actions.state') -- runtime (plugin) exists somewhere as lua/telescope/actions/state.lua
require('telescope').setup{
  defaults = {
    prompt_prefix = "$ ",
    mappings = {
      i = {
        ['<c-a>'] = function() print(vim.inspect(action_state.get_selected_entry())) end
      }
    }
  }
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('coc')

local mappings = {}

mappings.custom_fuzzy_buf = function() 
  local opt = require('telescope.themes').get_ivy({
    sorting_strategy='ascending',
    prompt_position='top'
  })
  require('telescope.builtin').current_buffer_fuzzy_find(opt)
end
return mappings
