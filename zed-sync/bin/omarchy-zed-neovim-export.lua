-- 2026-11-11 11:30: solicitud: exportar el resaltado de neovim para traducirlo a zed.
local syntax_groups = {
  attribute = { "@lsp.type.decorator", "@lsp.type.annotation", "@annotation", "@attribute", "TSAttribute" },
  boolean = { "@boolean", "TSBoolean", "Boolean" },
  comment = { "@comment", "TSComment", "Comment" }, ["comment.doc"] = { "@comment.documentation", "@comment", "Comment" },
  ["constant.builtin"] = { "@constant.builtin", "TSConstBuiltin", "Constant" },
  constant = { "@constant", "TSConstant", "Constant" }, constructor = { "@constructor", "TSConstructor", "Type" },
  embedded = { "@embedded" }, emphasis = { "@markup.italic" }, ["emphasis.strong"] = { "@markup.strong" },
  enum = { "@type", "Type" }, ["function"] = { "@function", "TSFunction", "Function" }, hint = { "@hint" },
  keyword = { "@keyword", "TSKeyword", "Keyword" }, label = { "@label", "Label" },
  link_text = { "@markup.link.label", "Underlined" }, link_uri = { "@markup.link.url", "Underlined" },
  number = { "@number", "TSNumber", "Number" }, operator = { "@operator", "TSOperator", "Operator" },
  predictive = { "@predictive" }, preproc = { "@preproc", "PreProc" }, primary = { "@primary" },
  property = { "@property", "TSProperty", "Identifier" }, punctuation = { "@punctuation", "TSPunctDelimiter", "Delimiter" },
  ["punctuation.bracket"] = { "@punctuation.bracket", "TSPunctBracket", "Delimiter" },
  ["punctuation.delimiter"] = { "@punctuation.delimiter", "TSPunctDelimiter", "Delimiter" },
  ["punctuation.list_marker"] = { "@punctuation.special", "TSPunctSpecial", "Delimiter" },
  ["punctuation.special"] = { "@punctuation.special", "TSPunctSpecial", "Special" },
  string = { "@string", "TSString", "String" }, ["string.escape"] = { "@string.escape", "TSStringEscape", "SpecialChar" },
  ["string.regex"] = { "@string.regex", "TSStringRegex", "String" }, ["string.special"] = { "@string.special", "TSStringSpecial", "SpecialChar" },
  ["string.special.symbol"] = { "@string.special.symbol", "TSStringSpecial", "SpecialChar" },
  tag = { "@tag", "TSTag", "Tag" }, ["tag.doctype"] = { "@tag.doctype", "TSTag", "PreProc" },
  ["text.literal"] = { "@markup.raw", "TSLiteral", "String" }, title = { "@markup.heading", "Title" },
  type = { "@type", "TSType", "Type" }, ["type.builtin"] = { "@type.builtin", "TSTypeBuiltin", "Type" },
  variable = { "@variable", "TSVariable", "Identifier" }, ["variable.special"] = { "@variable.builtin", "TSVariableBuiltin", "Special" },
  ["variable.parameter"] = { "@variable.parameter", "TSParameter", "Identifier" }, variant = { "@variant", "TSAttribute", "Type" },
}

local function style_for(candidates)
  for _, name in ipairs(candidates) do
    local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and value.fg then
      local result = { color = string.format("#%06x", value.fg) }
      if value.italic then result.font_style = "italic" end
      if value.bold then result.font_weight = 700 end
      return result
    end
  end
end

local syntax = {}
for target, candidates in pairs(syntax_groups) do syntax[target] = style_for(candidates) end

local ui_groups = {
  ["editor.background"] = { "Normal", "bg" }, ["editor.foreground"] = { "Normal", "fg" },
  ["editor.gutter.background"] = { "Normal", "bg" }, ["editor.line_number"] = { "LineNr", "fg" },
  ["editor.active_line_number"] = { "CursorLineNr", "fg" }, ["editor.active_line.background"] = { "CursorLine", "bg" },
  ["editor.highlighted_line.background"] = { "CursorLine", "bg" }, ["editor.selection.background"] = { "Visual", "bg" },
  ["editor.document_highlight.bracket_background"] = { "MatchParen", "bg" },
  ["editor.selection.foreground"] = { "Visual", "fg" }, ["panel.background"] = { "NormalFloat", "bg" },
  ["element.background"] = { "Pmenu", "bg" }, ["element.selected"] = { "PmenuSel", "bg" },
  ["border"] = { "FloatBorder", "fg" }, ["status_bar.background"] = { "StatusLine", "bg" },
  ["text"] = { "Normal", "fg" }, ["text.muted"] = { "Comment", "fg" },
}
local ui = {}
for target, spec in pairs(ui_groups) do
  local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = spec[1], link = false })
  if ok and value[spec[2]] then
    ui[target] = string.format("#%06x", value[spec[2]])
  end
end

local file = assert(io.open(vim.env.OMARCHY_ZED_EXPORT, "w"))
file:write(vim.json.encode({ colorscheme = vim.g.colors_name, syntax = syntax, ui = ui }), "\n")
file:close()
