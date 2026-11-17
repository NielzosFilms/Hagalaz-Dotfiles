-- Hagalaz for Neovim: aether.nvim with the palette from colors.toml, plus
-- syntax and editor colors matching the Hagalaz IntelliJ editor scheme
-- (~/Projects/hagalaz-intellij-theme/src/main/resources/theme/Hagalaz.xml).
--
-- Omarchy copies this file instead of generating one from colors.toml, so
-- palette changes in colors.toml must be mirrored in `colors` below.

local p = {
  ash = "#0a0807", -- background
  soot = "#14100e", -- caret row, popups
  iron = "#2e2724", -- selection, guides, separators
  muted = "#6b635c", -- comments, line numbers
  dark_fg = "#867d73", -- doc comments, , . ;
  fg = "#d5cbbb", -- bone: text, locals
  light_fg = "#e3dacb", -- instance fields
  bright_fg = "#efe8dc", -- parameters
  punct = "#c4bcae", -- operators, braces

  blood = "#c1121f", -- keywords, caret, matched brace
  dried_blood = "#5a0d10",
  red = "#b8323a", -- annotations, doc tags
  bright_red = "#d4474d", -- errors
  sage = "#7d8a68", -- strings
  bright_sage = "#9aa886", -- escapes, attributes
  gold = "#a8956a", -- numbers
  bright_gold = "#c9b98a", -- constants, warnings
  steel = "#6f7f8c", -- function declarations
  bright_steel = "#8fa0ae", -- function calls, static members
  mauve = "#8c6a76", -- class declarations
  bright_mauve = "#ad8b97", -- type references
  teal = "#6f8c88", -- tags
  bright_teal = "#8fadaa", -- entities, doc markup
}

