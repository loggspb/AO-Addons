local FromWS, ToWS, SendEvent = userMods.FromWString, userMods.ToWString, userMods.SendEvent
local countarrows=13
------------target
local wtTarget=mainForm:GetChildChecked( "target", false )
local wtCfgTarget=mainForm:GetChildChecked( "ConfigPanelTarget", false ) -- конфигурационная панель таргета
-- local wtArrowPanel=wtCfgTarget:GetChildChecked( "ArrowPanel", false )
local wtArrowPanelTarget=wtCfgTarget:GetChildChecked( "ArrowPanel", false ) -- стрелка в панельке таргет
local wtControl3D = stateMainForm:GetChildChecked( "MainAddonMainForm", false ):GetChildChecked( "MainScreenControl3D", false )
local chBtn=mainForm:GetChildChecked( "chbtn", false ) -- чекит кнопка

local CfgMenu={}
------------------
local indSmesh=0 -- анимация по кругу 0 -вверх 1 вниз
local TargetSmesh=30 -- на сколько будит происходить смещение анимации вверх по Y
local TimeS=500 -- время анимации в мс
local TipTarget=1 -- тип стрелки
--------------------------------
function SaveCFG()
  if TipTarget then
    local t={TipTarget}
    userMods.SetAvatarConfigSection( "ArrowTargetCFG", t )
  end
end
function LoadCFG()
  local ss = userMods.GetAvatarConfigSection( "ArrowTargetCFG" )
  if ss then
    TipTarget=ss[1]
  end
end
function PosXY(wt,posX,sizeX,posY,sizeY,highPosX,highPosY)
  if wt then
    local Placement = wt:GetPlacementPlain()
    if posX then Placement.posX = posX end
    if sizeX then Placement.sizeX = sizeX end
    if posY then Placement.posY = posY end
    if sizeY then Placement.sizeY = sizeY end
    if highPosX then Placement.highPosX = posY end
    if highPosY then Placement.highPosY = sizeY end
    wt:SetPlacementPlain(Placement) 
  end
end
function PlMoove(params)
  if params.wtOwner:GetName()=="ArrowPanel" then
    local StPlacement = wtArrowPanelTarget:GetPlacementPlain()
    local EdPlacement = wtArrowPanelTarget:GetPlacementPlain()
    if indSmesh==0 then
      indSmesh=1
      EdPlacement.posY = 0
    else
      indSmesh=0
      EdPlacement.posY = TargetSmesh
    end
    wtArrowPanelTarget:PlayMoveEffect( StPlacement, EdPlacement, TimeS, EA_MONOTONOUS_INCREASE  )
  end
  
end
function ChangeTarget()
  local unitId = avatar.GetTarget()
  if unitId then
    local StPlacement = wtArrowPanelTarget:GetPlacementPlain()
    local EdPlacement = wtArrowPanelTarget:GetPlacementPlain()
    EdPlacement.posY = 0
    indSmesh=1
    wtArrowPanelTarget:PlayMoveEffect( StPlacement, EdPlacement, TimeS, EA_MONOTONOUS_INCREASE  )
    wtTarget:Show(true)
    wtControl3D:AddWidget3D( wtTarget, {sizeX=160,sizeY=260}, object.GetPos(avatar.GetId()), false, false, 175.0, WIDGET_3D_BIND_POINT_HIGH  , 0.1, 0.5 )
	-- sizeX=160 - размер стрелки по Х, sizeY - размер по Y
	-- WIDGET_3D_BIND_POINT_LOW - привязка наименьшей координаты (верхний край)
	-- WIDGET_3D_BIND_POINT_CENTER - привязка центра
	-- WIDGET_3D_BIND_POINT_HIGH - привязка наибольшей кооординаты (нижний край)
	-- 0.1 minSizeLimit - коэффициент, задающий минимальный абсолютный размер контрола (его реальный размер в пикселах на экране), при достижении этого размера контрол перестает уменьшаться (при отдалении объекта), абсолютный минимальный размер контрола - его виртуальный размер, умноженный на данный коэффициент с учетом отношения реального и виртуального размеров экранов
	-- 0.5 maxSizeLimit - коэффициент максимального размера контрола, аналогичен минимальному
    object.AttachWidget3D( unitId, wtControl3D, wtTarget,1.5 )    
  else
    wtTarget:Show(false)
  end
