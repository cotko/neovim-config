local fn = {}

fn.nice_method_names = function(methods)
  local nice_names = {}
  for method, enabled in pairs(methods) do
    if enabled then
      table.insert(
        nice_names,
        method
          :gsub('NULL_LS_', '')
          :gsub('_', ' ')
          :lower()
      )
    end
  end

  return nice_names
end


fn.get_lsp_sources = function()

  local has_nls, nls = pcall(require, 'null-ls.sources')
  local list = {}
  local clients = vim.lsp.get_clients()

  for _, client in ipairs(clients) do
    if has_nls and client.name == 'null-ls' then
      goto continue
    end

    table.insert(list, {
      name = client.name,
      is_active = FNS.util.wrap_bufnr(function(bufnr)
        return client.attached_buffers[bufnr] and true or false
      end),
      toggle = FNS.util.wrap_bufnr(function(bufnr)
        if client.attached_buffers[bufnr] then
          vim.lsp.buf_detach_client(bufnr, client.id)
          vim.lsp.util.buf_clear_references(bufnr)
        else
          vim.lsp.buf_attach_client(bufnr, client.id)
        end
      end)
    })

    ::continue::
  end

  if has_nls then
    local children = {}
    local child_names = {}
    local sources = nls.get({})
    table.insert(list, {
      name = 'null-ls',
      children = children,
      toggle = FNS.util.wrap_bufnr(function(bufnr)
        nls.toggle({})
      end)
    })

    for _, source in pairs(sources) do
      local child = nil
      if not child_names[source.name] then
        child = {
          methods = vim.tbl_deep_extend(
            'force',
            {},
            fn.nice_method_names(source.methods)
          ),
          is_active = FNS.util.wrap_bufnr(function(bufnr)
            return nls.is_available(
              source,
              FNS.util.get_buf_ft(bufnr)
            )
          end),
          toggle = FNS.util.wrap_bufnr(function(bufnr)
            nls.toggle(source.name)
          end)
        }
        table.insert(children, child)
      else
        child = child_names[source.name]
        child.methods = vim.list_extend(
          child.methods,
          fn.nice_method_names(source.methods)
        )
      end

      local methods = vim.fn.join(child.methods, ', ')
      child.name = source.name .. ' (' .. methods .. ')'
      child_names[source.name] = child
    end
  end

  return list
end

return fn