local function highlights(hl)
  local function set(groups, spec)
    for _, g in ipairs(groups) do
      hl[g] = spec
    end
  end

  -- Keywords: blood red, bold
  set({
    "Keyword", "Statement", "Conditional", "Repeat", "Exception", "Include", "Define",
    "StorageClass", "PreProc", "@keyword", "@keyword.function", "@keyword.return",
    "@keyword.conditional", "@keyword.repeat", "@keyword.exception", "@keyword.import",
    "@keyword.storage", "@keyword.modifier", "@keyword.type", "@keyword.coroutine",
    "@keyword.operator", "@keyword.directive", "@type.qualifier",
    "@type.builtin", "@constant.builtin", "@variable.builtin", "Boolean", "@boolean",
    "@lsp.type.keyword", "@lsp.type.modifier",
  }, { fg = p.blood, bold = true })

  -- Strings and escapes
  set({ "String", "Character", "@string", "@character" }, { fg = p.sage })
  set({ "@string.escape", "@string.regexp", "SpecialChar", "@character.special" }, { fg = p.bright_sage })

  -- Numbers
  set({ "Number", "Float", "@number", "@number.float" }, { fg = p.gold })

  -- Comments: muted italic, doc comments a step lighter
  set({ "Comment", "@comment", "SpecialComment" }, { fg = p.muted, italic = true })
  set({ "@comment.documentation", "@string.documentation" }, { fg = p.dark_fg, italic = true })
  hl["@comment.todo"] = { fg = p.bright_gold, bold = true }
  hl["@comment.note"] = { fg = p.bright_teal, bold = true }
  hl["@comment.warning"] = { fg = p.bright_gold, bold = true }
  hl["@comment.error"] = { fg = p.bright_red, bold = true }
  hl.Todo = { fg = p.ash, bg = p.bright_gold, bold = true }

  -- Functions: declarations steel, calls brighter
  set({ "Function", "@function", "@function.method", "@lsp.type.function", "@lsp.type.method" }, { fg = p.steel })
  set({ "@function.call", "@function.method.call", "@function.builtin", "@constructor" }, { fg = p.bright_steel })
  hl["@lsp.typemod.method.static"] = { fg = p.bright_steel, bold = true }
  hl["@lsp.typemod.function.static"] = { fg = p.bright_steel, bold = true }
  set({ "Macro", "@function.macro", "@lsp.type.macro" }, { fg = p.red })

  -- Types: declarations mauve bold, references lighter
  set({ "Type", "Structure", "Typedef", "@type", "@type.definition", "@lsp.type.type",
    "@lsp.type.class", "@lsp.type.struct", "@lsp.type.enum", "@lsp.type.typeParameter" }, { fg = p.bright_mauve })
  set({ "@lsp.typemod.class.declaration", "@lsp.typemod.struct.declaration",
    "@lsp.typemod.enum.declaration", "@lsp.typemod.type.declaration" }, { fg = p.mauve, bold = true })
  set({ "@lsp.type.interface" }, { fg = p.bright_mauve, bold = true })

  -- Constants and static fields
  set({ "Constant", "@constant", "@constant.macro", "@lsp.type.enumMember" }, { fg = p.bright_gold })
  hl["@lsp.typemod.property.static"] = { fg = p.bright_steel, bold = true }
  hl["@lsp.typemod.variable.static"] = { fg = p.bright_steel, bold = true }
  hl["@lsp.typemod.variable.readonly"] = { fg = p.bright_gold }

  -- Fields, parameters, locals
  set({ "@variable.member", "@property", "@field", "@lsp.type.property" }, { fg = p.light_fg })
  set({ "@variable.parameter", "@parameter", "@lsp.type.parameter" }, { fg = p.bright_fg })
  set({ "Identifier", "@variable", "@lsp.type.variable", "@module", "@lsp.type.namespace" }, { fg = p.fg })

  -- Punctuation and operators
  set({ "Operator", "@operator", "@punctuation.bracket", "@punctuation.special" }, { fg = p.punct })
  set({ "Delimiter", "@punctuation.delimiter" }, { fg = p.dark_fg })

  -- Annotations / decorators / attributes
  set({ "@attribute", "@annotation", "@lsp.type.decorator", "@keyword.directive.define" }, { fg = p.red })

  -- Markup tags (HTML/XML/JSX)
  set({ "Tag", "@tag", "@tag.builtin", "@tag.tsx", "@tag.javascript", "@constructor.tsx" }, { fg = p.teal })
  set({ "@tag.attribute" }, { fg = p.bright_sage })
  set({ "@tag.delimiter", "@tag.delimiter.tsx" }, { fg = p.punct })
  set({ "Special", "@string.special", "@markup.link.url" }, { fg = p.bright_teal })

  -- Editor chrome
  hl.Cursor = { fg = p.ash, bg = p.blood }
  hl.lCursor = hl.Cursor
  hl.CursorIM = hl.Cursor
  hl.TermCursor = hl.Cursor
  hl.CursorLine = { bg = p.soot }
  hl.CursorColumn = { bg = p.soot }
  hl.ColorColumn = { bg = p.soot }
  hl.LineNr = { fg = p.muted }
  hl.LineNrAbove = { fg = p.muted }
  hl.LineNrBelow = { fg = p.muted }
  hl.CursorLineNr = { fg = p.blood, bold = true }
  hl.MatchParen = { fg = p.blood, bold = true, underline = true }
  hl.Visual = { bg = p.iron }
  hl.VisualNOS = { bg = p.iron }
  hl.Search = { bg = "#2e1c1a", fg = p.bright_fg }
  hl.IncSearch = { bg = "#3d1417", fg = p.bright_fg, bold = true }
  hl.CurSearch = { bg = "#3d1417", fg = p.bright_fg, bold = true }
  hl.Substitute = { bg = p.dried_blood, fg = p.bright_fg }
  hl.WinSeparator = { fg = p.iron }
  hl.VertSplit = { fg = p.iron }
  hl.NonText = { fg = p.iron }
  hl.Whitespace = { fg = p.iron }
  hl.SpecialKey = { fg = p.iron }
  hl.EndOfBuffer = { fg = p.ash }
  hl.Folded = { fg = p.dark_fg, bg = p.soot, italic = true }
  hl.FoldColumn = { fg = p.iron }
  hl.PmenuSel = { bg = p.iron, fg = p.bright_fg, bold = true }
  hl.PmenuThumb = { bg = p.iron }

  -- Floating windows: ash background, blood red frame and titles. The
  -- matching Hyprland window border is blood red too.
  local float = { fg = p.fg, bg = p.ash }
  local border = { fg = p.blood, bg = p.ash }
  local title = { fg = p.blood, bg = p.ash, bold = true }
  set({ "NormalFloat", "Pmenu", "NoicePopup", "NoicePopupmenu", "NoiceConfirm", "BlinkCmpMenu",
    "BlinkCmpDoc", "BlinkCmpSignatureHelp", "WhichKeyNormal", "LazyNormal", "MasonNormal",
    "SnacksNotifierInfo", "SnacksNotifierDebug", "SnacksNotifierTrace" }, float)
  set({ "FloatBorder", "LspInfoBorder", "NoicePopupBorder", "NoicePopupmenuBorder",
    "NoiceConfirmBorder", "BlinkCmpMenuBorder", "BlinkCmpDocBorder", "BlinkCmpSignatureHelpBorder",
    "WhichKeyBorder", "SnacksInputBorder", "SnacksPickerBorder", "SnacksPickerInputBorder",
    "SnacksPickerBoxBorder", "SnacksPickerPreviewBorder", "SnacksPickerListBorder",
    "SnacksNotifierBorderInfo", "SnacksNotifierBorderDebug", "SnacksNotifierBorderTrace" }, border)
  set({ "FloatTitle", "SnacksInputTitle", "SnacksPickerTitle", "SnacksPickerBoxTitle",
    "SnacksPickerInputTitle", "SnacksPickerPreviewTitle", "SnacksPickerListTitle", "WhichKeyTitle",
    "SnacksNotifierTitleInfo", "SnacksNotifierTitleDebug", "SnacksNotifierTitleTrace" }, title)
  hl.SnacksInputIcon = { fg = p.blood }
  hl.SnacksPickerPrompt = { fg = p.blood, bold = true }
  hl.BlinkCmpDocSeparator = { fg = p.iron, bg = p.ash }
  hl.NoicePopupmenuSelected = { bg = p.iron, bold = true }
  -- Warning and error notifications keep their own frame colour
  hl.SnacksNotifierWarn = float
  hl.SnacksNotifierError = float
  hl.SnacksNotifierBorderWarn = { fg = p.bright_gold, bg = p.ash }
  hl.SnacksNotifierTitleWarn = { fg = p.bright_gold, bg = p.ash, bold = true }
  hl.SnacksNotifierBorderError = { fg = p.bright_red, bg = p.ash }
  hl.SnacksNotifierTitleError = { fg = p.bright_red, bg = p.ash, bold = true }

  -- Identifier under cursor (LSP document highlight)
  set({ "LspReferenceText", "LspReferenceRead", "LspReferenceWrite", "IlluminatedWordText",
    "IlluminatedWordRead", "IlluminatedWordWrite" }, { bg = p.iron })

  -- Indent guides: iron, active scope in blood red
  set({ "SnacksIndent", "IblIndent", "MiniIndentscopeSymbol" }, { fg = p.iron })
  set({ "SnacksIndentScope", "IblScope" }, { fg = p.blood })

  -- Diagnostics
  hl.DiagnosticError = { fg = p.bright_red }
  hl.DiagnosticWarn = { fg = p.bright_gold }
  hl.DiagnosticInfo = { fg = p.bright_steel }
  hl.DiagnosticHint = { fg = p.bright_teal }
  hl.DiagnosticUnderlineError = { undercurl = true, sp = p.bright_red }
  hl.DiagnosticUnderlineWarn = { underline = true, sp = p.bright_gold }
  hl.DiagnosticUnderlineInfo = { underline = true, sp = p.bright_steel }
  hl.DiagnosticUnderlineHint = { underline = true, sp = p.muted }
  hl.DiagnosticDeprecated = { strikethrough = true, sp = p.muted }
  hl.DiagnosticUnnecessary = { fg = p.muted }
  hl.SpellBad = { undercurl = true, sp = p.bright_red }
  hl.SpellCap = { underline = true, sp = p.muted }

  -- Command-line popup (noice): blood red frame, gold while searching
  hl.NoiceCmdlinePopupBorder = { fg = p.blood, bg = p.ash }
  hl.NoiceCmdlinePopupTitle = { fg = p.blood, bg = p.ash, bold = true }
  hl.NoiceCmdlineIcon = { fg = p.blood }
  hl.NoiceCmdlinePopupBorderSearch = { fg = p.gold, bg = p.ash }
  hl.NoiceCmdlinePopupTitleSearch = { fg = p.gold, bg = p.ash, bold = true }
  hl.NoiceCmdlineIconSearch = { fg = p.gold }
  hl.NoiceCmdlinePopup = { fg = p.fg, bg = p.ash }

  -- Status line mode blocks, read by ~/.config/nvim/lua/plugins/lualine-transparent.lua
  hl.LualineModeNormal = { fg = p.bright_fg, bg = p.blood, bold = true }
  hl.LualineModeInsert = { fg = p.ash, bg = p.sage, bold = true }
  hl.LualineModeVisual = { fg = p.ash, bg = p.bright_mauve, bold = true }
  hl.LualineModeCommand = { fg = p.ash, bg = p.gold, bold = true }
  hl.LualineModeReplace = { fg = p.blood, bg = p.fg, bold = true }

  -- Diff and git signs
  hl.DiffAdd = { bg = "#1a2410" }
  hl.DiffChange = { bg = "#241d10" }
  hl.DiffDelete = { bg = "#2a0f10" }
  hl.DiffText = { bg = "#3a2e18" }
  set({ "GitSignsAdd", "MiniDiffSignAdd", "diffAdded" }, { fg = p.sage })
  set({ "GitSignsChange", "MiniDiffSignChange", "diffChanged" }, { fg = p.gold })
  set({ "GitSignsDelete", "MiniDiffSignDelete", "diffRemoved" }, { fg = p.red })
end

return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      styles = {
        comments = { italic = true },
        keywords = { bold = true },
      },
      colors = {
        bg = "#0a0807",
        dark_bg = "#070605",
        darker_bg = "#040302",
        lighter_bg = "#14100e",

        fg = "#d5cbbb",
        dark_fg = "#867d73",
        light_fg = "#e3dacb",
        bright_fg = "#efe8dc",
        muted = "#6b635c",

        red = "#b8323a",
        yellow = "#a8956a",
        orange = "#a8956a",
        green = "#7d8a68",
        cyan = "#6f8c88",
        blue = "#6f7f8c",
        magenta = "#8c6a76",
        brown = "#544b35",

        bright_red = "#d4474d",
        bright_yellow = "#c9b98a",
        bright_green = "#9aa886",
        bright_cyan = "#8fadaa",
        bright_blue = "#8fa0ae",
        bright_magenta = "#ad8b97",

        accent = "#c1121f",
        cursor = "#efe8dc",
        foreground = "#d5cbbb",
        background = "#0a0807",
        selection = "#2e2724",
        selection_foreground = "#efe8dc",
        selection_background = "#2e2724",
      },
      on_highlights = function(hl, _)
        highlights(hl)
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
