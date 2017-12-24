-- Warthog

-- Issues:
--
-- Potential weird behaviors if any cards are deleted
-- Currently using Mokou's character card to identify the character deck

local versionString = '24/12/2017'

local heroine_GUID = { '2dea91' }
local rival_GUID = { 'b1eec7' }
local stageBoss_basic_GUIDs = { '4fb09a', '05d5f3', 'd1943c' } --Stage Boss--
local stageBoss_extra_GUIDs = { 'a6b0d8',                      --Challenger--
                                '1c5b44',                      --Final Boss--
                                'd2bdce' }                     --Anti-Heroine--
local partner_basic_GUIDs = { '3f4b18', 'cd9fd0' } --Partner--
local partner_extra_GUIDs = { '0ee562',            --One True Partner--
                              '7538bf' }           --Ex Midboss--
local exBoss_basic_GUIDs = { '3fde74' } --Ex Boss--
local exBoss_extra_GUIDs = { 'f8f3ef',  --Phantasm Boss--
                             '65d489',  --Lone Wolf--
                             '8afe62' } --Secret Boss--

local charInCharDeck_GUID = '4ff1a0'  --A random character card that is in the character deck, used to identify the charDeck
-- local charCardsExtra_GUIDs = { '3670bb', 'e5c5d9', 'e1457f', '08491a' }
local charCardsExtra_GUIDs = {}

local seatedPlayersCounter = #getSeatedPlayers()
local numPlayers = 4

local deleteDiscardPileCondition = true
local deleteBoardCondition = true
local dealCardsCondition = true
local basicDeckOnlyCondition = false

local numOfCharToDeal = 2
local secondScanDelayTime = 0.2
local shuffleDelayTime = 1.0
local dealDelayTime = 2.0

