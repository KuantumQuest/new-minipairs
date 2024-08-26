local M = {}
M.setup = function()
	local augroup = vim.api.nvim_create_augroup("autopairs", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
		pattern = "*",
		group = augroup,
		callback = function()
			M.setup_pairs()
		end,
	})
end

M.setup_pairs = function()
	local ls = require("luasnip")
	local t = ls.text_node
	local i = ls.insert_node
	local f = ls.function_node
	local d = ls.dynamic_node
	local sn = ls.snippet_node

	local get_visual = function(_, parent)
		local text = parent.snippet.env.LS_SELECT_DEDENT
		if #text > 0 then
			return sn(nil, { i(1, text) })
		else
			return sn(nil, { i(1) })
		end
	end

	-- local first_caracter = function(args, parent, user_args)
	--   if args[1][1] ~= user_args then
	--     return ""
	--   else
	--     return parent.trigger
	--   end
	-- end

	local multipairs_snippets = function()
		local snippets = {}
		local values = {
			{ "(", ")" },
			{ "[", "]" },
			{ "{", "}" },
			{ "`", "`" },
			{ "'", "'" },
			{ '"', '"' },
		}
		local s = ls.extend_decorator.apply(ls.snippet, { wordTrig = true, snippetType = "autosnippet", priority = 0 })
		for _, pair in ipairs(values) do
			vim.list_extend(snippets, {
				s({ trig = pair[1], name = pair[1] .. pair[2] }, { t(pair[1]), d(1, get_visual), t(pair[2]), i(0) }),
			})
			vim.list_extend(snippets, {
				s({ trig = "æ" .. pair[1], name = "Just " .. pair[1], priority = 10 }, { t(pair[1]), i(0) }),
			})
		end
		return snippets
	end

	ls.add_snippets("all", multipairs_snippets(), { default_priority = 0 })
	local s = ls.snippet

	ls.add_snippets("all", {
		s({ trig = "date", name = "date" }, { f(function()
			return os.date("%d-%m-%Y")
		end, {}) }),
		s({ trig = "time", name = "time" }, { f(function()
			return os.date("%H:%M:%S")
		end, {}) }),
	}, { default_priority = 0 })
end

return M
