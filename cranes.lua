-- cranes w grid integration
-- dual looper / delay
-- v0.1 @jlmitch5, built on top of cranes by @dan_derks
-- https://llllllll.co/t/21207
-- ---------------------
-- to start:
-- press key 2 to rec.
-- sounds are written to
-- two buffers.
-- one = left in.
-- two = right in.
-- press key 2 to play.
--
-- key 1 = toggle focus b/w
--         voice 1 + voice 2.
-- key 2 = toggle overwrite for
--         selected voice.
-- key 3 = voice 1 pitch bump.
-- keys 3 + 1 = erase all.
-- enc 1 = overwrite amount
--         (0 = add, 1 = clear)
-- enc 2 / 3 = loop point for
--             selected voice.
-- ////
-- head to params to find
-- speed, vol, pan
-- \\\\
--
-- grid control:
-- 1st col = tap to set focused
--           buffer.  tap again
--           to toggle overdub
-- rest    = hold two points
--           in the same half
--           of the screen to
--           set start/end of
--           the buffer

-- counting ms between key 2 taps
-- sets loop length
function count()
  rec_time = rec_time + 0.01
end

function init()
  softcut.buffer_clear()
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(0)
  softcut.level(1,1.0)
  softcut.level(2,1.0)
  softcut.level_input_cut(1, 1, 1.0)
  softcut.level_input_cut(1, 2, 0.0)
  softcut.level_input_cut(2, 1, 0.0)
  softcut.level_input_cut(2, 2, 1.0)
  softcut.pan(1, 0.7)
  softcut.pan(2, 0.3)

  softcut.play(1, 1)
  softcut.rate(1, 1)
  softcut.loop_start(1, 0)
  softcut.loop_end(1, 60)
  softcut.loop(1, 1)
  softcut.fade_time(1, 0.1)
  softcut.rec(1, 1)
  softcut.rec_level(1, 1)
  softcut.pre_level(1, 1)
  softcut.position(1, 0)
  
  softcut.play(2, 1)
  softcut.rate(2, 1)
  softcut.loop_start(2, 0)
  softcut.loop_end(2, 60)
  softcut.loop(2, 1)
  softcut.fade_time(2, 0.1)
  softcut.rec(2, 1)
  softcut.rec_level(2, 1)
  softcut.pre_level(2, 1)
  softcut.position(2, 0)
  
  softcut.phase_quant(1,0.1)
  softcut.phase_quant(2,0.1)
  softcut.event_phase(phase)

  params:add_option("speed_voice_1","speed voice 1", speedlist)
  params:set("speed_voice_1", 7)
  params:set_action("speed_voice_1", function(x) softcut.rate(1, speedlist[params:get("speed_voice_1")]) end)
  params:add_option("speed_voice_2","speed voice 2", speedlist_2)
  params:set_action("speed_voice_2",
    function(x)
      softcut.rate(2, speedlist_2[params:get("speed_voice_2")])
      is_speed_negative()
    end)
  params:set("speed_voice_2", 7)
  params:add_separator()
  params:add_control("vol_1","vol voice 1",controlspec.new(0,5,'lin',0,5,''))
  params:set_action("vol_1", function(x) softcut.level(1, x) end)
  params:set("vol_1", 1.0)
  params:add_control("vol_2","vol voice 2",controlspec.new(0,5,'lin',0,5,''))
  params:set_action("vol_2", function(x) softcut.level(2, x) end)
  params:set("vol_2", 1.0)
  params:add_separator()
  params:add_control("pan_1","pan voice 1",controlspec.new(0,1,'lin',0,1,''))
  params:set_action("pan_1", function(x) softcut.pan(1, x) end)
  params:set("pan_1", 0.7)
  params:add_control("pan_2","pan voice 2",controlspec.new(0,1,'lin',0,1,''))
  params:set_action("pan_2", function(x) softcut.pan(2, x) end)
  params:set("pan_2", 0.3)
  params:add_separator()
  params:add_number("KEY3","KEY3 ( ~~, 0.5, 1.5, 2 )",0,3,0)
  params:set_action("KEY3", function(x) KEY3 = x end)
  
  counter = metro.init(count, 0.01, -1)
  rec_time = 0

  KEY3_hold = false
  KEY1_hold = false
  KEY1_press = 0
  poll_position_1 = 0
  poll_position_2 = 0
  clear_all()
  redraw()
end