function onload()
  local buttonWidth = 500
  local buttonHeight = 500
  local fontSize = 300

  local decreaseButton_parameters = {}
  decreaseButton_parameters.click_function = 'decreasePlayers'
  decreaseButton_parameters.function_owner = self
  decreaseButton_parameters.label = '-'
  decreaseButton_parameters.position = {-1,0.1,-2.0}
  decreaseButton_parameters.width = buttonWidth
  decreaseButton_parameters.height = buttonHeight
  decreaseButton_parameters.font_size = fontSize

  local shuffleButton_parameters = {}
  shuffleButton_parameters.click_function = 'shuffleRoleAndDealCharButton'
  shuffleButton_parameters.function_owner = self
  shuffleButton_parameters.label = tostring(numPlayers)
  shuffleButton_parameters.position = {0,0.1,-2.0}
  shuffleButton_parameters.width = buttonWidth
  shuffleButton_parameters.height = buttonHeight
  shuffleButton_parameters.font_size = fontSize

  local increaseButton_parameters = {}
  increaseButton_parameters.click_function = 'increasePlayers'
  increaseButton_parameters.function_owner = self
  increaseButton_parameters.label = '+'
  increaseButton_parameters.position = {1,0.1,-2.0}
  increaseButton_parameters.width = buttonWidth
  increaseButton_parameters.height = buttonHeight
  increaseButton_parameters.font_size = fontSize

  local lergeButtonWidth = 1480
  local largeButtonHeight = 325
  local largeFontSize = 100

  local toggleDeleteDiscardButton_parameters = {}
  toggleDeleteDiscardButton_parameters.click_function = 'toggleDeleteDiscardCondition'
  toggleDeleteDiscardButton_parameters.function_owner = self
  toggleDeleteDiscardButton_parameters.label = 'Delete unused role cards\nafter shuffle:\n' .. tostring(deleteDiscardPileCondition)
  toggleDeleteDiscardButton_parameters.position = {0,0.1,-1.1}
  toggleDeleteDiscardButton_parameters.width = lergeButtonWidth
  toggleDeleteDiscardButton_parameters.height = largeButtonHeight
  toggleDeleteDiscardButton_parameters.font_size = largeFontSize

  local toggleDeleteBoardButton_parameters = {}
  toggleDeleteBoardButton_parameters.click_function = 'toggleDeleteBoardCondition'
  toggleDeleteBoardButton_parameters.function_owner = self
  toggleDeleteBoardButton_parameters.label = 'Delete role distribution board\nafter shuffle:\n' .. tostring(deleteBoardCondition)
  toggleDeleteBoardButton_parameters.position = {0,0.1,-0.4}
  toggleDeleteBoardButton_parameters.width = lergeButtonWidth
  toggleDeleteBoardButton_parameters.height = largeButtonHeight
  toggleDeleteBoardButton_parameters.font_size = largeFontSize

  local dealCardsConditionButton_parameters = {}
  dealCardsConditionButton_parameters.click_function = 'toggleDealCardsCondition'
  dealCardsConditionButton_parameters.function_owner = self
  dealCardsConditionButton_parameters.label = 'Deal role cards after shuffle:\n' .. tostring(dealCardsCondition)
  dealCardsConditionButton_parameters.position = {0,0.1,0.3}
  dealCardsConditionButton_parameters.width = lergeButtonWidth
  dealCardsConditionButton_parameters.height = largeButtonHeight
  dealCardsConditionButton_parameters.font_size = largeFontSize

  local toggleNumOfCharToDealButton = {}
  toggleNumOfCharToDealButton.click_function = 'toggleNumOfCharToDeal'
  toggleNumOfCharToDealButton.function_owner = self
  toggleNumOfCharToDealButton.label = 'Deal ' .. numOfCharToDeal .. ' character cards per player.'
  toggleNumOfCharToDealButton.position = {0,0.1,1.0}
  toggleNumOfCharToDealButton.width = lergeButtonWidth
  toggleNumOfCharToDealButton.height = largeButtonHeight
  toggleNumOfCharToDealButton.font_size = largeFontSize

  local toggleBasicDeckButton = {}
  toggleBasicDeckButton.click_function = 'toggleBasicDeck'
  toggleBasicDeckButton.function_owner = self
  toggleBasicDeckButton.label = 'Use all role card variants.'
  toggleBasicDeckButton.position = {0,0.1,1.7}
  toggleBasicDeckButton.width = lergeButtonWidth
  toggleBasicDeckButton.height = largeButtonHeight
  toggleBasicDeckButton.font_size = largeFontSize

  -- Currently uses a blank function as a workaround
  local versionButton_parameters = {}
  versionButton_parameters.click_function = 'none'
  toggleNumOfCharToDealButton.function_owner = self
  versionButton_parameters.label = 'Version: ' .. versionString
  versionButton_parameters.position = {0,0.1,2.8}
  -- versionButton_parameters.rotation = {180,180,0}
  versionButton_parameters.width = lergeButtonWidth - 200
  versionButton_parameters.height = largeButtonHeight
  versionButton_parameters.font_size = largeFontSize

  self.createButton(decreaseButton_parameters)
  self.createButton(shuffleButton_parameters)
  self.createButton(increaseButton_parameters)

  self.createButton(toggleDeleteDiscardButton_parameters)
  self.createButton(toggleDeleteBoardButton_parameters)
  self.createButton(dealCardsConditionButton_parameters)

  self.createButton(toggleNumOfCharToDealButton)
  self.createButton(toggleBasicDeckButton)

  self.createButton(versionButton_parameters)

  onPlayerChangedColor()
end

-- Detects number of seated players to determine numPlayers automatically
function onPlayerChangedColor()
  seatedPlayersCounter=#getSeatedPlayers()
  if (seatedPlayersCounter >= 4 and seatedPlayersCounter <= 8) then
    updateNumPlayers(seatedPlayersCounter)
  end
end

function decreasePlayers()
  if (numPlayers > 4) then
    updateNumPlayers(numPlayers-1)
  end
end

function increasePlayers()
  if (numPlayers < 8) then
    updateNumPlayers(numPlayers+1)
  end
end

function updateNumPlayers(n)
  numPlayers = n
  local editedButton_parameters = {}
  editedButton_parameters.index = 1
  editedButton_parameters.label = tostring(numPlayers)
  self.editButton(editedButton_parameters)
end

function shuffleRoleAndDealCharButton()
  shuffleRoles()
  dealCharCards()
end

