-- generated.lua – Helix Zenburn theme для Neovim
-- Прозрачный фон (bg = "NONE"), как в оригинале.

local palette = {
    t1 = "#323230",
    t2 = "#474945",
    t3 = "#a19999",
    t4 = "#b0b4b6",
    t5 = "#c3d0d1",
    t6 = "#bde1e4",
    t7 = "#ffa3a9",
    t8 = "#feffff",
    t9 = "#ffffff",
    t10 = "#ffffff",
    t11 = "#ffe8a6",
    highlight = "#ff6cc3",
    highlight_two = "#ffff74",
    highlight_three = "#ffffe1",
    selection = "#89fdff",
    selection_fg = "#292c2d",
    black = "#000000",
    comment = "#b0837d",
    comment_doc = "#507a86",
    hints = "#646a74",
    ruler = "#4f504c",
    error = "#ff7a1d",
    warning = "#ffff1d",
    display = "#7dffff",
    info = "#ffffff",
    diff_minus = "#ff7a1d",
    diff_delta = "#1dcbff",
    diff_plus = "#ffff1d",
    diff_delta_moved = "#1d86ff",
}

local function set_hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

local function set_hl_multiple(groups, opts)
    for _, g in ipairs(groups) do
        set_hl(g, opts)
    end
end

-- ========================
-- 1. Фон – прозрачный (bg = "NONE")
-- ========================
set_hl("Normal", { fg = palette.t8, bg = "NONE" })
set_hl("NormalNC", { fg = palette.t8, bg = "NONE" })
set_hl("EndOfBuffer", { fg = "NONE", bg = "NONE" })  -- скрыть ~

-- ========================
-- 2. Синтаксис (из helix.toml)
-- ========================
set_hl_multiple({ "Comment", "TSComment", "@comment" }, { fg = palette.comment, italic = true })
set_hl("@comment.documentation", { bg = palette.comment_doc, italic = true })

set_hl_multiple({ "Constant", "TSConstant", "@constant" }, { fg = palette.t11 })

set_hl_multiple({ "Function", "TSFunction", "@function" }, { fg = palette.t10 })
set_hl_multiple({ "TSMethod", "@method" }, { fg = palette.t7 })
set_hl_multiple({ "TSMacro", "@function.macro" }, { fg = palette.t7 })

set_hl_multiple({ "Keyword", "TSKeyword", "@keyword" }, { fg = palette.t6 })
set_hl_multiple({ "TSKeywordFunction", "@keyword.function" }, { fg = palette.t11 })
set_hl_multiple({ "Include", "@include" }, { fg = palette.t8 })
set_hl_multiple({ "Conditional", "TSConditional", "@conditional" }, { fg = palette.t8 })
set_hl_multiple({ "Repeat", "TSRepeat", "@repeat" }, { fg = palette.t8 })
set_hl_multiple({ "StorageClass", "TSStorageClass", "@storageclass" }, { fg = palette.t7 })

set_hl_multiple({ "Operator", "TSOperator", "@operator" }, { fg = palette.t8 })
set_hl_multiple({ "Punctuation", "TSPunct", "@punctuation" }, { fg = palette.t9 })

set_hl_multiple({ "String", "TSString", "@string" }, { fg = palette.t6, italic = true })
set_hl("@string.regexp", { fg = palette.t6 })

set_hl_multiple({ "Type", "TSType", "@type" }, { fg = palette.t8, bold = true })
set_hl_multiple({ "TSNamespace", "@namespace" }, { fg = palette.t6, bold = true })

set_hl_multiple({ "Identifier", "TSIdentifier", "@variable" }, { fg = palette.t4 })
set_hl("@variable.parameter", { fg = palette.t6 })
set_hl("@variable.member", { fg = palette.t3 })

set_hl_multiple({ "Tag", "TSTag", "@tag" }, { fg = palette.t4 })
set_hl_multiple({ "Label", "TSLabel", "@label" }, { fg = palette.t4 })

-- ========================
-- 3. Diff
-- ========================
set_hl("DiffAdd", { fg = palette.diff_plus })
set_hl("DiffChange", { fg = palette.diff_delta })
set_hl("DiffDelete", { fg = palette.diff_minus })
set_hl("DiffText", { fg = palette.diff_delta_moved })
set_hl("@diff.plus", { fg = palette.diff_plus })
set_hl("@diff.delta", { fg = palette.diff_delta })
set_hl("@diff.delta.moved", { fg = palette.diff_delta_moved })
set_hl("@diff.minus", { fg = palette.diff_minus })

