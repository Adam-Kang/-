--- 模块功能：socket客户端数据发送处理

-- @module socketLongConnection.socketOutMsg


module(...,package.seeall)

require"misc"
require"string"
require"net"
require"sim"

--数据发送的消息队列
msgQueue = {}
local getGpio19Fnc = pins.setup(78)
--提示 调用时：显示insertMsg(a nil vlaue) 是因为  声明为 local 类型了
function insertMsg(data,user)
    table.insert(msgQueue,{data=data,user=user})
end

----------------------------------心跳包-------------------------------
local function sndHeartCb(result)
    log.info("socketOutMsg.sndHeartCb",result)
    if result then sys.timerStart(sndHeart,10000) end --10s 心跳
end
 
function sndHeart()  --数据插入表
    _G.IMEI = tostring(misc.getImei() )  --获取IMEI
					
	_G.vbat_get = tostring( misc.getVbatt() )   -- 获取VBAT的电池电压 
					
	_G.Imsi_get = tostring(sim.getImsi() ) --获取sim卡的imsi

    _G.xin_hao_x = tostring(net.getRssi() )   --获取信号值

    _G.time_tt = tostring(misc.getClock() )  --获取时间

    _G.week_k = tostring(misc.getWeek() )   --获取星期

    _G.gsm_zz = tostring(net.getState() )   --获取GSM网络注册状态

    _G.sim_mm = tostring(sim.getStatus() )  --获取sim卡的状态

    _G.banben = tostring(_G.VERSION)     --获取版本 
					
	_G.Netmode = tostring(net.getNetMode())   --获取netmode

	 _G.turn = tostring(getGpio19Fnc())
    insertMsg(
	 "IMEI:".._G.IMEI..
	 " VBAT:".._G.vbat_get..
	 " IMSI:".._G.Imsi_get..
	 " XinHao:".._G.xin_hao_x..
	 " TIME:".._G.time_tt..
	 " WEEK:".._G.week_k..
	 " GSM:".._G.gsm_zz..
     " SIM:".._G.sim_mm..
     " NETMODE:".._G.Netmode..
	 " VSION:".._G.banben..
	 " turn:".._G.turn..
	 " status:".._G.status
	 ,{cb=sndHeartCb} )	
end
------------------------------------------------------------------

--- 初始化“socket客户端数据发送”
-- @return 无
-- @usage socketOutMsg.init()
function init()
    sndHeart()
    --SndJson()
	-- recGPIO()
end

--- 去初始化“socket客户端数据发送”
-- @return 无
-- @usage socketOutMsg.unInit()
function unInit()
    sys.timerStop(sndHeart) --关闭定时器
    --sys.timerStop(SndJson)
	--sys.timerStop(recGPIO)
    while #msgQueue>0 do
        local outMsg = table.remove(msgQueue,1)
        if outMsg.user and outMsg.user.cb then outMsg.user.cb(false,outMsg.user.para) end
    end
end



--- socket客户端是否有数据等待发送
-- @return 有数据等待发送返回true，否则返回false
-- @usage socketOutMsg.waitForSend()
function waitForSend()
    return #msgQueue > 0
end





--- socket客户端数据发送处理
-- @param socketClient，socket客户端对象
-- @return 处理成功返回true，处理出错返回false
-- @usage socketOutMsg.proc(socketClient)
function proc(socketClient)
    while #msgQueue>0 do
        local outMsg = table.remove(msgQueue,1)
        local result = socketClient:send(outMsg.data)
        if outMsg.user and outMsg.user.cb then outMsg.user.cb(result,outMsg.user.para) end
        if not result then sys.restart('网络中断重启')  end
    end
    return true
end



-- local function recGPIO(button)
   -- insertMsg(button)
-- end 

-- sys.subscribe("GPIO_GET",recGPIO)












--------------------Json包---------------------------
-- local torigin = 
-- {
    -- KEY1 = buttont,
    -- KEY2 = _G.Netmode,
    -- KEY3 = _G.vbat_get,
    -- KEY4 = _G.xin_hao_x,
	-- KEY5 = _G.time_tt,
	-- KEY6 = _G.week_k,
	-- KEY7 = _G.gsm_zz, 
	-- KEY8 = _G.sim_mm,
	-- KEY9 = _G.banben,
	-- KEY10 = _G.Imsi_get,
	
-- }

-- local jsondata = json.encode(torigin)

-- local function sndLocCb(result)
    -- log.info("socketOutMsg.sndLocCb",result)
    -- if result then sys.timerStart(SndJson,20000) end
-- end

-- function SndJson()
    -- insertMsg(jsondata,{cb=sndLocCb})
-- end

-----------------------结束-------------------






-- --- 模块功能：socket客户端数据发送处理
-- -- @module socketLongConnection.socketOutMsg
-- --Lua 把 false 和 nil 看作是false，其他的都为true（包括0这个值，也是相当于true）

-- module(...,package.seeall)
  
-- require"misc"
-- require"string"
-- require"net"
-- require"sim"
-- require"pins"
  

   
-- local msgQueue = {}     --数据发送的消息队列

-- button = 0  
-- uartid = 2