function shuffleRoles()
  local deckPile = {}
  local discardPile = {}

  local boardPosition = self.getPosition()
  local deckPosition = {boardPosition[1]-5, boardPosition[2], boardPosition[3]}
  local discardPosition = {boardPosition[1]+5, boardPosition[2], boardPosition[3]}
  local rotation = {0,180,180}

  -- Inserts the elements of a table into another
  local function insertTableElementsToTable( fromTable, toTable )
    if fromTable == nil or toTable == nil then
      return
    end
    for key, value in pairs( fromTable ) do
      table.insert(toTable, value)
    end
  end

  -- Code taken from https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
  local function shuffleTable( t )
    local rand = math.random
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j

    for i = iterations, 2, -1 do
      j = rand(i)
      t[i], t[j] = t[j], t[i]
    end
  end

  -- Scans through the GUIDs, adding to deckPile and discardPile based on
  -- number of roles required
  local function scanRoleGUIDs(roleGUIDs, roleNum, roleName)
    local notFoundedList = {}
    local counter = 0
    for i=1, #roleGUIDs do
      local o = getObjectFromGUID(roleGUIDs[i])
      if (counter < roleNum) then
        if (o == nil) then
          -- Searches all deck instead
          local foundDeck = findDeckWithCardGUID(roleGUIDs[i])
          if (foundDeck == nil) then
            -- print('Error: ' .. roleName .. ' card ' .. roleGUIDs[i] .. ' not found.')
            table.insert(notFoundedList, roleGUIDs[i])
          else
            o = foundDeck.takeObject({guid=roleGUIDs[i], position=deckPosition, rotation=rotation})
            table.insert(deckPile, o)
            counter = counter + 1
          end
        else
          table.insert(deckPile, o)
          counter = counter + 1
        end
      else
        if (o == nil) then
          -- Searches all deck instead
          local foundDeck = findDeckWithCardGUID(roleGUIDs[i])
          if (foundDeck != nil) then
            o = foundDeck.takeObject({guid=roleGUIDs[i], position=discardPosition, rotation=rotation})
            table.insert(discardPile, o)
          else
            table.insert(notFoundedList, roleGUIDs[i])
          end
        else
          table.insert(discardPile, o)
        end
      end
    end
    -- if(counter < roleNum) then
    --   print('Error: Required ' .. roleNum .. ' ' .. roleName .. ' cards but only found ' .. counter .. '.')
    -- end

    -- Does a second, delayed scan
    local timer_parameters = {
      identifier = 'roleDistributionSecondScanTimer' .. roleName,
      function_name = 'findNotFoundedCardsAndMove_SecondScan',
      function_owner = self,
      parameters = {notFoundedList=notFoundedList, roleNum=roleNum, roleName=roleName, counter=counter, deckPosition=deckPosition, discardPosition=discardPosition, rotation=rotation},
      delay = secondScanDelayTime,
    }
    Timer.create(timer_parameters)
  end

  local heroineNum = nil
  local partnerNum = nil
  local stageBossNum = nil
  local extraBossNum = nil
  local rivalNum = nil

  if (numPlayers == 4) then
    heroineNum = 1
    partnerNum = 0
    stageBossNum = 2
    extraBossNum = 1
    rivalNum = 0
  elseif (numPlayers == 5) then
    heroineNum = 1
    partnerNum = 1
    stageBossNum = 2
    extraBossNum = 1
    rivalNum = 0
  elseif (numPlayers == 6) then
    heroineNum = 1
    partnerNum = 1
    stageBossNum = 3
    extraBossNum = 1
    rivalNum = 0
  elseif (numPlayers == 7) then
    heroineNum = 1
    partnerNum = 2
    stageBossNum = 3
    extraBossNum = 1
    rivalNum = 0
  elseif (numPlayers == 8) then
    heroineNum = 1
    partnerNum = 2
    stageBossNum = 3
    extraBossNum = 1
    rivalNum = 1
  end

  math.randomseed( os.time() )

  local extra_GUIDs = {}

  -- Heroine, only 1
  scanRoleGUIDs(heroine_GUID, heroineNum, 'Heroine')

  -- Partner
  local partner_GUIDs = {}
  insertTableElementsToTable(partner_basic_GUIDs, partner_GUIDs)
  if not basicDeckOnlyCondition then
    insertTableElementsToTable(partner_extra_GUIDs, partner_GUIDs)
  else
    insertTableElementsToTable(partner_extra_GUIDs, extra_GUIDs)
  end
  if (partnerNum > 0) then
    shuffleTable(partner_GUIDs)
  end
  scanRoleGUIDs(partner_GUIDs, partnerNum, 'Partner')

  -- Stage Boss
  local stageBoss_GUIDs = {}
  insertTableElementsToTable(stageBoss_basic_GUIDs, stageBoss_GUIDs)
  if not basicDeckOnlyCondition then
    insertTableElementsToTable(stageBoss_extra_GUIDs, stageBoss_GUIDs)
  else
    insertTableElementsToTable(stageBoss_extra_GUIDs, extra_GUIDs)
  end
  shuffleTable(stageBoss_GUIDs)
  scanRoleGUIDs(stageBoss_GUIDs, stageBossNum, 'Stage boss')

  -- Extra Boss
  local exBoss_GUIDs = {}
  insertTableElementsToTable(exBoss_basic_GUIDs, exBoss_GUIDs)
  if not basicDeckOnlyCondition then
    insertTableElementsToTable(exBoss_extra_GUIDs, exBoss_GUIDs)
  else
    insertTableElementsToTable(exBoss_extra_GUIDs, extra_GUIDs)
  end
  shuffleTable(exBoss_GUIDs)
  scanRoleGUIDs(exBoss_GUIDs, extraBossNum, 'Extra boss')

  -- Rival
  scanRoleGUIDs(rival_GUID, rivalNum, 'Rival')

  -- Discard extra cards if basic deck only option is selected
  scanRoleGUIDs(extra_GUIDs, 0, 'Extra')

  shuffleTable(deckPile)
  for k,v in pairs(deckPile) do
    deckPile[k].setRotation(rotation)
    deckPile[k].setPosition(deckPosition)
  end

  for k,v in pairs(discardPile) do
    if (deleteDiscardPileCondition) then
      discardPile[k].destruct()
    else
      discardPile[k].setRotation(rotation)
      discardPile[k].setPosition(discardPosition)
    end
  end

  -- Shuffles the deck with heroine after shuffleDelayTime
  local timer_parameters = {
    identifier = 'roleDistributionShuffleTimer',
    function_name = 'shuffleDeckWithCardGUID',
    function_owner = self,
    parameters = {cardGUID=heroine_GUID[1]},
    delay = shuffleDelayTime,
  }
  Timer.create(timer_parameters)

  if (dealCardsCondition) then
    -- Deals the deck with heroine after dealDelayTime
    local timer_parameters = {
      identifier = 'roleDistributionDealTimer',
      function_name = 'dealDeckWithCardGUID',
      function_owner = self,
      -- parameters = {cardGUID=heroine_GUID[1], cardNum=numPlayers},
      parameters = {cardGUID=heroine_GUID[1], cardNum=1},
      delay = dealDelayTime,
    }
    Timer.create(timer_parameters)
  end

  if(deleteBoardCondition) then
    self.destruct()
  end