-- ========================
-- 4. Markup
-- ========================
set_hl_multiple({ "Title", "TSMarkdownHeading", "@markup.heading" }, { fg = palette.t7 })
set_hl_multiple({ "TSMarkdownList", "@markup.list" }, { fg = palette.t7 })
set_hl_multiple({ "TSMarkdownBold", "@markup.bold" }, { fg = palette.t4, bold = true })
set_hl_multiple({ "TSMarkdownItalic", "@markup.italic" }, { fg = palette.t4, italic = true })
set_hl_multiple({ "TSMarkdownStrikethrough", "@markup.strikethrough" }, { fg = palette.t4, strikethrough = true })
set_hl_multiple({ "TSMarkdownLink", "@markup.link.text" }, { fg = palette.t11 })
set_hl("@markup.link.url", { fg = palette.t11, underline = true })
set_hl_multiple({ "TSMarkdownQuote", "@markup.quote" }, { fg = palette.t5 })
set_hl_multiple({ "TSMarkdownCode", "@markup.raw" }, { fg = palette.t4 })

-- ========================
-- 5. UI элементы (bg = "NONE" для всех, где в Helix было bg = none)
-- ========================
-- Номера строк
set_hl("LineNr", { fg = palette.hints, bg = "NONE" })
set_hl("CursorLineNr", { fg = palette.t8, bg = "NONE" })

-- Статуслайн (в Helix bg = none)
set_hl("StatusLine", { fg = palette.t8, bg = "NONE", bold = true })
set_hl("StatusLineNC", { fg = palette.t4, bg = "NONE" })

-- Попап / меню (в Helix bg = none)
set_hl("Pmenu", { fg = palette.t8, bg = "NONE" })
set_hl("PmenuSel", { fg = palette.t8, bg = palette.selection })
set_hl("PmenuSbar", { bg = "NONE" })
set_hl("PmenuThumb", { bg = palette.t5 })

-- Буферная строка (в Helix bg = none)
set_hl("TabLine", { fg = palette.t4, bg = "NONE" })
set_hl("TabLineSel", { fg = palette.black, bg = palette.t8 })
set_hl("TabLineFill", { bg = "NONE" })

-- Текст / поиск / выделение
set_hl("Search", { bg = palette.highlight_two, fg = palette.black })
set_hl("IncSearch", { bg = palette.highlight, fg = palette.black })
set_hl("Directory", { fg = palette.t8, bg = "NONE" })

-- Виртуальные элементы (отступы, подсказки) – в Helix bg = none
set_hl("Whitespace", { fg = palette.ruler })
set_hl("VirtualText", { fg = palette.hints, bg = "NONE" })

-- Выделение (в Helix bg задан)
set_hl("Visual", { bg = palette.selection, fg = palette.selection_fg })

-- Курсор и скобки (в Helix bg задан)
set_hl("Cursor", { fg = palette.black, bg = palette.t8 })
set_hl("CursorIM", { fg = palette.black, bg = palette.t8 })
set_hl("MatchParen", { fg = palette.t8, bg = palette.selection, bold = true })

-- Подсветка (ui.highlight) – в Helix bg = secondary_container
set_hl("Search", { bg = palette.highlight_two, fg = palette.black })

-- Текущая строка (можно оставить прозрачной или задать лёгкий фон)
set_hl("CursorLine", { bg = "NONE" })
set_hl("CursorColumn", { bg = "NONE" })

-- ========================
-- 6. Диагностика (LSP) – в Helix underlined, bg = none
-- ========================
set_hl("DiagnosticError", { fg = palette.error, undercurl = true, sp = palette.error })
set_hl("DiagnosticWarn",  { fg = palette.warning, undercurl = true, sp = palette.warning })
set_hl("DiagnosticInfo",  { fg = palette.info, undercurl = true, sp = palette.info })
set_hl("DiagnosticHint",  { fg = palette.hints, undercurl = true, sp = palette.hints })
set_hl("DiagnosticUnnecessary", { fg = palette.t2, italic = true })

-- ========================
-- 7. Fallback сообщения
-- ========================
set_hl("ErrorMsg", { fg = palette.error })
set_hl("WarningMsg", { fg = palette.warning })
set_hl("ModeMsg", { fg = palette.info })
set_hl("MoreMsg", { fg = palette.hints })

print("Helix theme (transparent) applied successfully!")
