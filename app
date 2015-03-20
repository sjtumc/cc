
local function printUsage()
    print( "Usages:" )
    print( "  app get <filename>  optional :<rename>" )
    print( "  app run <filename> <arguments>" )
    print( "  app list  :list all apps")
    print( "  app more :more info  ")
end

local function more()
    print("  run <filename> <args> will download the file (if file exists ,replace it by default) and execute programs with args")
end

local tArgs = {...}
if #tArgs == 0 then
    printUsage()
    return
end
 
if not http then
    printError( "  Apps requires http API" )
    printError( "  Set http_enable to true in ComputerCraft.cfg" )
    return
end

local function get(paste)
    write( "  Connecting to github.com... " )
    local urlPrefix = "https://raw.githubusercontent.com/sjtumc/cc/master/apps/"
    local response = http.get(urlPrefix..textutils.urlEncode( paste ))
        
    if response then
        print( " Success." )
        
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        printError( "  Failed." )
    end
end

local function isExists(file)
    if fs.exists( file ) then
        print( "  Warning! this file has already exists,do you want to replace it? y or n" )
        local replace = read()
        if (replace == "y") or (replace == "Y") then
        	print("  "..tostring(file).." will be repalced")
        	return true
        else 
        	print("  "..tostring(file).." won't be repalced")
      	return false
        end
    else 
    	return true
    end
end

local function star()
	 local x,y = term.getSize()
      for i=1,x do
      	if (i<3)or(i>x-2) then
      		term.write(' ')
      	else
      		term.write('*')
        end
      end
      print(' ')
end

local function list()
   local tmp = get("../applist")
   if tmp then
      print("   apps in serve   ")
      star()
   	  print(tmp)
   	  star()
    else 
      print("can't open applist")
    end
end

local sCommand = tArgs[1]

if sCommand == "get" then
    -- Download a file from pastebin.com
    if #tArgs < 2 then
        printUsage()
        return
    end
 
    -- Determine file to download
    local sFile    = tArgs[2]
    local sRename  = tArgs[3]
    local filename = sRename
    if not filename then 
    	print("  try to use default name")
    	   filename = sFile
    elseif filename == sFile then 
    	print("  use different filename for replace")
    	return
    end

    sPath  = shell.resolve( filename )
    if not isExists( sPath ) then
        return
    end
    
    -- GET the contents from pastebin
    local res = get(sFile)
    if res then        
        local file = fs.open( sPath, "w" )
        file.write( res )
        file.close()
        print( "  Downloaded  "..sFile.." and save as "..sPath)
    end 
elseif sCommand == "run" then
    local sFile = tArgs[2]
 
    local res = get(sFile)
    if res then
        local func, err = loadstring(res)
        if not func then
            printError( err )
            return
        end
        setfenv(func, getfenv())
        local success, msg = pcall(func, unpack(tArgs, 3))
        if not success then
            printError( msg )
        end
    end
elseif sCommand == "list" then
	 list()
elseif sCommand == "more" then
	 more()
else
    printUsage()
    return
end