end

function dealCharCards()
  if (numOfCharToDeal == 0) then
    return
  end

  charDeck = findDeckWithCardGUID(charInCharDeck_GUID)
  if (charDeck == nil) then
    print('Error: Character deck with card ' .. charInCharDeck_GUID .. ' not found.')
    return
  end
  local charDeckPosition = charDeck.getPosition()
  -- local rotation = charDeck.getRotation()

  -- rotation[1] = 0

  local rotation = {0,90,180}

  charDeck.setRotation(rotation)

  -- Put the cards all over the table on to the character deck
  for i=1, #charCardsExtra_GUIDs do
    local o = getObjectFromGUID(charCardsExtra_GUIDs[i])
    if (o == nil) then
      print('Error: Character card ' .. charCardsExtra_GUIDs[i] .. ' not found.')
    else
      o.setPosition(charDeckPosition)
      o.setRotation(rotation)
    end
  end

  -- Shuffles the deck after shuffleDelayTime
  local timer_parameters = {
    identifier = 'characterShuffleTimer',
    function_name = 'shuffleDeckWithCardGUID',
    function_owner = self,
    parameters = {cardGUID=charInCharDeck_GUID},
    delay = shuffleDelayTime,
  }
  Timer.create(timer_parameters)

  -- Deals the deck with charInCharDeck_GUID card after dealDelayTime
  local timer2_parameters = {
    identifier = 'characterDealTimer',
    function_name = 'dealDeckWithCardGUID',
    function_owner = self,
    -- parameters = {cardGUID=charInCharDeck_GUID, cardNum=numPlayers*numOfCharToDeal},
    parameters = {cardGUID=charInCharDeck_GUID, cardNum=numOfCharToDeal},
    delay = dealDelayTime,
  }
  Timer.create(timer2_parameters)
end

function toggleDeleteDiscardCondition()
  deleteDiscardPileCondition = not deleteDiscardPileCondition
  local editedButton_parameters = {}
  editedButton_parameters.index = 3
  editedButton_parameters.label = 'Delete unused role cards\nafter shuffle:\n' .. tostring(deleteDiscardPileCondition)
  self.editButton(editedButton_parameters)
end

function toggleDeleteBoardCondition()
  deleteBoardCondition = not deleteBoardCondition
  local editedButton_parameters = {}
  editedButton_parameters.index = 4
  editedButton_parameters.label = 'Delete role distribution board\nafter shuffle:\n' .. tostring(deleteBoardCondition)
  self.editButton(editedButton_parameters)
