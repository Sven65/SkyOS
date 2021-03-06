-- API load

os.loadAPI('api/text')
os.loadAPI('api/windows')

local w, h = term.getSize()
term.setBackgroundColor(2048)
term.setTextColor(1)
term.clear()
desktop = false
login = false

function login()
term.clear()
text.cPrint("SkyOS", 2)
text.cWrite("Username: ", 4)
text.cWrite("Password: ", 6)
text.cWrite("Username: ", 4)
local name = read()
text.cWrite("Password: ", 6)
local pass = read('*')
file = fs.open("users/"..name,"r")
if not fs.exists("users/"..name) then
	text.cPrint('Login failed!', 8)
	sleep(0.5)
	login()
else
	local fileData = {}
	local line = file.readLine()
	repeat
		table.insert(fileData, line)
		line = file.readLine()
	until line == nil -- readLine()
		file.close()
		if pass == fileData[1] then
			text.cPrint("Login successfull!", 8)
			login = true
			sleep(0.5)
			desktop()

		else
			text.cPrint("Login failed", 8)
			sleep(0.5)
			login()
		end

end
end

local xSize, ySize, myEvent = term.getSize()

-- Returns whether a click was performed at a given location.
-- If one parameter is passed, it checks to see if y is [1].
-- If two parameters are passed, it checks to see if x is [1] and y is [2].
-- If three parameters are passed, it checks to see if x is between [1]/[2] (non-inclusive) and y is [3].
-- If four paramaters are passed, it checks to see if x is between [1]/[2] and y is between [3]/[4] (non-inclusive).
local function clickedAt(...)
        if myEvent[1] ~= "mouse_click" then return false end
        if #arg == 1 then return (arg[1] == myEvent[4])
        elseif #arg == 2 then return (myEvent[3] == arg[1] and myEvent[4] == arg[2])
        elseif #arg == 3 then return (myEvent[3] > arg[1] and myEvent[3] < arg[2] and myEvent[4] == arg[3])
        else return (myEvent[3] > arg[1] and myEvent[3] < arg[2] and myEvent[4] > arg[3] and myEvent[4] < arg[4]) end
end

-- Returns whether one of a given set of keys was pressed.
local function pressedKey(...)
        if myEvent[1] ~= "key" then return false end
        for i=1,#arg do if arg[i] == myEvent[2] then return true end end
        return false
end

