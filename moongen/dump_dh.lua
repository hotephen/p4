local mg     = require "moongen"
local memory = require "memory"
local device = require "device"
local stats	 = require "stats"
local log    = require "log"
local dh	 = require "proto.dh"
-- local nsh    = require "proto.nsh"

function configure(parser)
	parser:argument("rxDev", "The device to receive from"):convert(tonumber)
end

function master(args)
	local rxDev = device.config{port = args.rxDev, dropEnable = false}
	device.waitForLinks()
	mg.startTask("dumpSlave", rxDev:getRxQueue(0))
	mg.waitForTasks()
end


function dumpSlave(queue)
	local bufs = memory.bufArray()
	local pktCtr = stats:newPktRxCounter("Packets counted", "plain")
	local total_latency = 0
	local count = 0
	while mg.running() do
		local rx = queue:tryRecv(bufs, 100)
		for i = 1, rx do
			local buf = bufs[i]
			-- buf:dump()
			local pkt = buf:getDhPacket()
			local srcmac = pkt.eth:getSrcString()
			local dstmac = pkt.eth:getDstString()
			src_pure = string.gsub(srcmac,":","") --src_pure = 1234567890AB (: -> blank)
			dst_pure = string.gsub(dstmac,":","") --dst_pure = 234567890AB1
			sb = string.sub(src_pure,5) --sb = 67890AB
			db = string.sub(dst_pure,5) --db = 7890AB1
			sint = tonumber(sb,16) -- 16->10진수로 변환
			dint = tonumber(db,16) 
			latency = dint-sint
			total_latency = total_latency + latency
			count = count + 1
			pktCtr:countPacket(buf)
		end
		if count % 100 == 0 then
			print(total_latency/count)
			count = 0
			total_latency = 0
		end
		bufs:free(rx)
		pktCtr:update()
	end
	pktCtr:finalize()
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end