end

function toggleDealCardsCondition()
  dealCardsCondition = not dealCardsCondition
  local editedButton_parameters = {}
  editedButton_parameters.index = 5
  editedButton_parameters.label = 'Deal role cards after shuffle:\n' .. tostring(dealCardsCondition)
  self.editButton(editedButton_parameters)
end

function toggleNumOfCharToDeal()
  if (numOfCharToDeal == 0) then
    updateNumOfCharToDeal(2)
  elseif (numOfCharToDeal == 2) then
    updateNumOfCharToDeal(3)
  elseif (numOfCharToDeal == 3) then
    updateNumOfCharToDeal(0)
  end
end

function updateNumOfCharToDeal(n)
  numOfCharToDeal = n
  local editedButton_parameters = {}
  editedButton_parameters.index = 6
  editedButton_parameters.label = 'Deal ' .. numOfCharToDeal .. ' character cards per player.'
  self.editButton(editedButton_parameters)
end

function toggleBasicDeck()
  basicDeckOnlyCondition = not basicDeckOnlyCondition
  local editedButton_parameters = {}
  editedButton_parameters.index = 7
  if basicDeckOnlyCondition then
    editedButton_parameters.label = 'Use basic roles only\n(Stage boss, Partner, Extra Boss).'
  else
    editedButton_parameters.label = 'Use all role card variants.'
  end
  self.editButton(editedButton_parameters)
end

-- Scans for cards that are in notFoundedList, and move them to the intended destination if can be found
-- Intended to be used as a second search with a delay after the first search
-- params {notFoundedList, roleNum, roleName, counter, deckPosition, discardPosition, rotation}
function findNotFoundedCardsAndMove_SecondScan(p)
  for i=1, #p.notFoundedList do
    local o = getObjectFromGUID(p.notFoundedList[i])
    if (p.counter < p.roleNum) then
      if (o == nil) then
        -- Searches all deck instead
        local foundDeck = findDeckWithCardGUID(p.notFoundedList[i])
        if (foundDeck == nil) then
          print('Error: ' .. p.roleName .. ' card ' .. p.notFoundedList[i] .. ' not found.')
        else
          o = foundDeck.takeObject({guid=p.notFoundedList[i], position=p.deckPosition, rotation=p.rotation})
          p.counter = p.counter + 1
        end
      else
        o.setPosition(p.deckPosition)
        o.setRotation(p.rotation)
        p.counter = p.counter + 1
      end
    else
      if (o == nil) then
        -- Searches all deck instead
        local foundDeck = findDeckWithCardGUID(p.notFoundedList[i])
        if (foundDeck != nil) then
          o = foundDeck.takeObject({guid=p.notFoundedList[i], position=p.discardPosition, rotation=p.rotation})
        end
      end
      o.setPosition(p.discardPosition)
      o.setRotation(p.rotation)
    end
  end
  if(p.counter < p.roleNum) then
    print('Error: Required ' .. p.roleNum .. ' ' .. p.roleName .. ' cards but only able to find ' .. p.counter .. '.')
  end
end

-- Shuffles the deck, specified in a table which have the variable cardGUID
function shuffleDeckWithCardGUID(p)
  if p != nil then
    local foundDeck = findDeckWithCardGUID(p.cardGUID)
    if (foundDeck != nil) then
      foundDeck.shuffle()
    else
      print('Error: Deck with card ' .. p.cardGUID .. ' not found.')
    end
  end
end

-- Deals the deck, specified in a table which have the variable cardGUID, cardNum
function dealDeckWithCardGUID(p)
  if p != nil then
    local foundDeck = findDeckWithCardGUID(p.cardGUID)
    if (foundDeck != nil) then
      foundDeck.dealToAll(p.cardNum)
    else
      print('Error: Deck with card ' .. p.cardGUID .. ' not found.')
    end
  end
end

function findDeckWithCardGUID(cardGUID)
  -- Searches for a card (specified by GUID) in a deck and returns true if exists,
  -- for which may call deck.takeObject({guid=cardGUID}) to take it
  local function isCardInDeckByGUID(cardGUID, deck)
    local cardList = deck.getObjects()
    for i, card in ipairs(cardList) do
      if card.guid == cardGUID then
        return true
      end
    end
    return false
  end

  local objectList = getAllObjects()
  for i, object in ipairs(objectList) do
    if object.tag == 'Deck' then
      if (isCardInDeckByGUID(cardGUID, object)) then
        return object
      end
    end
  end
  return nil
end