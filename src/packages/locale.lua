local locale = {}

local locales = {}
local current = nil

local function readonly(t)
  return setmetatable(t, {
    __index = function(self, key) -- requesting totally unknown entries: fire off a nonbreaking error and return key
      rawset(self, key, key)      -- only need to see the warning once, really
      return key
    end,
    __newindex = function() assert(false, 'Locale is now read only') end
  })
end

local function writeonly(t)
  return setmetatable(t, {
    __newindex = function(self, key, value)
      if not rawget(self, key) then
        rawset(self, key, value == true and key or value)
      end
    end,
    __index = function() assert(false, 'Locale is now write only') end
  })
end

function locale.new(language)
  local L = writeonly(locales[language] or {})
  locales[language] = L
  return L
end

local function load(lang)
  --local ok , l = pcall(require, 'app.locale.'..lang)
  return ok and l or nil
end

function locale.get()
  return readonly(current)
end

function locale.set(lang)
  print('set language:', lang)
  local L = load(lang)
  if not L then
    L = load('zh-Hans')
  end
  current = L or {}
end

local smatch = string.match
local function matchAny(s, p)
    if type(p) == 'string' then
        return (smatch(s, p))
    elseif type(p) == 'table' then
        for _,v in ipairs(p) do
            if smatch(s,v) then
                return true
            end
        end
    end
    return false
end

local function glob(path, pattern, files)
  local lfs = require ('lfs')
  files = files or {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local mode = lfs.attributes (f, 'mode')
        if mode == 'file' then
          if matchAny(file, pattern) then
              files[#files+1] = f
            end
        elseif mode == 'directory' then
          glob(f, pattern, files)
        end
        end
    end
    return files
end

local translatable = {
  ['ccui.Text'] = {'getString', 'setString'},
  ['ccui.Button'] = {'getTitleText', 'setTitleText'}
}

local function addEntry(entries, item, file)
  if #item == 0 or entries[item] then return end
  entries[item] = true
  entries[#entries+1] = {item, file}
end

local function tr1(node, L)
  local funcs = translatable[tolua.type(node)]
  if funcs then
    local get, set = node[funcs[1]], node[funcs[2]]
    local raw = get(node)
    if #raw == 0 then return end
    local s = raw:match("^L%['([^']+)'%]$")
    if not s then return end
    local trans = L[s]
    set(node, trans)
  end
end

local function tr(node, L)
  tr1(node, L)
  for _, v in ipairs(node:getChildren()) do
    tr(v, L)
  end
end

local function translate(node)
  local L = locale.get()
  tr(node, L)
end

function cc.CSLoader:createLocalizedNode(csb) -- luacheck: ignore self
  local node = cc.CSLoader:createNode(csb)
  if node then
    translate(node)
  end
  return node
end


local function collectTranslation(entries, file)
  local f = io.open(file, 'r')
  local content = f:read('*a')
  f:close()
  for s in string.gmatch(content, "[^%a_]L%[[\"']([^\"']+)[\"']%]") do
    addEntry(entries, s, file)
  end
end


local function genetateTranslationFile(entries, lang)
  local filename = cc.FileUtils:getInstance():getWritablePath() ..lang.. '.lua'
  local f = io.open(filename, 'wb')

  f:write("local L = require('locale').new('"..lang.."')\n")

  for _, v in ipairs(entries) do
    f:write(string.format("L['%s'] = true -- %s\n", v[1], v[2]))
  end

  f:write("\nreturn L\n")
  f:close()
end

function locale.collect()
  local csds = glob('raw/cocosstudio/views', '.*%.csd')
  local entries = {}

  for _, v in ipairs(csds) do
    collectTranslation(entries, v)
  end

  local luas = glob('src/app', '.*%.lua')
  for _, v in ipairs(luas) do
    collectTranslation(entries, v)
  end

  for _, lang in ipairs({'zh-Hans', 'zh-Hant', 'en'}) do
    genetateTranslationFile(entries, lang)
  end
end

return locale
