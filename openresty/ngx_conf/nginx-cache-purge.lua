local md5 = ngx.md5

function file_exists(name)
        local f = io.open(name, "r")
        if f~=nil then io.close(f) return true else return false end
end

function explode(d, p)
        local t, ll
        t={}
        ll=0
        if(#p == 1) then return {p} end
                while true do
                        l=string.find(p, d, ll, true)
                        if l~=nil then.
                                table.insert(t, string.sub(p, ll, l-1))
                                ll=l+1
                        else
                                table.insert(t, string.sub(p, ll))
                                break
                        end
                end
        return t
end

function purge(filename)
        if (file_exists(filename)) then
                os.remove(filename)
        end
end

function trim(s)
        return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function exec(cmd)
        local handle = io.popen(cmd)
        local result = handle:read("*all")
        handle:close()
        return trim(result)
end

function list_files(cache_path, purge_upstream, purge_pattern)
        local result = exec("/usr/bin/find " .. cache_path .. " -type f | /usr/bin/xargs --no-run-if-empty -n1000 /bin/grep -El -m 1 '^KEY: " .. purge_upstream .. purge_pattern .. "' 2>&1")
        if result == "" then
                return {}
        end
        return explode("\n", result)
end

function cache_filename(cache_path, cache_levels, cache_key)
        local md5sum = md5(cache_key)
        local levels = explode(":", cache_levels)
        local filename = ""

        local index = string.len(md5sum)
        for k, v in pairs(levels) do
                local length = tonumber(v)
                index = index - length;
                filename = filename .. md5sum:sub(index+1, index+length) .. "/";
        end
        if cache_path:sub(-1) ~= "/" then
                cache_path = cache_path .. "/";
        end
        filename = cache_path .. filename .. md5sum
        return filename
end

function file_exists(name)
        local f=io.open(name,"r")
        if f~=nil then io.close(f) return true else return false end
end

function purge_single()
        local cache_key = ngx.var.lua_purge_upstream .. ngx.var.request_uri
        local filename = cache_filename(ngx.var.lua_purge_path, ngx.var.lua_purge_levels, cache_key)

        if file_exists(filename) then
                purge(filename)
                return 1
        else
                return 0
        end
end

function purge_multi()
        local files = list_files(ngx.var.lua_purge_path, ngx.var.lua_purge_upstream, ngx.var.request_uri)

        for k, v in pairs(files) do
                purge(v)
        end

        return table.getn(files)
end

function purge_all()
        local number = exec("/usr/bin/find " .. ngx.var.lua_purge_path .. " -type f | /usr/bin/wc -l")
        os.execute('rm -rd "'..ngx.var.lua_purge_path..'/"')
        return number
end

function get_function(uri)
        local func
        if(uri == '/purge_all.html') then
                func = 'purge_all'
        elseif(string.find(uri,'*')) then
                func = 'purge_multi'
        else
                func = 'purge_single'
        end

        return func
end


if ngx ~= nil then
        local func = get_function(ngx.var.request_uri)
        local count = _G[func]()
        ngx.header["Content-type"] = "text/plain; charset=utf-8"
        ngx.header["X-Purged-Count"] = count
        ngx.say('OK')
        ngx.exit(ngx.OK)
end