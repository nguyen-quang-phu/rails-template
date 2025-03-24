return {
	{
		"neovim/nvim-lspconfig",
		---@class PluginLspOpts
		opts = {
			servers = {
				ruby_lsp = {
					enabled = true,
					mason = false,
					cmd = { "bundle", "exec", "ruby-lsp" },
				},
				rubocop = {
					enabled = true,
					mason = false,
					cmd = { "bundle", "exec", "rubocop", "--lsp" },
				},
			},
		},
	},
}
