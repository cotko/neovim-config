require('typescript-tools').setup({
  settings = {
     -- https://github.com/microsoft/TypeScript/blob/v5.0.4/src/server/protocol.ts#L3439
    tsserver_file_preferences = {
      includeInlayParameterNameHints = "all",
      includeCompletionsForModuleExports = true,
      quotePreference = 'single',
      includeCompletionsForImportStatements = true,
      provideRefactorNotApplicableReason = true,
      includePackageJsonAutoImports = true,
    },
    -- https://github.com/microsoft/TypeScript/blob/v5.0.4/src/server/protocol.ts#L3418
    tsserver_format_options = {
      allowIncompleteCompletions = false,
      allowRenameOfImportPath = true,
      semicolons = false,
    }
  }
})