local function Menu(displayList)
        local position, lastPosition = 1, 0
        term.setBackgroundColour(colours.black)

        while true do
                -- Update file list display.
                if position ~= lastPosition then for y = 1, ySize do
                        local thisLine = y + position - math.floor(ySize / 2) - 1

                        if displayList[thisLine] then
                                if thisLine == position then
                                        term.setCursorPos(math.floor((xSize - #displayList[thisLine] - 8) / 2) + 1, y)
                                        term.clearLine()
                                        term.setTextColour(term.isColour() and colours.cyan or colours.black)
                                        term.write("> > ")
                                        term.setTextColour(term.isColour() and colours.blue or colours.white)
                                        term.write(displayList[thisLine])
                                        term.setTextColour(term.isColour() and colours.cyan or colours.black)
                                        term.write(" < <")
                                else
                                        term.setCursorPos(math.floor((xSize - #displayList[thisLine]) / 2) + 1, y)
                                        term.clearLine()

                                        if y == 1 or y == ySize then
                                                term.setTextColour(colours.black)
                                        elseif y == 2 or y == ySize - 1 then
                                                term.setTextColour(term.isColour() and colours.grey or colours.black)
                                        elseif y == 3 or y == ySize - 2 then
                                                term.setTextColour(term.isColour() and colours.lightGrey or colours.white)
                                        else term.setTextColour(colours.white) end

                                        term.write(displayList[thisLine])
                                end
                        else
                                term.setCursorPos(1,y)
                                term.clearLine()
                        end
                end end
                lastPosition = position
                
                -- Wait for input.
                myEvent = {os.pullEvent()}

                -- Move down the list.
                if pressedKey(keys.down,keys.s) or (myEvent[1] == "mouse_scroll" and myEvent[2] == 1) then
                        position = position == #displayList and 1 or (position + 1)

                -- Move up the list.
                elseif pressedKey(keys.up,keys.w) or (myEvent[1] == "mouse_scroll" and myEvent[2] == -1) then
                        position = position == 1 and #displayList or (position - 1)

                -- Item selected, return its name.
                elseif pressedKey(keys.enter, keys.space) or clickedAt(math.floor(ySize / 2) + 1) then
                	login = true
                        os.run({},"programs/"..displayList[position])
                        while true do
                        e, p1, p2, p3 = os.pullEventRaw()
	  						if e == "terminate" then
  								drawDesktop()
  							elseif e == "key" then
  								if p1 == 1 then
  									drawDesktop()
  								end
  							end
  						end


                -- User clicked somewhere on the file list; move that entry to the currently-selected position.
                elseif clickedAt(0, xSize + 1, 0, ySize + 1) then
                        position = position + myEvent[4] - math.floor(ySize / 2) - 1
                        position = position > #displayList and #displayList or position
                        position = position < 1 and 1 or position
                end
        end
end


function desktop()
	desktop = true
	term.clear()
	term.setCursorPos(1,1)
	term.setBackgroundColor(256)
	term.clearLine()
	term.setTextColor(1)
	write("Menu")
	term.setBackgroundColor(2048)
	menu = true
end

function drawDesktop()
	term.setBackgroundColor(2048)
	term.clear()
	term.setCursorPos(1,1)
	term.setBackgroundColor(256)
	term.clearLine()
	term.setTextColor(1)
	write("Menu")
	menu = true
end

function programs()
	progtable = {}
	y = 0
	local FileList = fs.list("programs")
	prog = true
	term.setBackgroundColor(2048)
	term.clear()
	term.setCursorPos(1,1)
	text.cPrint("Programs", 2)
	term.setCursorPos(1,1)
	print("X")
	for _, file in ipairs(FileList) do
		table.insert(progtable, file)
	end
	Menu(progtable)
	--p = tostring(Menu(progtable))
	--shell.run("programs/"..p)
	--drawDesktop()
end

function run()
	term.setBackgroundColor(2048)
	term.clear()
	text.cPrint("Run", 2)
	text.cWrite("File Name: ", 4)
	text.cWrite("File Name: ", 4)
	name = read()
	shell.run(name)
	sleep(0.5)
	programs()
end

function shell()
	term.clear()
	shell.run("shell")
end

login()

while login do
	e, p1, p2, p3 = os.pullEventRaw()
	  if e == "terminate" then
  			drawDesktop()
  		end
	if e == "mouse_click" then
		if menu then
			if p2 >= 1 and p2 <= 4 and p3 == 1 then
					term.setBackgroundColor(256)
					term.setCursorPos(1,2)
					print("Logout")
					term.setCursorPos(1,3)
					print("Programs")
					term.setCursorPos(1,4)
					print("Close")
					term.setCursorPos(1,5)
					print("Run")
					term.setCursorPos(1,6)
					print("Shell")
				elseif p2 >= 1 and p2 <= 6 and p3 == 2 then
					os.reboot()
				elseif p2 >= 1 and p2 <= 8 and p3 == 3 then
					programs()
					menu = false
					prog = true
					login = true
				elseif p2 >= 1 and p2 <= 5 and p3 == 4 then
					drawDesktop()
				elseif p2 >= 1 and p2 <= 3 and p3 == 5 then
					run()
				elseif p2 >= 1 and p2 <= 4 and p3 == 6 then
					shell()
			end
		elseif prog then
			if p2 == 1 and p3 == 1 then
				prog = false
				drawDesktop()
			elseif p2 >= 1 and p2 <= 8 and p3 == 3 then
				pasteget()
			end
		end
	elseif e == "key" then
		if p1 == 25 then
			programs()
		end
	end
end