function phase(n, x)
  if n == 1 then
    poll_position_1 = x
  elseif n == 2 then
    poll_position_2 = x
  end
  redraw()
end

function is_speed_negative()
  if params:get("speed_voice_2") < 5 then
    neg_start = 0.2
    neg_end = 0.4
    if start_point_2 < 0.2 then
      start_point_2 = 0.2
      softcut.loop_start(2,0.2)
    end
    if end_point_2 < 0.5 then
      end_point_2 = 0.5
      softcut.loop_end(2,0.5)
    end
  else
    neg_start = 0.0
    neg_end = 0.0
  end
end

function warble()
  local bufSpeed1 = speedlist[params:get("speed_voice_1")]
  if bufSpeed1 > 1.99 then
      ray = bufSpeed1 + (math.random(-15,15)/1000)
    elseif bufSpeed1 >= 1.0 then
      ray = bufSpeed1 + (math.random(-10,10)/1000)
    elseif bufSpeed1 >= 0.50 then
      ray = bufSpeed1 + (math.random(-4,5)/1000)
    else
      ray = bufSpeed1 + (math.random(-2,2)/1000)
  end
    softcut.rate_slew_time(1,0.6 + (math.random(-30,10)/100))
    softcut.rate(1,ray)
    screen.move(0,30)
    screen.text(ray)
    screen.update()
end

function half_speed()
  ray = speedlist[params:get("speed_voice_1")] / 2
  softcut.rate_slew_time(1,0.6 + (math.random(-30,10)/100))
  softcut.rate(1,ray)
  screen.move(0,30)
  screen.text(ray)
  screen.update()
end

function oneandahalf_speed()
  ray = speedlist[params:get("speed_voice_1")] * 1.5
  softcut.rate_slew_time(1,0.6 + (math.random(-30,10)/100))
  softcut.rate(1,ray)
  screen.move(0,30)
  screen.text(ray)
  screen.update()
end

function double_speed()
  ray = speedlist[params:get("speed_voice_1")] * 2
  softcut.rate_slew_time(1,0.6 + (math.random(-30,10)/100))
  softcut.rate(1,ray)
  screen.move(0,30)
  screen.text(ray)
  screen.update()
end

function restore_speed()
  ray = speedlist[params:get("speed_voice_1")]
  softcut.rate_slew_time(1,0.6)
  softcut.rate(1,speedlist[params:get("speed_voice_1")])
  redraw()
end

function clear_all()
  softcut.poll_stop_phase()
  softcut.rec_level(1,1)
  softcut.rec_level(2,1)
  softcut.play(1,0)
  softcut.play(2,0)
  softcut.rate(1, 1)
  softcut.rate(2, 1)
  softcut.buffer_clear()
  ray = speedlist[params:get("speed_voice_1")]
  softcut.loop_start(1,0)
  softcut.loop_end(1,60)
  softcut.loop_start(2,0)
  softcut.loop_end(2,60)
  start_point_1 = 0
  start_point_2 = 0
  end_point_1 = 60
  end_point_2 = 60
  clear = 1
  rec_time = 0
  rec = 0
  overdubBuf1Active = false
  overdubBuf2Active = false
  mainRecordActive = false
  c2 = math.random(4,15)
  restore_speed()
  KEY3_hold = false
  softcut.position(1, 0)
  softcut.position(2, 0)
  softcut.enable(1,0)
  softcut.enable(2,0)
  bufferFocus = 1
  redraw()
end

-- variable dump
down_time = 0
hold_time = 0
speedlist = {-2.0, -1.0, -0.5, -0.25, 0.25, 0.5, 1.0, 2.0, 4.0}
speedlist_2 = {-2.0, -1.0, -0.5, -0.25, 0.25, 0.5, 1.0, 2.0, 4.0}
start_point_1 = 0
start_point_2 = 0
end_point_1 = 60
end_point_2 = 60
over = 0
clear = 1
ray = 0.0
KEY3 = 0
timeQuantUnit = 0
overdubBuf1Active = false
overdubBuf2Active = false
bufferFocus = 1
c2 = math.random(4,12)
rec = 0
g = grid.connect()

function overdubStart(buf)
  softcut.rec_level(buf,1)
  softcut.pre_level(buf,math.abs(over-1))
  if buf == 1 then
    overdubBuf1Active = true
  else
    overdubBuf2Active = true
  end
  redraw()
end

