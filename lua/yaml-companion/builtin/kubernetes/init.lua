local M = {}

local api = vim.api
local resources = require("yaml-companion.builtin.kubernetes.resources")
local uri = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main"

-- https://github.com/redhat-developer/yaml-language-server/blob/main/src/languageservice/utils/schemaUrls.ts#L18
local schema = {
  name = "Kubernetes",
  uri = "kubernetes",
}

M.match = function(bufnr)
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local group, version, kind
  local apiRegex = vim.regex("^apiVersion:\\s\\+")
  local kindRegex = vim.regex("^kind:\\s\\+")

  for _, line in ipairs(lines) do
    local ok, col = apiRegex:match_str(line)
    if ok then
      local parts = vim.split(line:sub(col + 1), "/")
      if #parts == 2 then
        group = parts[1]
        version = parts[2]
      end
    end
    ok, col = kindRegex:match_str(line)
    if ok then
      kind = line:sub(col + 1)
    end

    if vim.list_contains(resources, kind) then
      return schema
    end
  end

  if vim.list_contains({ group, version, kind }, nil) then
    return {
      name = "Kubernetes CRD",
      uri = uri .. "/" .. group:lower() .. "/" .. kind:lower() .. "_" .. version:lower() .. ".json",
    }
  end
end

M.handles = function()
  return { schema }
end

return M