-- function uartopn()
    -- uart.setup(uartid,9600,8,uart.PAR_NONE,uart.STOP_1)    --语音串口配置  	
-- end

-- local function insertMsg(data)
    -- table.insert(msgQueue,{data=data,user=user})
-- end
   
-- -------------------------------  心跳包发送  -----------------------------------------

-- local function sndHeartCb(result)
    -- log.info("socketOutMsg.sndHeartCb",result)
    -- if result then sys.timerStart(sndHeart,10000) end --10s 心跳
-- end

-- function sndHeart()
    -- insertMsg("HeartData",{cb=sndHeartCb})	
-- end

-- --------------------------------------结束-------------------------------------------------


-- ---------------------------------中断检测按键-----------------------------------------
-- function gpio78IntFnc(msg)
  -- --log.info( "testGpioSingle.gpio78IntFnc",msg,getGpio78Fnc() )
    
	-- str1 = 'IMEI0292:'
	-- local kaiguan = getGpio78Fnc()    -- 获取 78管脚电平
    -- button = tostring(kaiguan)        -- 转换成字符串
	
   
    -- if msg==cpu.INT_GPIO_POSEDGE then  --上升沿中断
	-- log.info( "testGpioSingle.gpio78IntFnc-----Up",msg,getGpio78Fnc() ) -- 按键按着是：1 , 1
	-- insertMsg(str1..button,nil)       --str1..button连接两个字符串   
   
    -- else  --下降沿中断     
	-- log.info( "testGpioSingle.gpio78IntFnc-----Down",msg,getGpio78Fnc() ) --按键松开是：2 , 0
	
    -- end
-- end

-- --GPIO54配置为中断，可通过getGpio54Fnc()获取输入电平，产生中断时，自动执行gpio54IntFnc函数     
-- getGpio78Fnc = pins.setup(pio.P2_14,gpio78IntFnc)

-- ---------------------------------结束------------------------------------



-- ------------------------ 初始化“socket客户端数据发送”-------------------------
-- -- @return 无
-- -- @usage socketOutMsg.init()
-- function init()
    -- sndHeart()   --发送心跳包
   -- -- sndLoc()
   -- --sndIMEI()
-- end
-- ------------------------------------结束-------------------------------------------

-- --- 去初始化“socket客户端数据发送”
-- -- @usage socketOutMsg.unInit()
-- function unInit()
    -- sys.timerStop(sndHeart)  --关闭定时器
    -- --sys.timerStop(sndLoc)
	-- --sys.timerStop(sndIMEI)
    -- while #msgQueue>0 do
        -- local outMsg = table.remove(msgQueue,1)
        -- if outMsg.user and outMsg.user.cb then outMsg.user.cb(false,outMsg.user.para) end
    -- end
-- end


-- --- socket客户端是否有数据等待发送
-- -- @return 有数据等待发送返回true，否则返回false
-- -- @usage socketOutMsg.waitForSend()
-- function waitForSend()
    -- return #msgQueue > 0
-- end


-- --- socket 客户端数据发送处理
-- -- @param socketClient，socket客户端对象
-- -- @return 处理成功返回true，处理出错返回false
-- -- @usage socketOutMsg.proc(socketClient)
-- function proc(socketClient)
    -- while #msgQueue>0 do
        -- local outMsg = table.remove(msgQueue,1)  --移除table参数
        -- local result = socketClient:send(outMsg.data)  --发送 数据outMsg.data
		
        -- if outMsg.user and outMsg.user.cb then 
		   -- outMsg.user.cb(result,outMsg.user.para) 
		-- end
		
        -- if not result then 
		   -- return 
		-- end
    -- end
    -- return true
-- end


---------------------------------中断检测按键-------------------------------------------



--GPIO4配置为中断，可通过getGpio4Fnc()获取输入电平，产生中断时，自动执行gpio4IntFnc函数
-- getGpio78Fnc = pins.setup(pio.P2_14,gpio78IntFnc) --78-64 = 14


-- function gpio78IntFnc(msg)
     -- log.info("testGpioSingle.gpio4IntFnc",msg,getGpio78Fnc())
    -- -- 上升沿中断
     -- pins.close(pio.P1_25)
     -- pins.close(pio.P1_26)
     -- if msg==cpu.INT_GPIO_POSEDGE then
	  -- log.info("testGpioSingle.gpio78IntFnc",getGpio78Fnc())
	      -- if kaiguan == 1 then
		  -- local kaiguan = getGpio78Fnc()    -- 获取 78管脚电平 
		  -- uartopn() 
          -- uart.write(uartid,string.char(0xAA, 0x13, 0x01, 0x0A, 0xC8))	 --音量设置 为30级		
		  -- kaiguann = tostring(kaiguan)     -- 转换成字符串 
		  -- insertMsg(kaiguann,nil) 	               
		  -- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x03, 0xB6))   --0xAA, 0x07, 0x02, 0x00, 0x13, 0xC6, 叮咚声
	  -- --log.info("socketOutMsg.sndLocCb",kaiguann) 	  
      -- end 
     -- --下降沿中断		
    -- else     
	
    -- end
-- end
-------------------------------------结束-------------------------------------





   