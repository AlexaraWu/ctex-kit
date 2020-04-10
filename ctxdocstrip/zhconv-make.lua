#!/usr/bin/env texlua
--
--  File zhconv-make.lua
--
--     Copyright (C) 2020 by Qing Lee <sobenlee@gmail.com>
--------------------------------------------------------------------------
--
--     This work may be distributed and/or modified under the
--     conditions of the LaTeX Project Public License, either
--     version 1.3c of this license or (at your option) any later
--     version. This version of this license is in
--        http://www.latex-project.org/lppl/lppl-1-3c.txt
--     and the latest version of this license is in
--        http://www.latex-project.org/lppl.txt
--     and version 1.3 or later is part of all distributions of
--     LaTeX version 2005/12/01 or later.
--
--     This work has the LPPL maintenance status "maintained".
--
--     The Current Maintainer of this work is Qing Lee.
--
--     This work consists of the files zhconv.lua, zhconv-make.lua
--               and the derived files zhconv-index.lua, zhconv-index.luc.
--
--------------------------------------------------------------------------
--

local preamble = [[
--
--  File zhconv-index.lua
--
--     Copyright (C) 2020 by Qing Lee <sobenlee@gmail.com>
--------------------------------------------------------------------------
--
--     This work may be distributed and/or modified under the
--     conditions of the LaTeX Project Public License, either
--     version 1.3c of this license or (at your option) any later
--     version. This version of this license is in
--        http://www.latex-project.org/lppl/lppl-1-3c.txt
--     and the latest version of this license is in
--        http://www.latex-project.org/lppl.txt
--     and version 1.3 or later is part of all distributions of
--     LaTeX version 2005/12/01 or later.
--
--     This work has the LPPL maintenance status "maintained".
--
--     The Current Maintainer of this work is Qing Lee.
--
--     This work consists of the files zhconv.lua, zhconv-make.lua
--               and the derived files zhconv-index.lua, zhconv-index.luc.
--
--------------------------------------------------------------------------
--
--  Do not edit this file!
--  Generated from the WHATWG Encoding Standard:
--
--     https://encoding.spec.whatwg.org/index-big5.txt           (Date: %s)
--     https://encoding.spec.whatwg.org/index-gb18030.txt        (Date: %s)
--     https://encoding.spec.whatwg.org/index-gb18030-ranges.txt (Date: %s)
--
--
]]

local rep, format, dump = string.rep, string.format, string.dump
local insert, unpack, concat = table.insert, table.unpack, table.concat
local io_open, os_execute = io.open, os.execute

local curlcmd = "curl --silent --output %s https://encoding.spec.whatwg.org/%s"
local function prepare_index (file)
  local file_path = file
  local handle = io_open(file, "rb")
  if handle then return handle end
  local ret = os_execute(curlcmd:format(file, file))
  assert(ret == 0, "the curl command failed with: ".. ret)
  return assert(io_open(file, "rb"))
end

local index, date = { }, { }

local indent = 2
local begin_enc = "%s[%q] = {"
local end_enc   = "%s} ,"
local num_item = "%s[%s] = %s ,"
local tab_item = "%s{ %6d , %s } ,"
local tab = rep(" ", indent)
local tabtab = tab .. tab

insert(index, "return {")
for i, v in ipairs { { "index-big5.txt",  "big5" },
                     { "index-gb18030.txt", "gb18030" },
                     { "index-gb18030-ranges.txt", "gb18030_ranges" } } do
  local file, encode = unpack(v)
  local handle = prepare_index(file)
  insert(index, begin_enc:format(tab, encode))
  for line in handle:lines() do
    if not date[i] then
      local s = line:match("Date: (.+)$")
      if s then date[i] = s end
    end
    local pointer, code_point = line:match("^%s*(%d+)\t(0x%x+)")
    if pointer and code_point then
      insert(index, format(i == 3 and tab_item or num_item, tabtab, pointer, code_point))
    end
  end
  insert(index, end_enc:format(tab))
  handle:close()
end
insert(index, "}\n")

local index = concat(index, "\n")

local handle = io_open("zhconv-index.luc", "wb")
handle:write(dump(load(index), true))
handle:close()

local handle = io_open("zhconv-index.lua", "wb")
handle:write(preamble:format(unpack(date)), index)
handle:close()
