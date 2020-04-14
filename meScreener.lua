--Constants
colorMap = {{value=0, color=colors.lightBlue},
{value=1000, color=colors.cyan},
{value=5000, color=colors.blue},
{value=10000, color=colors.magenta},
{value=50000, color=colors.purple},
{value=100000, color=colors.green},
{value=500000, color=colors.lime},
{value=1000000, color=colors.yellow},
{value=5000000, color=colors.orange},
{value=10000000, color=colors.red}
}

pauseTextColor = colors.black
pauseBackgroundColor = colors.lightGray

pageBackgroundColor = colors.black
amountTextColor = colors.white
dNameTextColor = colors.white
nameTextColor = colors.gray

pagePageBackgroundColor = colors.lightGray
pagePageTextColor = colors.black

stringPause = "Pause"

maxPage = 5
pageTime = 2
stoptimeMax = 60
textScale = 0.5

--Runtime stuff
pageCounter = 0
isPaused = false
monitor = peripheral.find("monitor")
monitor.setTextScale(textScale)
term.redirect(monitor)
meBridge = peripheral.find("meBridge")

timer = 0

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function prepColor(background, text)
	term.setBackgroundColor(background)
	term.setTextColor(text)
end

function determineColor(amount)
local cc
    for i=1, #colorMap do
        if amount >= colorMap[i].value then
           cc = colorMap[i].color
        end
    end
    return cc
end

function retrieveMeData()
	meDataT = meBridge.listItems()
	while (meDataT == nil) or (meDataT[1] == nil) do
		meDataT = meBridge.listItems()
		sleep(1)
	end
	table.sort(meDataT, function(a,b) return a.amount > b.amount end)
end

function showPage(page, actualMaxPage, allEntriesCount)
	width, height = monitor.getSize()
	term.setBackgroundColor(pageBackgroundColor)
	monitor.clear()
	term.clear()
	--Write page number
	
	local pageString = page.."/"..actualMaxPage
	
	--Longest text of the amounts of items
	local amountMaxText = 0
	for i = 1, height do
		local ii = i + (page - 1) * height
		if (ii > allEntriesCount) or (meDataT[ii] == nil) then
			--Page can not be fully filled/the entry has been removed
			break
		end
		if (string.len("" .. meDataT[ii].amount) > amountMaxText) then
			amountMaxText = string.len("" .. meDataT[ii].amount)
		end
	end
	amountMaxText = amountMaxText + 3 --offset
	--Prepare and write page
	for i = 1, height do
		local ii = i + (page - 1) * height
		if (ii > allEntriesCount) or (meDataT[ii] == nil) then
			--Page can not be fully filled/the entry has been removed
			break
		end
		--Length of colored bar:
		local relCount = (width * meDataT[ii].amount) / meDataT[(page - 1) * height + 1].amount
		local stringAmount = "" .. meDataT[ii].amount
		local color = determineColor(meDataT[ii].amount)
		local dName = meDataT[ii].displayName
		local name = " (" .. meDataT[ii].name .. ")"
		paintutils.drawLine(1, i, relCount, i, color)
		--this is big oof (maybe improve later?):
		term.setCursorPos(amountMaxText - 1 - string.len(stringAmount), i)
		if (relCount < amountMaxText - string.len(stringAmount) - 1) then
			prepColor(pageBackgroundColor, amountTextColor)
			term.write(stringAmount)
		else
			prepColor(color, amountTextColor)
			if (relCount >= amountMaxText) then
				term.write(stringAmount)
			else
				term.write(string.sub(stringAmount, 1, 1 + relCount - (amountMaxText - 1 - string.len(stringAmount))))
				prepColor(pageBackgroundColor, amountTextColor)
				term.write(string.sub(stringAmount, 2 + relCount - (amountMaxText - 1 - string.len(stringAmount))))
			end
		end
		term.setCursorPos(amountMaxText, i)
		--dName
		if (relCount < amountMaxText) then
			prepColor(pageBackgroundColor, dNameTextColor)
			term.write(dName)
		else
			prepColor(color, dNameTextColor)
			term.write(string.sub(dName, 1, 1 + relCount - amountMaxText))
			if(amountMaxText + string.len(dName) >= relCount) then
				prepColor(pageBackgroundColor, dNameTextColor)
				term.write(string.sub(dName, 1 + relCount + 1 - amountMaxText))
			end
		end
		--name
		if (relCount < amountMaxText + string.len(dName)) then
			prepColor(pageBackgroundColor, nameTextColor)
			term.write(name)
		else
			prepColor(color, nameTextColor)
			term.write(string.sub(name, 1, 1 + relCount - amountMaxText - string.len(dName)))
			if (amountMaxText + string.len(name) + string.len(dName) >= relCount) then
				prepColor(pageBackgroundColor, nameTextColor)
				term.write(string.sub(name, 1 + relCount + 1 - amountMaxText - string.len(dName)))
			end
		end
	end
	prepColor(pagePageBackgroundColor, pagePageTextColor)
	term.setCursorPos(width - string.len(pageString), height)
	term.write(pageString)
end

function update()
	pageCounter = pageCounter + 1
	local w, h = monitor.getSize()
	local tl = tablelength(meDataT)
	local actualMaxPage = math.max(1, math.min(maxPage, math.ceil(tl / h)))
	if (pageCounter > actualMaxPage) then
		pageCounter = 1
	end
	retrieveMeData()
	showPage(pageCounter, actualMaxPage, tl)
end

function printPause()
	width, height = monitor.getSize()
	prepColor(pauseBackgroundColor, pauseTextColor)
	term.setCursorPos(width - string.len(stringPause) + 1, height - 1)
	term.write(stringPause)
end


function resetTimer(time)
	timer = os.startTimer(time)
end

retrieveMeData()
resetTimer(1)

while true do
	local event, p1, p2, p3, p4, p5 = os.pullEvent()
	if (event == "timer" and p1 == timer) then
		update()
		resetTimer(pageTime)
	elseif (event == "monitor_touch") then
		if (isPaused) then
			resetTimer(1)
		else
			printPause()
			resetTimer(stoptimeMax)
		end
		isPaused = not isPaused
	end
end
term.redirect(term.native())
