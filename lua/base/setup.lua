pcall(function() vim.loader.enable() end)

vim.filetype.add({
	extension = {
		json = 'jsonc',
		ejs = 'html',
		mts = 'typescript',
		mjs = 'javascript',
    adoc = 'asciidoc',
	},
	filename = {
		['.eslintrc'] = 'json',
	},
})