function overdubEnd(buf)
  softcut.rec_level(buf,0)
  softcut.pre_level(buf,1)
  if buf == 1 then
    overdubBuf1Active = false
  else
    overdubBuf2Active = false
  end
  redraw()
end

function focusBuffer(buf)
  rec = 0
  overdubEnd(buf % 2 + 1)
  bufferFocus = buf
  redraw()
end

function startLoop()
  softcut.buffer_clear()
  softcut.rate_slew_time(1,0.1)
  softcut.enable(1,1)
  softcut.enable(2,1)
  softcut.rate(1,1)
  softcut.rate(2,1)
  softcut.play(1,1)
  softcut.play(2,1)
  softcut.rec(1,1)
  softcut.rec(2,1)
  softcut.level(1,0)
  softcut.level(2,0)
  counter:start()
  mainRecordActive = true
  redraw()
end

function setLoop()
  clear = 0
  softcut.position(1,0)
  softcut.position(2,0)
  softcut.rec_level(1,0)
  softcut.rec_level(2,0)
  counter:stop()
  softcut.poll_start_phase()
  end_point_1 = rec_time
  end_point_2 = rec_time
  rec_time = 0
  if end_point_1 > 1 then
    timeQuantUnit = 1 + end_point_1 % 1 / math.floor(end_point_1)
  else
    timeQuantUnit = end_point_1
  end
  softcut.phase_quant(1,timeQuantUnit/10)
  softcut.phase_quant(2,timeQuantUnit/10)
  softcut.event_phase(phase)
  softcut.loop_start(1,0)
  softcut.loop_end(1,end_point_1)
  softcut.loop_start(2,0)
  softcut.loop_end(2,end_point_2)
  softcut.level(1,1)
  softcut.level(2,1)
  softcut.rate(1,speedlist[params:get("speed_voice_1")])
  softcut.rate(2,speedlist_2[params:get("speed_voice_2")])
  mainRecordActive = false
  redraw()
  -- -- voice 2's end point needs to adapt to the buffer size to avoid BOOM
  -- if end_point_1 > 0.5 then
  --   end_point_2 = end_point_1
  -- elseif end_point_1 > 0.25 then
  --   end_point_2 = 0.2 + end_point_1
  -- end
end

-- key hardware interaction
function key(n,z)
  -- KEY 2
  if n == 2 and z == 1 then
      rec = rec + 1
        -- if the buffer is clear and key 2 is pressed:
        -- main recording will enable
        if rec % 2 == 1 and clear == 1 then
          startLoop()
        -- if the buffer is clear and key 2 is pressed again:
        -- main recording will disable, loop points set
        elseif rec % 2 == 0 and clear == 1 then
          setLoop()
        end
        -- if the buffer is NOT clear and key 2 is pressed:
        -- overwrite/overdub behavior will enable
        if rec % 2 == 1 and clear == 0 and bufferFocus == 1 then
          overdubStart(1)
        -- if the buffer is NOT clear and key 2 is pressed again:
        -- overwrite/overdub behavior will disable
        elseif rec % 2 == 0 and clear == 0 and bufferFocus == 1 then
          overdubEnd(1)
        elseif rec % 2 == 1 and clear == 0 and bufferFocus == 2 then
          overdubStart(2)
        elseif rec % 2 == 0 and clear == 0 and bufferFocus == 2 then
          overdubEnd(2)
        end
  end

  -- KEY 3
  -- all based on Parameter choice
  if n == 3 and z == 1 and KEY3 == 0 then
    KEY3_hold = true
    warble()
  elseif n == 3 and z == 1 and KEY3 == 1 then
    KEY3_hold = true
    half_speed()
  elseif n == 3 and z == 1 and KEY3 == 2 then
    KEY3_hold = true
    oneandahalf_speed()
  elseif n == 3 and z == 1 and KEY3 == 3 then
    KEY3_hold = true
    double_speed()
  elseif n == 3 and z == 0 then
    KEY3_hold = false
    restore_speed()
  end

  -- KEY 1
  -- hold key 1 + key 3 to clear the buffers
  if n == 1 and z == 1 and KEY3_hold == true then
    clear_all()
    KEY1_hold = false
  elseif n == 1 and z == 1 then
    KEY1_press = KEY1_press + 1
    focusBuffer(bufferFocus % 2 + 1)
    KEY1_hold = true
    redraw()
  elseif n == 1 and z == 0 then
    KEY1_hold = false
    redraw()
  end
end