end
function EmptyChbtn(ind)
  for i=1,countarrows do
    CfgMenu[i].BTN:SetVariant(0)
  end
  CfgMenu[ind].BTN:SetVariant(1)
end

function ChangeArrow(ind)
  local bt=common.GetAddonRelatedTexture("arrow"..ind )
  wtTarget:AddChild(wtArrowPanelTarget)
  wtArrowPanelTarget:SetBackgroundTexture( bt )
  wtArrowPanelTarget:Show(true)
  PosXY(wtTarget,0,160,0,260+TargetSmesh,nil,nil)
  PosXY(wtArrowPanelTarget,0,160,TargetSmesh,260,nil,nil)
end
function click_chbtn(params)
  local widgetName = params.widget:GetName()
  for i=1,countarrows do                            -- выбор стрелок над целью
    if widgetName == "arrowBTN"..i then 
      TipTarget=i
      ChangeArrow(TipTarget)
      EmptyChbtn(TipTarget)
      break
    end
  end
end
function OnSlashCommand(params)
  if userMods.FromWString(params.text) == "/arrow" then
    if wtCfgTarget:IsVisible() then
      wtCfgTarget:Show(false)
      SaveCFG()
    else
      wtCfgTarget:Show(true)
    end
  end
end



function Init()

	
  LoadCFG()
  -- Панель конфига
  -- wtCfgTarget:Show(true)
  --PosXY(wtCfgTarget,400,380,150,370,nil,nil)
  PosXY(wtCfgTarget,400,760,150,370,nil,nil)
  for i=1,countarrows do
    CfgMenu[i]={
      WT  = mainForm:CreateWidgetByDesc(wtArrowPanelTarget:GetWidgetDesc()),
      BTN = mainForm:CreateWidgetByDesc(chBtn:GetWidgetDesc()),
    }
    wtCfgTarget:AddChild(CfgMenu[i].WT)
    CfgMenu[i].WT:Show(true)
    wtCfgTarget:AddChild(CfgMenu[i].BTN)
    CfgMenu[i].BTN:Show(true)
    CfgMenu[i].BTN:SetName("arrowBTN"..i)
    local bt=common.GetAddonRelatedTexture("arrow"..i )
    CfgMenu[i].WT:SetBackgroundTexture(bt)
    if TipTarget == i then
      CfgMenu[i].BTN:SetVariant(1)
    else
      CfgMenu[i].BTN:SetVariant(0)
    end
    if i<9 then
      PosXY(CfgMenu[i].WT,10+i*90-90,90,5,145,nil,nil)
      PosXY(CfgMenu[i].BTN,43+i*90-90,24,155,24,nil,nil)
    else
      -- PosXY(CfgMenu[i].WT ,5+(i-4)*90-90,90,185,145,nil,nil)
      -- PosXY(CfgMenu[i].BTN,43+(i-4)*90-90,24,335,24,nil,nil)
		PosXY(CfgMenu[i].WT ,5+(i-8)*90-90,90,185,145,nil,nil)
		PosXY(CfgMenu[i].BTN,43+(i-8)*90-90,24,335,24,nil,nil)
    end
    -- LogToChat(" "..i)
  end
  ChangeArrow(TipTarget)
  common.RegisterReactionHandler(click_chbtn, "click_chbtn")
  common.RegisterEventHandler(OnSlashCommand, "EVENT_UNKNOWN_SLASH_COMMAND")
  common.RegisterEventHandler( ChangeTarget, "EVENT_AVATAR_PRIMARY_TARGET_CHANGED" )
  common.RegisterEventHandler( ChangeTarget, "EVENT_AVATAR_TARGET_CHANGED" ) --5.0.2
  common.RegisterEventHandler( PlMoove, "EVENT_EFFECT_FINISHED" )
end

Init()
