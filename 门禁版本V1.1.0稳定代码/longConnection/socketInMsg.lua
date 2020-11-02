 --- 模块功能：socket客户端数据接收处理

-- @module socketLongConnection.socketInMsg

module(...,package.seeall)

require"pins"
require "myUpdate"  --更新库   


--[[
pmd.ldoset(x,pmd.VLDO6)
x=0时：关闭LDO
x=1时：LDO输出1.8V
x=2时：LDO输出2.5V
x=3时：LDO输出2.5V
x=4时：LDO输出2.8V
x=5时：LDO输出2.9V
x=6时：LDO输出3.1V
x=7时：LDO输出3.3V
x=8时：LDO输出1.7V
]]

uartid = 2 

local s1 = 0 

xiyiPower = pins.setup(81,0)   --洗衣机主板通电控制管脚
menu = pins.setup(80,0) --模式选择
start = pins.setup(56,0) --开始暂停
power = pins.setup(61,0) --洗衣机电源
--[[
函数名：uartopn
功能  ：打开uart
参数  ：无
返回值：无
]]
function uartopn()
    uart.setup(uartid,9600,8,uart.PAR_NONE,uart.STOP_1)    --语音串口配置  	
end



-- socket客户端数据接收处理
-- @param socketClient，socket客户端对象
-- @return 处理成功返回true，处理出错返回false
-- @usage socketInMsg.proc(socketClient)
function proc(socketClient)
    local result,data
    while true do
        result,data = socketClient:recv(500)   --2000      
        --接收到数据
        if result then
            log.info("socketInMsg.proc",data)
			
          --TODO：根据需求处理data  --02000000
		                            --001 
			pins.close(pio.P1_25)
            pins.close(pio.P1_26)
            --打开uart功能
            uartopn()  
			 
			uart.write(uartid,string.char(0xAA, 0x13, 0x01, 0x1E, 0xDC))	 --音量设置   10级音量为：0xAA, 0x13, 0x01, 0x0A, 0xC8    30级音量为： 0xAA, 0x13, 0x01, 0x1E, 0xDC
			
			-- nextpox3,number1 = pack.unpack(common.hexstobins(data),">h")  --输出为100，因为短型是2个字节
            -- log.info("nextpox3",nextpox3)      
			
			
		     -- s1 = string.sub(data,2,2)
			 -- log.info("s1",s1)
			 
            --if data == "stop" 	then 		--断电
            if string.find(data,"stop")	then 
			   _G.status = 0
			   socketClient:send("IMEI:".._G.IMEI.. " success:".."OK".." menu:"..data)
			   power(0)
			   xiyiPower(0)
			   menu(0)
			   start(0)
			   
			-- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x10, 0xC3)) --0xAA, 0x07, 0x02, 0x00, 0x0E, 0xC1 --扫码成功，欢迎使用！ --0xAA, 0x07, 0x02, 0x00, 0x10, 0xC3, --门要开启一段时间
			   log.info("get 44 ")
			end 
			
			
			--if data == "standard" 	then 		--标准洗，洗衣机主板通电，电源按键，菜单按键1次，开始按键
			if string.find(data,"standard")	then 
			   _G.status = 1
			   socketClient:send("IMEI:".._G.IMEI.. " success:".."OK".." menu:"..data)
			   power(1)
			   sys.wait(3000)
			   xiyiPower(1)
			   sys.wait(1000)
			   xiyiPower(0)
			   sys.wait(1000)
			   menu(1)
			   sys.wait(500)
			   menu(0)
			   sys.wait(500)
			   start(1)
			   sys.wait(500)
			   start(0)
			   
			   --uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x04, 0xB7))  --门要关闭啦
			-- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x11, 0xC4)) --0xAA, 0x07, 0x02, 0x00, 0x0D, 0xC0 --扫码失败，请重新扫码！ --0xAA, 0x07, 0x02, 0x00, 0x11, 0xC4,  --门要关闭了
			   log.info("get 55 ")  
			end 
			
			
            --if data[1] == "quickly"  then      --快速洗
            if string.find(data,"quickly") then
			   _G.status = 1
			   socketClient:send("IMEI:".._G.IMEI.. " success:".."OK".." menu:"..data)
			   power(1)
			   sys.wait(3000)
			   xiyiPower(1)
			   sys.wait(1000)
			   xiyiPower(0)
			   sys.wait(1000)
			   menu(1)
			   sys.wait(500)
			   menu(0)
			   sys.wait(500)
			   menu(1)
			   sys.wait(500)
			   menu(0)
			   sys.wait(500)
			   start(1)
			   sys.wait(500)
			   start(0)
			end
			--if data[1] == "dry"  then      --脱水
			if string.find(data,"dry") then
			   _G.status = 1
			   socketClient:send("IMEI:".._G.IMEI.. " success:".."OK".." menu:"..data)
			   power(1)
			   sys.wait(3000)
			   xiyiPower(1)
			   sys.wait(1000)
			   xiyiPower(0)
			   sys.wait(1000)
			   for i=1,9 do
    		      menu(1)
    		      sys.wait(500)
    		      menu(0)
    		      sys.wait(500)
               end
			   sys.wait(500)
			   start(1)
			   sys.wait(500)
			   start(0)
			   
			end
			
			if string.find(data,"tfg") then
			   _G.status = 1
			   socketClient:send("IMEI:".._G.IMEI.. " success:".."OK".." menu:"..data)
			   power(1)
			   sys.wait(3000)
			   xiyiPower(1)
			   sys.wait(500)
			   xiyiPower(0)
			   sys.wait(500)
			   for i=1,10 do
    		      menu(1)
    		      sys.wait(500)
    		      menu(0)
    		      sys.wait(500)
               end
			   sys.wait(500)
			   start(1)
			   sys.wait(500)
			   start(0)
			   
			end
			--if data[1] == "suspendUp" then --暂停/启动
			if string.find(data,"suspendUp") then
				_G.status = 1
				socketClient:send("IMEI:".._G.IMEI.. " success:".."OK".." menu:"..data)
			   start(1)
			   sys.wait(500)
			   start(0)
			end
            -- if data == "update"  then  --做升级        
			
				-- setGpio61Fnc(0)     --开    	      
				-- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x03, 0xB6))  --扫码成功，欢迎使用！
				-- log.info("da_kai_b0ba0-----------Open")
				-- sys.wait(10000) --ms  --10秒
				
				-- setGpio61Fnc(1)	   --关
				-- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x04, 0xB7))  --门要关闭啦
				-- log.info("da_kai_b0ba0-----------Close") 
				-- sys.wait(10000) --ms  --10秒 
			
			-- end
			if data == "update"  then    --门禁  update 升级按钮 
           -- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x0B, 0xBE))	 --语音播报  --》 设备维护中，暂停使用！ 
            log.info("sheng__ji------------update")	    --日志 升级
            myUpdate.request(nil,"http://school.manwei.org/kangyu/SOCKET_LONG_CONNECTION_1.2.0_Luat_V0031_ASR1802_FLOAT_720H.bin") --升级更新			
			end 
					
            --如果socketOutMsg中有等待发送的数据，则立即退出本循环
            if socketOutMsg.waitForSend()   then return true end
        else
            break
        end
    end
	
    return result or data=="timeout"
end











--sys.timerLoopStart(log.info,10000,"testUpdate.version",_G.VERSION)

            -- if data == "turn"  then         
			
				-- setGpio61Fnc(1)     --开    	      
				-- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x03, 0xB6))  --扫码成功，欢迎使用！
				-- log.info("da_kai_b0ba0-----------Open")
				-- sys.wait(10000) --ms  --10秒
				
				-- setGpio61Fnc(0)	   --关
				-- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x04, 0xB7))  --使用结束，请取走衣物！
				-- log.info("da_kai_b0ba0-----------Close") 
				-- sys.wait(10000) --ms  --10秒 
			
			-- end

			-- if data == "update"  then    --门禁  update 升级按钮 
           -- -- uart.write(uartid,string.char(0xAA, 0x07, 0x02, 0x00, 0x0B, 0xBE))	 --语音播报  --》 设备维护中，暂停使用！ 
            -- log.info("sheng__ji------------update")	    --日志 升级
            -- --myUpdate.request(nil,"schoolandyouapi.aboutnew.net/pati/SOCKET_LONG_CONNECTION_1.0.0_Luat_V0025_ASR1802_720G.bin") --升级更新			
			-- end 