-- encoder hardware interaction
function enc(n,d)

  -- encoder 3: voice 1's loop end point
  if n == 3 and bufferFocus == 1 then
    end_point_1 = util.clamp((end_point_1 + d/10),0.0,60.0)
    softcut.loop_end(1,end_point_1)
    redraw()

  -- encoder 2: voice 1's loop start point
  elseif n == 2 and bufferFocus == 1 then
    start_point_1 = util.clamp((start_point_1 + d/10),0.0,60.0)
    softcut.loop_start(1,start_point_1)
    redraw()

-- encoder 3: voice 2's loop end point
  elseif n == 3 and bufferFocus == 2 then
    end_point_2 = util.clamp((end_point_2 + d/10),neg_end,60.0)
    softcut.loop_end(2,end_point_2)
    redraw()

-- encoder 2: voice 2's loop start point
  elseif n == 2 and bufferFocus == 2 then
    start_point_2 = util.clamp((start_point_2 + d/10),neg_start,60.0)
    softcut.loop_start(2,start_point_2)
    redraw()

  -- encoder 1: voice 1's overwrite/overdub amount
  -- 0 is full overdub
  -- 1 is full overwrite
  elseif n == 1 then
    over = util.clamp((over + d/100), 0.0,1.0)
    if KEY1_press % 2 == 0 and rec % 2 == 1 then
      softcut.pre_level(1,math.abs(over-1))
    elseif KEY1_press % 2 == 1 and rec % 2 == 1 then
      softcut.pre_level(2,math.abs(over-1))
    end
    redraw()
  end
end

-- grid coordinates to buffer position translation (assumes 128)
function bufPosToCoor(buf, pos)
  xPad = 2
  yPad = buf == 2 and 5 or 1
  return { x = xPad + math.floor(pos) % 15, y = math.floor(yPad + math.floor(pos) / 15) }
end

function coorToBufPos(x, y)
  xPad = 2
  yPad = y > 4 and 5 or 1
  buf = y > 4 and 2 or 1
  return { buf = buf, pos = (x - xPad) % 15 + (y - yPad) * 15 }
end

-- grid interaction
local press1buf1 = nil
local press2buf1 = nil
local press1buf2 = nil
local press2buf2 = nil
local overdubBuf1PressActive = 0
local overdubBuf2PressActive = 0

function g.key(x, y, z)
  if clear == 0 then
    if x ~= 1 then
      if z == 1 then
        local newPress = coorToBufPos(x, y)
        if newPress.buf == 1 then
          if press1buf1 == nil then
            press1buf1 = newPress.pos
          elseif press2buf1 == nil then
            press2buf1 = newPress.pos + 1
            if press1buf1 < press2buf1 then
              start_point_1 = press1buf1
              end_point_1 = press2buf1
            else
              start_point_1 = press2buf1 - 1
              end_point_1 = press1buf1 + 1
            end
            softcut.loop_start(1,start_point_1*timeQuantUnit)
            softcut.loop_end(1,end_point_1*timeQuantUnit)
            press1buf1 = nil
            press2buf1 = nil
          end
        else
          if press1buf2 == nil then
            press1buf2 = newPress.pos
          elseif press2buf2 == nil then
            press2buf2 = newPress.pos + 1
            if press1buf2 < press2buf2 then
              start_point_2 = press1buf2
              end_point_2 = press2buf2
            else
              start_point_2 = press2buf2 - 1
              end_point_2 = press1buf2 + 1
            end
            softcut.loop_start(2,start_point_2*timeQuantUnit)
            softcut.loop_end(2,end_point_2*timeQuantUnit)
            press1buf2 = nil
            press2buf2 = nil
          end
        end
      else
        if press1buf1 ~= nil and press2buf1 == nil then
          press1buf1 = nil
        elseif press1buf2 ~= nil and press2buf2 == nil then
          press1buf2 = nil
        end
      end
    else
      if z == 1 then
        if y <= 4 then
          if overdubBuf1PressActive == 0 then
            if bufferFocus == 1 then
              if overdubBuf1Active == false then
                focusBuffer(1)
                overdubStart(1)
              else
                overdubEnd(1)
              end
            else
              focusBuffer(1)
            end
          end
          overdubBuf1PressActive = overdubBuf1PressActive + 1
        else
          if overdubBuf2PressActive == 0 then
            if bufferFocus == 2 then
              if overdubBuf2Active == false then
                focusBuffer(2)
                overdubStart(2)
              else
                overdubEnd(2)
              end
            else
              focusBuffer(2)
            end
          end
          overdubBuf2PressActive = overdubBuf2PressActive + 1
        end
      else
        if y <= 4 then
          overdubBuf1PressActive = overdubBuf1PressActive - 1
        else
          overdubBuf2PressActive = overdubBuf2PressActive - 1
        end
      end
    end
  end
  redraw()
