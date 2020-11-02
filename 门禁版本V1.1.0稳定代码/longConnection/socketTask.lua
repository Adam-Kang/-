--- 模块功能：socket长连接功能测试.
-- 与服务器连接成功后
--
-- 每隔10秒钟发送一次"heart data\r\n"字符串到服务器
--
-- 每隔20秒钟发送一次"location data\r\n"字符串到服务器
--
-- 与服务器断开连接后，会自动重连

-- @module socketLongConnection.testSocket1


module(...,package.seeall)

require"misc"
require"socket"
require"socketOutMsg"
require"socketInMsg"
require"pins"

local ready = false

--把下面local 去掉 试一下json格式发送
local IMEI="000000000000000"
local vbat_get="0000"
local Imsi_get="0000000000000000"
local xin_hao_x="0000"
local time_tt = {" "," "," "," "," "," ",}
local week_k="0000"
local gsm_zz="0000"
local sim_mm="0000"
local banben="0000000"
local Netmode="00"

pins.close(pio.P1_25)
pins.close(pio.P1_26)
--打开uart功能
uart.setup(2,9600,8,uart.PAR_NONE,uart.STOP_1)    --语音串口配置 
uart.write(2,string.char(0xAA, 0x13, 0x01, 0x1E, 0xDC)) --音量
_G.status = 0 --初始状态，洗衣机主板未上电
--- socket连接是否处于激活状态
-- @return 激活状态返回true，非激活状态返回false
-- @usage socketTask.isReady()
function isReady()
    return ready
end

--启动socket客户端任务
sys.taskInit(
    function()
        local retryConnectCnt = 0
        while true do
            if not socket.isReady() then
                retryConnectCnt = 0
                --等待网络环境准备就绪，超时时间是5分钟
                sys.waitUntil("IP_READY_IND",300000)
            end

            if socket.isReady() then
                --创建一个socket tcp客户端
                local socketClient = socket.tcp()
				   
                --阻塞执行socket connect动作，直至成功 
                if socketClient:connect("39.108.102.243",8090) then   --39.108.102.243  
                    retryConnectCnt = 0
                    ready = true

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
					
					--_G.SN=tostring(misc.getSn())  --获取模块序列号

					
                    socketOutMsg.init()  --发送数据
					
                    --循环处理接收和发送的数据  
                    while true do
					  --log.info("Update.version",_G.VERSION) --版本信息
                        if not socketInMsg.proc(socketClient) then 
						   log.error("socketTask.socketInMsg.proc error") 
						   break 
						end
						
                        if not socketOutMsg.proc(socketClient) then 
						   log.error("socketTask.socketOutMsg.proc error") 
						   break 
						end
                    end  
                    socketOutMsg.unInit() --去初始化 发送数据   
    
	
                    ready = false
                else
                    retryConnectCnt = retryConnectCnt + 1
                end
                --断开socket连接
                socketClient:close()
                if retryConnectCnt>=5 then link.shut() retryConnectCnt=0 end
                sys.wait(100)    --5000
            else
                --进入飞行模式，20秒之后，退出飞行模式
                net.switchFly(true)
                sys.wait(20000)
                net.switchFly(false)
            end  
        end
    end
)


--------按键输入电路设计-------------------------中断检测按键-------------------------------------------
-- function gpio78IntFnc(msg)
--   --log.info( "testGpioSingle.gpio78IntFnc",msg,getGpio78Fnc() )
    
--      --上升沿 ： 先执行上面的if 再执行下面的else   下降沿： 先执行下面的else 再执行上面的if 
--     if msg==cpu.INT_GPIO_POSEDGE then  --上升沿中断
-- 		log.info( "testGpioSingle.gpio78IntFnc-----Up",msg,getGpio78Fnc() ) -- 按键按着是：1 , 1  	     
--     else  --下降沿中断     
-- 	    log.info( "testGpioSingle.gpio78IntFnc-----Down",msg,getGpio78Fnc() ) --按键松开是：2 , 0
--         local kaiguan = getGpio78Fnc()    -- 获取 78管脚电平
-- 		button = tostring(kaiguan)        -- 转换成字符串 
-- 		uart.write(2,string.char(0xAA, 0x07, 0x02, 0x00, 0x03, 0xB6))  --dingdong	
-- 		sys.publish("GPIO_GET", button) 		
--     end
-- end

-- --GPIO54配置为中断，可通过getGpio54Fnc()获取输入电平，产生中断时，自动执行gpio54IntFnc函数     
-- getGpio78Fnc = pins.setup(pio.P2_14,gpio78IntFnc)
-- -- -------------------------------------结束----------------------------------------



-- --按键值数据上报任务
-- sys.taskInit(function()
--     while true do
--         result, data = sys.waitUntil("GPIO_GET", 3000)
--         if result == true then
--             print("rev")
--             print(data)
-- 			socketOutMsg.insertMsg("IMEI:".._G.IMEI.." turn:"..tostring(data),nil)
--         end
--         sys.wait(500)
--     end
-- end)


-- setOutputFnc = pins.setup(pio.P1_1,0)，配置GPIO 33，输出模式，默认输出低电平；
-- -- 执行setOutputFnc(0)可输出低电平，执行setOutputFnc(1)可输出高电平

-- getInputFnc = pins.setup(pio.P1_1,intFnc)，配置GPIO33，中断模式
-- -- 产生中断时自动调用intFnc(msg)函数：上升沿中断时：msg为cpu.INT_GPIO_POSEDGE；下降沿中断时：msg为cpu.INT_GPIO_NEGEDGE
-- -- 执行getInputFnc()即可获得当前电平；如果是低电平，getInputFnc()返回0；如果是高电平，getInputFnc()返回1


-- getInputFnc = pins.setup(pio.P1_1),配置GPIO33，输入模式
-- -- 执行getInputFnc()即可获得当前电平；如果是低电平，getInputFnc()返回0；如果是高电平，getInputFnc()返回1




--定时心跳
-- sys.taskInit(function()
    -- while not socket.isReady() do 
        -- sys.wait(1000)
    -- end
    -- while true do
        -- reportStatus()
        -- sys.wait(5000)
    -- end
-- end)

--最终解决办法   78端口拉低  然后判断是高电平 再判断是否为1  然后上报 数据


  