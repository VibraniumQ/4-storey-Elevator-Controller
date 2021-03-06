// 楼层转换计时器
// counter_run run_Timer(endRun,clk4hz,clk32hz,mv2nxt);
module counter_run(endRun,CP,CP_H,StRun);
/*
** 输出列表
** count(RunCount) : 计数器(运行计数)
** endRun(endRun)  : 运行完毕信号
** 输入列表
** CP(clk4hz)      : 时钟(低频时钟)
** CP_H(clk32hz)   : 时钟(高频时钟)
** StRun(mv2nxt)   : 开始运行(移动指令)  move to next floor
*/
	input CP,CP_H,StRun;	
	output reg endRun;
	reg [2:0] count;
	
	always @ (posedge CP)
		if(!StRun) begin count <= 3'b000; end
		else
			begin
			if(count==3'd5)
				begin count<=3'd0; end
			else
				begin count<=count+1'd1; end
			end
	always @ (CP_H)
		if(!StRun) begin endRun<=0; end
		else
			begin
			if(count==3'd5)
				begin endRun<=1; end
			else
				begin endRun<=0; end
			end
			
endmodule

// 开门计时器
// counter_open open_Timer(endOpen,dispStage,clk4hz,opendoor,pause,close);
module counter_open(endOpen,dispStage,CP,StOpen,pause,close);
/*
** 输出列表
** endOpen(endOpen)     : 开门完毕
** dispStage(dispStage) : 显示状态
** 输入列表
** CP(clk4hz)           : 时钟(低频时钟)
** StOpen(opendoor)     : 开始开门(开门指令)
** pause(pause)         : 暂停关门信号
** close(close)         : 提前关门
*/
	input CP,StOpen,pause,close;	
	output reg endOpen;
	output reg [1:0] dispStage=2'b00;
	reg [6:0] count;
	reg [6:0] endTime = 7'b0010101;

	always @ (posedge CP)
		if(!StOpen) begin count <= 7'b0000000;endOpen<=0;dispStage<=2'b00; end
		else
			begin
			if(count == endTime)
				begin count<=7'd0;endOpen<=1;dispStage<=2'b00; end
			else if (close)count = endTime-7'b0000011;
            else if (pause)endTime <= endTime;
			else
				begin 
				count<=count+1'd1;endOpen<=0;
				if (count == 7'd1)dispStage<=2'b01;
				else if (count == 7'd2)dispStage<=2'b10;
				else if (count == 7'd3)dispStage<=2'b11;
				else if (count == endTime-7'b0000010)dispStage<=2'b10;
				else if (count == endTime-7'b0000001)dispStage<=2'b01;
				end
			end

endmodule

// 延迟关门按钮
// delaybutton delaybutton0(pause,clk4hz,delay)
module delaybutton(pause,CP,delay);
/*
** 输出列表
** pause(pause)         : 暂停关门信号
** 输入列表
** CP(clk4hz)           : 时钟(低频时钟)
** delay(delay)         : 延迟关门信号
*/
input delay,CP;
output reg pause=0;
reg delay_reg=0;
reg [6:0] counter;
parameter conuntEnd = 7'd20;

always @ (posedge CP)
	begin
		delay_reg <= delay|delay_reg;                      // 延迟信号进入寄存器
		if(!delay_reg) begin counter<=7'd0;pause<=0;end
		else if (delay == delay_reg) begin counter<=counter+1'b1;pause<=1;end  // 自按键开始时进行计时
		else if (counter==conuntEnd) begin counter<=7'd0;delay_reg<=0;pause<=1'b0;end // 计时结束时计数器归零，取消延迟
		else begin counter<=counter+1'b1;pause<=1;end
	end

endmodule

// 分频器
// divideclk divideclk0(clk4hz,clk32hz,mv2nxt,opendoor);
module divideclk(clk4hz,clk32hz,StRun,StOpen);
/*
** 输出列表
** clk4hz(clk4hz)   : 低频时钟
** 输入列表
** clk32hz(clk32hz) : 高频时钟
** StRun(mv2nxt)   : 开始运行(移动指令)  move to next floor
** StOpen(opendoor)     : 开始开门(开门指令)
*/
input clk32hz,StRun,StOpen;
output reg clk4hz;
reg[2:0] count=3'b000;

always @(posedge clk32hz)
	begin
		if (!StRun && !StOpen) clk4hz<=1'b1;
		else if (count==3'b111) begin clk4hz<=1'b1;count<=3'b000;end
		else begin clk4hz<=1'b0 ;count<=count+1'b1;end
	end

endmodule