end

-- displaying stuff on the grid
function gridredraw()
  g:all(0)
  if clear == 0 then
    -- overdub indicators on col 1
    for i = 1,4,1 do
      g:led(1, i, overdubBuf1Active and 10 or bufferFocus == 1 and 5 or 0)
    end
    for i = 5,8,1 do
      g:led(1, i, overdubBuf2Active and 10 or bufferFocus == 2 and 5 or 0)
    end
    -- position and start/end indicators
    highlight_coor_1 = bufPosToCoor(1, math.floor(poll_position_1/timeQuantUnit + .001))
    for i = math.floor(start_point_1),math.floor(end_point_1) - 1,1 do
      i_coor = bufPosToCoor(1, i)
      if (i_coor.x == highlight_coor_1.x and i_coor.y == highlight_coor_1.y) then
        g:led(i_coor.x, i_coor.y, 15)
      else
        g:led(i_coor.x, i_coor.y, 5)
      end
    end
    highlight_coor_2 = bufPosToCoor(2, math.floor(poll_position_2/timeQuantUnit + .001))
    for i = math.floor(start_point_2),math.floor(end_point_2) - 1,1 do
      i_coor = bufPosToCoor(2, i)
      if (i_coor.x == highlight_coor_2.x and i_coor.y == highlight_coor_2.y) then
        g:led(i_coor.x, i_coor.y, 15)
      else
        g:led(i_coor.x, i_coor.y, 5)
      end
    end
  end
  g:refresh()
end

-- displaying stuff on the screen
function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0,50)
    if bufferFocus == 2 then
      screen.text("s2: "..util.round(start_point_2))
    elseif bufferFocus == 1 then
      screen.text("s1: "..util.round(start_point_1))
    end
  screen.move(0,60)
    if bufferFocus == 2 then
      screen.text("e2: "..util.round(end_point_2))
    elseif bufferFocus == 1 then
      screen.text("e1: "..util.round(end_point_1))
    end
  screen.move(0,40)
  screen.text("over: "..over)
  if mainRecordActive then
    crane()
  elseif overdubBuf1Active or overdubBuf2Active then
    crane2()
  end
  screen.level(3)
  screen.move(0,10)
  screen.text("one: "..math.floor(poll_position_1*10)/10)
  screen.move(0,20)
  screen.text("two: "..math.floor(poll_position_2*10)/10)
  screen.update()
  if g then gridredraw() end
end

-- ALL JUST CRANE DRAWING FROM HERE TO END!
function crane()
  screen.level(13)
  screen.aa(1)
  screen.line_width(0.5)
  screen.move(50,60)
  screen.line(65,40)
  screen.move(65,40)
  screen.line(100,50)
  screen.move(100,50)
  screen.line(50,60)
  screen.move(60,47)
  screen.line(48,15)
  screen.move(48,15)
  screen.line(75,40)
  screen.move(73,43)
  screen.line(85,35)
  screen.move(85,35)
  screen.line(100,50)
  screen.move(100,50)
  screen.line(105,25)
  screen.move(105,25)
  screen.line(117,35)
  screen.move(117,35)
  screen.line(104,30)
  screen.move(105,25)
  screen.line(100,30)
  screen.move(100,30)
  screen.line(95,45)
  screen.move(97,40)
  screen.line(80,20)
  screen.move(80,20)
  screen.line(70,35)
  screen.stroke()
  screen.update()
end

function crane2()
  screen.level(3)
  screen.aa(1)
  screen.line_width(0.5)
  if poll_position_1 < 10 then
    screen.move(100-(poll_position_1 * 3),60-(poll_position_2))
  elseif poll_position_1 < 40 then
    screen.move(100-(poll_position_1 * 2),60-(poll_position_2))
  else
    screen.move(100-(poll_position_1),60-(poll_position_2))
  end
  if c2 > 30 then
    screen.text(" ^ ^ ")
  elseif c2 < 30 then
  screen.text(" v v ")
  else
    screen.text(" ^ ^ ")
  end
  screen.stroke()
  screen.update()
  c2 = math.random(29,31)
end
