Functions = {}

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function Functions.TablePrint (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
      formatting = string.rep("  ", indent) .. k .. ": "
      if type(v) == "table" then
        print(formatting)
        Functions.TablePrint(v, indent+1)
      elseif type(v) == 'boolean' then
        print(formatting .. tostring(v))      
      else
        print(formatting .. v)
      end
    end
  end

-- makes an array of controls exclusive, so when one turns on the others turn off.
-- does not overwrite existing eventHandlers, but adds to them
function Functions.MakeExclusive(ArrayOfCtrls)
    for i , v in pairs(ArrayOfCtrls) do
      local oldEH = v.EventHandler or function() end
      v.EventHandler = function()
        for x,y in pairs(ArrayOfCtrls) do
          y.Boolean = x == i
        end
        oldEH()
      end
    end
end

-- will return the index of a given value if found in table t
function Functions.GetIndex(t,value)
    for i , v in pairs(t) do
        if v == value then return i end
    end
end

function Functions.Write(socket, data, EOL)
  print('TX:', data)
  EOL = EOL or ""
  socket:Write(data..EOL)
end

----------------------------------------------------functions for finding available NICs on a Core and returning their IP address---------------------------

function Functions.SetNicOptions() --this function looks through the Cores network interfaces - if a Core has a valid IP address then it will return that NIC as an option to be used in a dropdown list
  local availablePort = {}
  for subtbl,item in pairs(Network.Interfaces()) do
    if subtbl then --checks valid IP of Cores NICs
      table.insert(availablePort, item.Interface) --inserts the interface into the table for using in a dropdown box
    end
  end
  return availablePort
end 

function Functions.GetIP(s) --returns the IP address of a selected Core interface. Example, if you select "LAN B" in your interface dropdown box - it will return you the IP of that NIC
  for index,value in pairs(Network.Interfaces()) do
    if value.Interface == s then 
      return value.Address
    end 
  end
end 

-- provide a string and delimiter and the function will return a table with the split parts of the string.
function Functions.SplitString(str, delimiter)
  local t = {}
  for word in string.gmatch(str, "[^" .. delimiter .. "]+") do
    table.insert(t, word)
  end
  return t
end


--------------------------functions to write a CSV file---------------------
function Functions.AddCsvRow(filePath, data)
  -- Open the CSV file in append mode
  local file = io.open('media/'.. filePath, "a")

  -- Convert the data table to a string and append it to the file
  file:write(table.concat(data, ",") .. "\n")

  -- Close the file
  file:close()
end

--eg AddCsvRow('Audio/test.csv', {7,8,9,0})

------------------------Wake on LAN function -------------------------------------

--function for sending a Wake On LAN command for any devices that require. 
function Functions.WOL(mac)
  local wol = UdpSocket.New()
  wol:Open()
  mac1=parseMacAddress(mac)
  for i=1,4 do
    mac1 = mac1..mac1
  end

  mac2 = string.char(0xff,0xff,0xff,0xff,0xff,0xff)..mac1
  wol:Send("255.255.255.255",9,mac2)
  print("Wake-On-Lan packet sent")
  wol:Close()
end

function parseMacAddress(mac)
  local bytes = {string.match(mac, '(%x+)[-:](%x+)[-:](%x+)[-:](%x+)[-:](%x+)[-:](%x+)')}
  if bytes == nil then
    return
  end
  for i = 1, 6 do
    if bytes[i] == nil then
      return 
    end
    bytes[i] = tonumber(bytes[i], 16)
    if  bytes[i] < 0 or bytes[i] > 0xFF then
      return
    end
  end
  local addr = {}
  for i = 0, 5 do
    addr[i] = bytes[i + 1]
  end
  return string.char(addr[0],addr[1],addr[2],addr[3],addr[4],addr[5])
end

-----------------------Title case strings-----------------------------------------

function Functions.StringTitlecase(str) --takes in a string as it's parameters and will capitalise the first character of each word. 
local buf = {}
  local inWord = false
  for i = 1, #str do
    local c = string.sub(str, i, i) 
    if inWord then
      table.insert(buf, string.lower(c))
      if string.find(c, "%s") then 
        inWord = false
      end
    else
      table.insert(buf, string.upper(c))
      inWord = true
    end
  end
  return table.concat(buf)
end

-----------------------Check IP is valid------------------------------------------

function Functions.CheckIP(ip)
  if not ip then return false end
  local octets = {ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
  if #octets ~= 4 then return false end
  for _, octet in ipairs(octets) do
    local num = tonumber(octet)
    if tonumber(num) == nil or tonumber(num) < 0 or tonumber(num) > 255 then
      return false
    end
  end
  return true
end


------------------hex converters------------------------------------------------

function Functions.HexToString(hex)
  local string = ""
  -- loop through each character in the hexadecimal string
  for i = 1, #hex, 2 do
    -- convert the hexadecimal code to a decimal number
    local decimal = tonumber(hex:sub(i, i+1), 16)
      -- if the decimal value is a printable character, add it to the output string
    if decimal >= 32 and decimal <= 126 then
      string = string .. string.char(decimal)
      -- if it's a control character, add a printable representation of it
    elseif decimal == 1 then
      string = string .. "<SOH>"
    elseif decimal == 0 then
      string = string .. "<NUL>"
    elseif decimal == 4 then
      string = string .. "<EOT>"
      ---------------------feel free to expand this for any others your may encounter--------------------
    end
  end
  return string
end

function Functions.StringToHex(str)
  local hexString = ""
  -- loop through each character in the string
  for i = 1, #str do
    -- convert the character to its ASCII code
    local decimal = string.byte(str:sub(i, i))
    -- convert the decimal value to a hexadecimal string
    local hex = string.format("%02X", decimal)
    -- add the hexadecimal code to the output string
    hexString = hexString .. hex
  end
  -- return the hexadecimal string
  return hexString
end

function Functions.NumberToHex(num)
  return string.format("%X", num)
end

function Functions.HexToNumber(hex)
  return tonumber(hex, 16)
end







--------------------------------------------------------------------------------

return Functions