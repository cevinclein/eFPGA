module eFPGA_top #(
    /* verilator lint_off UNUSEDSIGNAL */
    /* verilator lint_off UNUSEDPARAM*/

    parameter include_eFPGA = 1,
    parameter NumberOfRows = 6,
    parameter NumberOfCols = 10,
    parameter FrameBitsPerRow = 32,
    parameter MaxFramesPerCol = 20,
    parameter desync_flag = 20,
    parameter FrameSelectWidth = 5,
    parameter RowSelectWidth = 5
    /* verilator lint_on UNUSEDPARAM*/
) (
`ifdef USE_POWER_PINS
    input wire vccd1,
    input wire vssd1,
`endif
    //External IO port
    output [23:0] A_config_C,
    output [23:0] B_config_C,
    output [23:0] Config_accessC,
    output [11:0] I_top,
    input [11:0] O_top,
    output [11:0] T_top,
    //Config related ports
    input CLK,
    input resetn,
    input SelfWriteStrobe,
    input [31:0] SelfWriteData,
    input Rx,
    output ComActive,
    output ReceiveLED,
    input s_clk,
    input s_data
);
    //BlockRAM ports

    wire [96-1:0] RAM2FAB_D_I;
    wire [96-1:0] FAB2RAM_D_O;
    wire [48-1:0] FAB2RAM_A_O;
    wire [24-1:0] FAB2RAM_C_O;

    //Signal declarations
    wire [(NumberOfRows*FrameBitsPerRow)-1:0] FrameRegister;
    wire [(MaxFramesPerCol*NumberOfCols)-1:0] FrameSelect;
    wire [(FrameBitsPerRow*(NumberOfRows+2))-1:0] FrameData;
    wire [FrameBitsPerRow-1:0] FrameAddressRegister;
    wire LongFrameStrobe;
    wire [31:0] LocalWriteData;
    wire LocalWriteStrobe;
    wire [RowSelectWidth-1:0] RowSelect;
    wire resten;
`ifndef EMULATION

    eFPGA_Config #(
        .RowSelectWidth(RowSelectWidth),
        .NumberOfRows(NumberOfRows),
        .desync_flag(desync_flag),
        .FrameBitsPerRow(FrameBitsPerRow)
    ) eFPGA_Config_inst (
        .CLK(CLK),
        .resetn(resetn),
        .Rx(Rx),
        .ComActive(ComActive),
        .ReceiveLED(ReceiveLED),
        .s_clk(s_clk),
        .s_data(s_data),
        .SelfWriteData(SelfWriteData),
        .SelfWriteStrobe(SelfWriteStrobe),
        .ConfigWriteData(LocalWriteData),
        .ConfigWriteStrobe(LocalWriteStrobe),
        .FrameAddressRegister(FrameAddressRegister),
        .LongFrameStrobe(LongFrameStrobe),
        .RowSelect(RowSelect)
    );


    Frame_Data_Reg #(
        .FrameBitsPerRow(FrameBitsPerRow),
        .RowSelectWidth(RowSelectWidth),
        .Row(1)
    ) inst_Frame_Data_Reg_0 (
        .FrameData_I(LocalWriteData),
        .FrameData_O(FrameRegister[0*FrameBitsPerRow+FrameBitsPerRow-1:0*FrameBitsPerRow]),
        .RowSelect(RowSelect),
        .CLK(CLK)
    );

    Frame_Data_Reg #(
        .FrameBitsPerRow(FrameBitsPerRow),
        .RowSelectWidth(RowSelectWidth),
        .Row(2)
    ) inst_Frame_Data_Reg_1 (
        .FrameData_I(LocalWriteData),
        .FrameData_O(FrameRegister[1*FrameBitsPerRow+FrameBitsPerRow-1:1*FrameBitsPerRow]),
        .RowSelect(RowSelect),
        .CLK(CLK)
    );

    Frame_Data_Reg #(
        .FrameBitsPerRow(FrameBitsPerRow),
        .RowSelectWidth(RowSelectWidth),
        .Row(3)
    ) inst_Frame_Data_Reg_2 (
        .FrameData_I(LocalWriteData),
        .FrameData_O(FrameRegister[2*FrameBitsPerRow+FrameBitsPerRow-1:2*FrameBitsPerRow]),
        .RowSelect(RowSelect),
        .CLK(CLK)
    );

    Frame_Data_Reg #(
        .FrameBitsPerRow(FrameBitsPerRow),
        .RowSelectWidth(RowSelectWidth),
        .Row(4)
    ) inst_Frame_Data_Reg_3 (
        .FrameData_I(LocalWriteData),
        .FrameData_O(FrameRegister[3*FrameBitsPerRow+FrameBitsPerRow-1:3*FrameBitsPerRow]),
        .RowSelect(RowSelect),
        .CLK(CLK)
    );

    Frame_Data_Reg #(
        .FrameBitsPerRow(FrameBitsPerRow),
        .RowSelectWidth(RowSelectWidth),
        .Row(5)
    ) inst_Frame_Data_Reg_4 (
        .FrameData_I(LocalWriteData),
        .FrameData_O(FrameRegister[4*FrameBitsPerRow+FrameBitsPerRow-1:4*FrameBitsPerRow]),
        .RowSelect(RowSelect),
        .CLK(CLK)
    );

    Frame_Data_Reg #(
        .FrameBitsPerRow(FrameBitsPerRow),
        .RowSelectWidth(RowSelectWidth),
        .Row(6)
    ) inst_Frame_Data_Reg_5 (
        .FrameData_I(LocalWriteData),
        .FrameData_O(FrameRegister[5*FrameBitsPerRow+FrameBitsPerRow-1:5*FrameBitsPerRow]),
        .RowSelect(RowSelect),
        .CLK(CLK)
    );


    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(0)
    ) inst_Frame_Select_0 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[0*MaxFramesPerCol+MaxFramesPerCol-1:0*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(1)
    ) inst_Frame_Select_1 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[1*MaxFramesPerCol+MaxFramesPerCol-1:1*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(2)
    ) inst_Frame_Select_2 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[2*MaxFramesPerCol+MaxFramesPerCol-1:2*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(3)
    ) inst_Frame_Select_3 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[3*MaxFramesPerCol+MaxFramesPerCol-1:3*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(4)
    ) inst_Frame_Select_4 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[4*MaxFramesPerCol+MaxFramesPerCol-1:4*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(5)
    ) inst_Frame_Select_5 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[5*MaxFramesPerCol+MaxFramesPerCol-1:5*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(6)
    ) inst_Frame_Select_6 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[6*MaxFramesPerCol+MaxFramesPerCol-1:6*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(7)
    ) inst_Frame_Select_7 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[7*MaxFramesPerCol+MaxFramesPerCol-1:7*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(8)
    ) inst_Frame_Select_8 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[8*MaxFramesPerCol+MaxFramesPerCol-1:8*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );

    Frame_Select #(
        .MaxFramesPerCol(MaxFramesPerCol),
        .FrameSelectWidth(FrameSelectWidth),
        .Col(9)
    ) inst_Frame_Select_9 (
        .FrameStrobe_I(FrameAddressRegister[MaxFramesPerCol-1:0]),
        .FrameStrobe_O(FrameSelect[9*MaxFramesPerCol+MaxFramesPerCol-1:9*MaxFramesPerCol]),
        .FrameSelect  (FrameAddressRegister[FrameBitsPerRow-1:FrameBitsPerRow-FrameSelectWidth]),
        .FrameStrobe  (LongFrameStrobe)
    );


`endif
    eFPGA eFPGA_inst (
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .Tile_X0Y6_A_config_C_bit0(A_config_C[0]),
        .Tile_X0Y6_A_config_C_bit1(A_config_C[1]),
        .Tile_X0Y6_A_config_C_bit2(A_config_C[2]),
        .Tile_X0Y6_A_config_C_bit3(A_config_C[3]),
        .Tile_X0Y5_A_config_C_bit0(A_config_C[4]),
        .Tile_X0Y5_A_config_C_bit1(A_config_C[5]),
        .Tile_X0Y5_A_config_C_bit2(A_config_C[6]),
        .Tile_X0Y5_A_config_C_bit3(A_config_C[7]),
        .Tile_X0Y4_A_config_C_bit0(A_config_C[8]),
        .Tile_X0Y4_A_config_C_bit1(A_config_C[9]),
        .Tile_X0Y4_A_config_C_bit2(A_config_C[10]),
        .Tile_X0Y4_A_config_C_bit3(A_config_C[11]),
        .Tile_X0Y3_A_config_C_bit0(A_config_C[12]),
        .Tile_X0Y3_A_config_C_bit1(A_config_C[13]),
        .Tile_X0Y3_A_config_C_bit2(A_config_C[14]),
        .Tile_X0Y3_A_config_C_bit3(A_config_C[15]),
        .Tile_X0Y2_A_config_C_bit0(A_config_C[16]),
        .Tile_X0Y2_A_config_C_bit1(A_config_C[17]),
        .Tile_X0Y2_A_config_C_bit2(A_config_C[18]),
        .Tile_X0Y2_A_config_C_bit3(A_config_C[19]),
        .Tile_X0Y1_A_config_C_bit0(A_config_C[20]),
        .Tile_X0Y1_A_config_C_bit1(A_config_C[21]),
        .Tile_X0Y1_A_config_C_bit2(A_config_C[22]),
        .Tile_X0Y1_A_config_C_bit3(A_config_C[23]),
        .Tile_X0Y6_B_config_C_bit0(B_config_C[0]),
        .Tile_X0Y6_B_config_C_bit1(B_config_C[1]),
        .Tile_X0Y6_B_config_C_bit2(B_config_C[2]),
        .Tile_X0Y6_B_config_C_bit3(B_config_C[3]),
        .Tile_X0Y5_B_config_C_bit0(B_config_C[4]),
        .Tile_X0Y5_B_config_C_bit1(B_config_C[5]),
        .Tile_X0Y5_B_config_C_bit2(B_config_C[6]),
        .Tile_X0Y5_B_config_C_bit3(B_config_C[7]),
        .Tile_X0Y4_B_config_C_bit0(B_config_C[8]),
        .Tile_X0Y4_B_config_C_bit1(B_config_C[9]),
        .Tile_X0Y4_B_config_C_bit2(B_config_C[10]),
        .Tile_X0Y4_B_config_C_bit3(B_config_C[11]),
        .Tile_X0Y3_B_config_C_bit0(B_config_C[12]),
        .Tile_X0Y3_B_config_C_bit1(B_config_C[13]),
        .Tile_X0Y3_B_config_C_bit2(B_config_C[14]),
        .Tile_X0Y3_B_config_C_bit3(B_config_C[15]),
        .Tile_X0Y2_B_config_C_bit0(B_config_C[16]),
        .Tile_X0Y2_B_config_C_bit1(B_config_C[17]),
        .Tile_X0Y2_B_config_C_bit2(B_config_C[18]),
        .Tile_X0Y2_B_config_C_bit3(B_config_C[19]),
        .Tile_X0Y1_B_config_C_bit0(B_config_C[20]),
        .Tile_X0Y1_B_config_C_bit1(B_config_C[21]),
        .Tile_X0Y1_B_config_C_bit2(B_config_C[22]),
        .Tile_X0Y1_B_config_C_bit3(B_config_C[23]),
        .Tile_X9Y6_Config_accessC_bit0(Config_accessC[0]),
        .Tile_X9Y6_Config_accessC_bit1(Config_accessC[1]),
        .Tile_X9Y6_Config_accessC_bit2(Config_accessC[2]),
        .Tile_X9Y6_Config_accessC_bit3(Config_accessC[3]),
        .Tile_X9Y5_Config_accessC_bit0(Config_accessC[4]),
        .Tile_X9Y5_Config_accessC_bit1(Config_accessC[5]),
        .Tile_X9Y5_Config_accessC_bit2(Config_accessC[6]),
        .Tile_X9Y5_Config_accessC_bit3(Config_accessC[7]),
        .Tile_X9Y4_Config_accessC_bit0(Config_accessC[8]),
        .Tile_X9Y4_Config_accessC_bit1(Config_accessC[9]),
        .Tile_X9Y4_Config_accessC_bit2(Config_accessC[10]),
        .Tile_X9Y4_Config_accessC_bit3(Config_accessC[11]),
        .Tile_X9Y3_Config_accessC_bit0(Config_accessC[12]),
        .Tile_X9Y3_Config_accessC_bit1(Config_accessC[13]),
        .Tile_X9Y3_Config_accessC_bit2(Config_accessC[14]),
        .Tile_X9Y3_Config_accessC_bit3(Config_accessC[15]),
        .Tile_X9Y2_Config_accessC_bit0(Config_accessC[16]),
        .Tile_X9Y2_Config_accessC_bit1(Config_accessC[17]),
        .Tile_X9Y2_Config_accessC_bit2(Config_accessC[18]),
        .Tile_X9Y2_Config_accessC_bit3(Config_accessC[19]),
        .Tile_X9Y1_Config_accessC_bit0(Config_accessC[20]),
        .Tile_X9Y1_Config_accessC_bit1(Config_accessC[21]),
        .Tile_X9Y1_Config_accessC_bit2(Config_accessC[22]),
        .Tile_X9Y1_Config_accessC_bit3(Config_accessC[23]),
        .Tile_X9Y6_FAB2RAM_A0_O0(FAB2RAM_A_O[0]),
        .Tile_X9Y6_FAB2RAM_A0_O1(FAB2RAM_A_O[1]),
        .Tile_X9Y6_FAB2RAM_A0_O2(FAB2RAM_A_O[2]),
        .Tile_X9Y6_FAB2RAM_A0_O3(FAB2RAM_A_O[3]),
        .Tile_X9Y6_FAB2RAM_A1_O0(FAB2RAM_A_O[4]),
        .Tile_X9Y6_FAB2RAM_A1_O1(FAB2RAM_A_O[5]),
        .Tile_X9Y6_FAB2RAM_A1_O2(FAB2RAM_A_O[6]),
        .Tile_X9Y6_FAB2RAM_A1_O3(FAB2RAM_A_O[7]),
        .Tile_X9Y5_FAB2RAM_A0_O0(FAB2RAM_A_O[8]),
        .Tile_X9Y5_FAB2RAM_A0_O1(FAB2RAM_A_O[9]),
        .Tile_X9Y5_FAB2RAM_A0_O2(FAB2RAM_A_O[10]),
        .Tile_X9Y5_FAB2RAM_A0_O3(FAB2RAM_A_O[11]),
        .Tile_X9Y5_FAB2RAM_A1_O0(FAB2RAM_A_O[12]),
        .Tile_X9Y5_FAB2RAM_A1_O1(FAB2RAM_A_O[13]),
        .Tile_X9Y5_FAB2RAM_A1_O2(FAB2RAM_A_O[14]),
        .Tile_X9Y5_FAB2RAM_A1_O3(FAB2RAM_A_O[15]),
        .Tile_X9Y4_FAB2RAM_A0_O0(FAB2RAM_A_O[16]),
        .Tile_X9Y4_FAB2RAM_A0_O1(FAB2RAM_A_O[17]),
        .Tile_X9Y4_FAB2RAM_A0_O2(FAB2RAM_A_O[18]),
        .Tile_X9Y4_FAB2RAM_A0_O3(FAB2RAM_A_O[19]),
        .Tile_X9Y4_FAB2RAM_A1_O0(FAB2RAM_A_O[20]),
        .Tile_X9Y4_FAB2RAM_A1_O1(FAB2RAM_A_O[21]),
        .Tile_X9Y4_FAB2RAM_A1_O2(FAB2RAM_A_O[22]),
        .Tile_X9Y4_FAB2RAM_A1_O3(FAB2RAM_A_O[23]),
        .Tile_X9Y3_FAB2RAM_A0_O0(FAB2RAM_A_O[24]),
        .Tile_X9Y3_FAB2RAM_A0_O1(FAB2RAM_A_O[25]),
        .Tile_X9Y3_FAB2RAM_A0_O2(FAB2RAM_A_O[26]),
        .Tile_X9Y3_FAB2RAM_A0_O3(FAB2RAM_A_O[27]),
        .Tile_X9Y3_FAB2RAM_A1_O0(FAB2RAM_A_O[28]),
        .Tile_X9Y3_FAB2RAM_A1_O1(FAB2RAM_A_O[29]),
        .Tile_X9Y3_FAB2RAM_A1_O2(FAB2RAM_A_O[30]),
        .Tile_X9Y3_FAB2RAM_A1_O3(FAB2RAM_A_O[31]),
        .Tile_X9Y2_FAB2RAM_A0_O0(FAB2RAM_A_O[32]),
        .Tile_X9Y2_FAB2RAM_A0_O1(FAB2RAM_A_O[33]),
        .Tile_X9Y2_FAB2RAM_A0_O2(FAB2RAM_A_O[34]),
        .Tile_X9Y2_FAB2RAM_A0_O3(FAB2RAM_A_O[35]),
        .Tile_X9Y2_FAB2RAM_A1_O0(FAB2RAM_A_O[36]),
        .Tile_X9Y2_FAB2RAM_A1_O1(FAB2RAM_A_O[37]),
        .Tile_X9Y2_FAB2RAM_A1_O2(FAB2RAM_A_O[38]),
        .Tile_X9Y2_FAB2RAM_A1_O3(FAB2RAM_A_O[39]),
        .Tile_X9Y1_FAB2RAM_A0_O0(FAB2RAM_A_O[40]),
        .Tile_X9Y1_FAB2RAM_A0_O1(FAB2RAM_A_O[41]),
        .Tile_X9Y1_FAB2RAM_A0_O2(FAB2RAM_A_O[42]),
        .Tile_X9Y1_FAB2RAM_A0_O3(FAB2RAM_A_O[43]),
        .Tile_X9Y1_FAB2RAM_A1_O0(FAB2RAM_A_O[44]),
        .Tile_X9Y1_FAB2RAM_A1_O1(FAB2RAM_A_O[45]),
        .Tile_X9Y1_FAB2RAM_A1_O2(FAB2RAM_A_O[46]),
        .Tile_X9Y1_FAB2RAM_A1_O3(FAB2RAM_A_O[47]),
        .Tile_X9Y6_FAB2RAM_C_O0(FAB2RAM_C_O[0]),
        .Tile_X9Y6_FAB2RAM_C_O1(FAB2RAM_C_O[1]),
        .Tile_X9Y6_FAB2RAM_C_O2(FAB2RAM_C_O[2]),
        .Tile_X9Y6_FAB2RAM_C_O3(FAB2RAM_C_O[3]),
        .Tile_X9Y5_FAB2RAM_C_O0(FAB2RAM_C_O[4]),
        .Tile_X9Y5_FAB2RAM_C_O1(FAB2RAM_C_O[5]),
        .Tile_X9Y5_FAB2RAM_C_O2(FAB2RAM_C_O[6]),
        .Tile_X9Y5_FAB2RAM_C_O3(FAB2RAM_C_O[7]),
        .Tile_X9Y4_FAB2RAM_C_O0(FAB2RAM_C_O[8]),
        .Tile_X9Y4_FAB2RAM_C_O1(FAB2RAM_C_O[9]),
        .Tile_X9Y4_FAB2RAM_C_O2(FAB2RAM_C_O[10]),
        .Tile_X9Y4_FAB2RAM_C_O3(FAB2RAM_C_O[11]),
        .Tile_X9Y3_FAB2RAM_C_O0(FAB2RAM_C_O[12]),
        .Tile_X9Y3_FAB2RAM_C_O1(FAB2RAM_C_O[13]),
        .Tile_X9Y3_FAB2RAM_C_O2(FAB2RAM_C_O[14]),
        .Tile_X9Y3_FAB2RAM_C_O3(FAB2RAM_C_O[15]),
        .Tile_X9Y2_FAB2RAM_C_O0(FAB2RAM_C_O[16]),
        .Tile_X9Y2_FAB2RAM_C_O1(FAB2RAM_C_O[17]),
        .Tile_X9Y2_FAB2RAM_C_O2(FAB2RAM_C_O[18]),
        .Tile_X9Y2_FAB2RAM_C_O3(FAB2RAM_C_O[19]),
        .Tile_X9Y1_FAB2RAM_C_O0(FAB2RAM_C_O[20]),
        .Tile_X9Y1_FAB2RAM_C_O1(FAB2RAM_C_O[21]),
        .Tile_X9Y1_FAB2RAM_C_O2(FAB2RAM_C_O[22]),
        .Tile_X9Y1_FAB2RAM_C_O3(FAB2RAM_C_O[23]),
        .Tile_X9Y6_FAB2RAM_D0_O0(FAB2RAM_D_O[0]),
        .Tile_X9Y6_FAB2RAM_D0_O1(FAB2RAM_D_O[1]),
        .Tile_X9Y6_FAB2RAM_D0_O2(FAB2RAM_D_O[2]),
        .Tile_X9Y6_FAB2RAM_D0_O3(FAB2RAM_D_O[3]),
        .Tile_X9Y6_FAB2RAM_D1_O0(FAB2RAM_D_O[4]),
        .Tile_X9Y6_FAB2RAM_D1_O1(FAB2RAM_D_O[5]),
        .Tile_X9Y6_FAB2RAM_D1_O2(FAB2RAM_D_O[6]),
        .Tile_X9Y6_FAB2RAM_D1_O3(FAB2RAM_D_O[7]),
        .Tile_X9Y6_FAB2RAM_D2_O0(FAB2RAM_D_O[8]),
        .Tile_X9Y6_FAB2RAM_D2_O1(FAB2RAM_D_O[9]),
        .Tile_X9Y6_FAB2RAM_D2_O2(FAB2RAM_D_O[10]),
        .Tile_X9Y6_FAB2RAM_D2_O3(FAB2RAM_D_O[11]),
        .Tile_X9Y6_FAB2RAM_D3_O0(FAB2RAM_D_O[12]),
        .Tile_X9Y6_FAB2RAM_D3_O1(FAB2RAM_D_O[13]),
        .Tile_X9Y6_FAB2RAM_D3_O2(FAB2RAM_D_O[14]),
        .Tile_X9Y6_FAB2RAM_D3_O3(FAB2RAM_D_O[15]),
        .Tile_X9Y5_FAB2RAM_D0_O0(FAB2RAM_D_O[16]),
        .Tile_X9Y5_FAB2RAM_D0_O1(FAB2RAM_D_O[17]),
        .Tile_X9Y5_FAB2RAM_D0_O2(FAB2RAM_D_O[18]),
        .Tile_X9Y5_FAB2RAM_D0_O3(FAB2RAM_D_O[19]),
        .Tile_X9Y5_FAB2RAM_D1_O0(FAB2RAM_D_O[20]),
        .Tile_X9Y5_FAB2RAM_D1_O1(FAB2RAM_D_O[21]),
        .Tile_X9Y5_FAB2RAM_D1_O2(FAB2RAM_D_O[22]),
        .Tile_X9Y5_FAB2RAM_D1_O3(FAB2RAM_D_O[23]),
        .Tile_X9Y5_FAB2RAM_D2_O0(FAB2RAM_D_O[24]),
        .Tile_X9Y5_FAB2RAM_D2_O1(FAB2RAM_D_O[25]),
        .Tile_X9Y5_FAB2RAM_D2_O2(FAB2RAM_D_O[26]),
        .Tile_X9Y5_FAB2RAM_D2_O3(FAB2RAM_D_O[27]),
        .Tile_X9Y5_FAB2RAM_D3_O0(FAB2RAM_D_O[28]),
        .Tile_X9Y5_FAB2RAM_D3_O1(FAB2RAM_D_O[29]),
        .Tile_X9Y5_FAB2RAM_D3_O2(FAB2RAM_D_O[30]),
        .Tile_X9Y5_FAB2RAM_D3_O3(FAB2RAM_D_O[31]),
        .Tile_X9Y4_FAB2RAM_D0_O0(FAB2RAM_D_O[32]),
        .Tile_X9Y4_FAB2RAM_D0_O1(FAB2RAM_D_O[33]),
        .Tile_X9Y4_FAB2RAM_D0_O2(FAB2RAM_D_O[34]),
        .Tile_X9Y4_FAB2RAM_D0_O3(FAB2RAM_D_O[35]),
        .Tile_X9Y4_FAB2RAM_D1_O0(FAB2RAM_D_O[36]),
        .Tile_X9Y4_FAB2RAM_D1_O1(FAB2RAM_D_O[37]),
        .Tile_X9Y4_FAB2RAM_D1_O2(FAB2RAM_D_O[38]),
        .Tile_X9Y4_FAB2RAM_D1_O3(FAB2RAM_D_O[39]),
        .Tile_X9Y4_FAB2RAM_D2_O0(FAB2RAM_D_O[40]),
        .Tile_X9Y4_FAB2RAM_D2_O1(FAB2RAM_D_O[41]),
        .Tile_X9Y4_FAB2RAM_D2_O2(FAB2RAM_D_O[42]),
        .Tile_X9Y4_FAB2RAM_D2_O3(FAB2RAM_D_O[43]),
        .Tile_X9Y4_FAB2RAM_D3_O0(FAB2RAM_D_O[44]),
        .Tile_X9Y4_FAB2RAM_D3_O1(FAB2RAM_D_O[45]),
        .Tile_X9Y4_FAB2RAM_D3_O2(FAB2RAM_D_O[46]),
        .Tile_X9Y4_FAB2RAM_D3_O3(FAB2RAM_D_O[47]),
        .Tile_X9Y3_FAB2RAM_D0_O0(FAB2RAM_D_O[48]),
        .Tile_X9Y3_FAB2RAM_D0_O1(FAB2RAM_D_O[49]),
        .Tile_X9Y3_FAB2RAM_D0_O2(FAB2RAM_D_O[50]),
        .Tile_X9Y3_FAB2RAM_D0_O3(FAB2RAM_D_O[51]),
        .Tile_X9Y3_FAB2RAM_D1_O0(FAB2RAM_D_O[52]),
        .Tile_X9Y3_FAB2RAM_D1_O1(FAB2RAM_D_O[53]),
        .Tile_X9Y3_FAB2RAM_D1_O2(FAB2RAM_D_O[54]),
        .Tile_X9Y3_FAB2RAM_D1_O3(FAB2RAM_D_O[55]),
        .Tile_X9Y3_FAB2RAM_D2_O0(FAB2RAM_D_O[56]),
        .Tile_X9Y3_FAB2RAM_D2_O1(FAB2RAM_D_O[57]),
        .Tile_X9Y3_FAB2RAM_D2_O2(FAB2RAM_D_O[58]),
        .Tile_X9Y3_FAB2RAM_D2_O3(FAB2RAM_D_O[59]),
        .Tile_X9Y3_FAB2RAM_D3_O0(FAB2RAM_D_O[60]),
        .Tile_X9Y3_FAB2RAM_D3_O1(FAB2RAM_D_O[61]),
        .Tile_X9Y3_FAB2RAM_D3_O2(FAB2RAM_D_O[62]),
        .Tile_X9Y3_FAB2RAM_D3_O3(FAB2RAM_D_O[63]),
        .Tile_X9Y2_FAB2RAM_D0_O0(FAB2RAM_D_O[64]),
        .Tile_X9Y2_FAB2RAM_D0_O1(FAB2RAM_D_O[65]),
        .Tile_X9Y2_FAB2RAM_D0_O2(FAB2RAM_D_O[66]),
        .Tile_X9Y2_FAB2RAM_D0_O3(FAB2RAM_D_O[67]),
        .Tile_X9Y2_FAB2RAM_D1_O0(FAB2RAM_D_O[68]),
        .Tile_X9Y2_FAB2RAM_D1_O1(FAB2RAM_D_O[69]),
        .Tile_X9Y2_FAB2RAM_D1_O2(FAB2RAM_D_O[70]),
        .Tile_X9Y2_FAB2RAM_D1_O3(FAB2RAM_D_O[71]),
        .Tile_X9Y2_FAB2RAM_D2_O0(FAB2RAM_D_O[72]),
        .Tile_X9Y2_FAB2RAM_D2_O1(FAB2RAM_D_O[73]),
        .Tile_X9Y2_FAB2RAM_D2_O2(FAB2RAM_D_O[74]),
        .Tile_X9Y2_FAB2RAM_D2_O3(FAB2RAM_D_O[75]),
        .Tile_X9Y2_FAB2RAM_D3_O0(FAB2RAM_D_O[76]),
        .Tile_X9Y2_FAB2RAM_D3_O1(FAB2RAM_D_O[77]),
        .Tile_X9Y2_FAB2RAM_D3_O2(FAB2RAM_D_O[78]),
        .Tile_X9Y2_FAB2RAM_D3_O3(FAB2RAM_D_O[79]),
        .Tile_X9Y1_FAB2RAM_D0_O0(FAB2RAM_D_O[80]),
        .Tile_X9Y1_FAB2RAM_D0_O1(FAB2RAM_D_O[81]),
        .Tile_X9Y1_FAB2RAM_D0_O2(FAB2RAM_D_O[82]),
        .Tile_X9Y1_FAB2RAM_D0_O3(FAB2RAM_D_O[83]),
        .Tile_X9Y1_FAB2RAM_D1_O0(FAB2RAM_D_O[84]),
        .Tile_X9Y1_FAB2RAM_D1_O1(FAB2RAM_D_O[85]),
        .Tile_X9Y1_FAB2RAM_D1_O2(FAB2RAM_D_O[86]),
        .Tile_X9Y1_FAB2RAM_D1_O3(FAB2RAM_D_O[87]),
        .Tile_X9Y1_FAB2RAM_D2_O0(FAB2RAM_D_O[88]),
        .Tile_X9Y1_FAB2RAM_D2_O1(FAB2RAM_D_O[89]),
        .Tile_X9Y1_FAB2RAM_D2_O2(FAB2RAM_D_O[90]),
        .Tile_X9Y1_FAB2RAM_D2_O3(FAB2RAM_D_O[91]),
        .Tile_X9Y1_FAB2RAM_D3_O0(FAB2RAM_D_O[92]),
        .Tile_X9Y1_FAB2RAM_D3_O1(FAB2RAM_D_O[93]),
        .Tile_X9Y1_FAB2RAM_D3_O2(FAB2RAM_D_O[94]),
        .Tile_X9Y1_FAB2RAM_D3_O3(FAB2RAM_D_O[95]),
        .Tile_X0Y6_B_I_top(I_top[0]),
        .Tile_X0Y6_A_I_top(I_top[1]),
        .Tile_X0Y5_B_I_top(I_top[2]),
        .Tile_X0Y5_A_I_top(I_top[3]),
        .Tile_X0Y4_B_I_top(I_top[4]),
        .Tile_X0Y4_A_I_top(I_top[5]),
        .Tile_X0Y3_B_I_top(I_top[6]),
        .Tile_X0Y3_A_I_top(I_top[7]),
        .Tile_X0Y2_B_I_top(I_top[8]),
        .Tile_X0Y2_A_I_top(I_top[9]),
        .Tile_X0Y1_B_I_top(I_top[10]),
        .Tile_X0Y1_A_I_top(I_top[11]),
        .Tile_X0Y6_B_O_top(O_top[0]),
        .Tile_X0Y6_A_O_top(O_top[1]),
        .Tile_X0Y5_B_O_top(O_top[2]),
        .Tile_X0Y5_A_O_top(O_top[3]),
        .Tile_X0Y4_B_O_top(O_top[4]),
        .Tile_X0Y4_A_O_top(O_top[5]),
        .Tile_X0Y3_B_O_top(O_top[6]),
        .Tile_X0Y3_A_O_top(O_top[7]),
        .Tile_X0Y2_B_O_top(O_top[8]),
        .Tile_X0Y2_A_O_top(O_top[9]),
        .Tile_X0Y1_B_O_top(O_top[10]),
        .Tile_X0Y1_A_O_top(O_top[11]),
        .Tile_X9Y6_RAM2FAB_D0_I0(RAM2FAB_D_I[0]),
        .Tile_X9Y6_RAM2FAB_D0_I1(RAM2FAB_D_I[1]),
        .Tile_X9Y6_RAM2FAB_D0_I2(RAM2FAB_D_I[2]),
        .Tile_X9Y6_RAM2FAB_D0_I3(RAM2FAB_D_I[3]),
        .Tile_X9Y6_RAM2FAB_D1_I0(RAM2FAB_D_I[4]),
        .Tile_X9Y6_RAM2FAB_D1_I1(RAM2FAB_D_I[5]),
        .Tile_X9Y6_RAM2FAB_D1_I2(RAM2FAB_D_I[6]),
        .Tile_X9Y6_RAM2FAB_D1_I3(RAM2FAB_D_I[7]),
        .Tile_X9Y6_RAM2FAB_D2_I0(RAM2FAB_D_I[8]),
        .Tile_X9Y6_RAM2FAB_D2_I1(RAM2FAB_D_I[9]),
        .Tile_X9Y6_RAM2FAB_D2_I2(RAM2FAB_D_I[10]),
        .Tile_X9Y6_RAM2FAB_D2_I3(RAM2FAB_D_I[11]),
        .Tile_X9Y6_RAM2FAB_D3_I0(RAM2FAB_D_I[12]),
        .Tile_X9Y6_RAM2FAB_D3_I1(RAM2FAB_D_I[13]),
        .Tile_X9Y6_RAM2FAB_D3_I2(RAM2FAB_D_I[14]),
        .Tile_X9Y6_RAM2FAB_D3_I3(RAM2FAB_D_I[15]),
        .Tile_X9Y5_RAM2FAB_D0_I0(RAM2FAB_D_I[16]),
        .Tile_X9Y5_RAM2FAB_D0_I1(RAM2FAB_D_I[17]),
        .Tile_X9Y5_RAM2FAB_D0_I2(RAM2FAB_D_I[18]),
        .Tile_X9Y5_RAM2FAB_D0_I3(RAM2FAB_D_I[19]),
        .Tile_X9Y5_RAM2FAB_D1_I0(RAM2FAB_D_I[20]),
        .Tile_X9Y5_RAM2FAB_D1_I1(RAM2FAB_D_I[21]),
        .Tile_X9Y5_RAM2FAB_D1_I2(RAM2FAB_D_I[22]),
        .Tile_X9Y5_RAM2FAB_D1_I3(RAM2FAB_D_I[23]),
        .Tile_X9Y5_RAM2FAB_D2_I0(RAM2FAB_D_I[24]),
        .Tile_X9Y5_RAM2FAB_D2_I1(RAM2FAB_D_I[25]),
        .Tile_X9Y5_RAM2FAB_D2_I2(RAM2FAB_D_I[26]),
        .Tile_X9Y5_RAM2FAB_D2_I3(RAM2FAB_D_I[27]),
        .Tile_X9Y5_RAM2FAB_D3_I0(RAM2FAB_D_I[28]),
        .Tile_X9Y5_RAM2FAB_D3_I1(RAM2FAB_D_I[29]),
        .Tile_X9Y5_RAM2FAB_D3_I2(RAM2FAB_D_I[30]),
        .Tile_X9Y5_RAM2FAB_D3_I3(RAM2FAB_D_I[31]),
        .Tile_X9Y4_RAM2FAB_D0_I0(RAM2FAB_D_I[32]),
        .Tile_X9Y4_RAM2FAB_D0_I1(RAM2FAB_D_I[33]),
        .Tile_X9Y4_RAM2FAB_D0_I2(RAM2FAB_D_I[34]),
        .Tile_X9Y4_RAM2FAB_D0_I3(RAM2FAB_D_I[35]),
        .Tile_X9Y4_RAM2FAB_D1_I0(RAM2FAB_D_I[36]),
        .Tile_X9Y4_RAM2FAB_D1_I1(RAM2FAB_D_I[37]),
        .Tile_X9Y4_RAM2FAB_D1_I2(RAM2FAB_D_I[38]),
        .Tile_X9Y4_RAM2FAB_D1_I3(RAM2FAB_D_I[39]),
        .Tile_X9Y4_RAM2FAB_D2_I0(RAM2FAB_D_I[40]),
        .Tile_X9Y4_RAM2FAB_D2_I1(RAM2FAB_D_I[41]),
        .Tile_X9Y4_RAM2FAB_D2_I2(RAM2FAB_D_I[42]),
        .Tile_X9Y4_RAM2FAB_D2_I3(RAM2FAB_D_I[43]),
        .Tile_X9Y4_RAM2FAB_D3_I0(RAM2FAB_D_I[44]),
        .Tile_X9Y4_RAM2FAB_D3_I1(RAM2FAB_D_I[45]),
        .Tile_X9Y4_RAM2FAB_D3_I2(RAM2FAB_D_I[46]),
        .Tile_X9Y4_RAM2FAB_D3_I3(RAM2FAB_D_I[47]),
        .Tile_X9Y3_RAM2FAB_D0_I0(RAM2FAB_D_I[48]),
        .Tile_X9Y3_RAM2FAB_D0_I1(RAM2FAB_D_I[49]),
        .Tile_X9Y3_RAM2FAB_D0_I2(RAM2FAB_D_I[50]),
        .Tile_X9Y3_RAM2FAB_D0_I3(RAM2FAB_D_I[51]),
        .Tile_X9Y3_RAM2FAB_D1_I0(RAM2FAB_D_I[52]),
        .Tile_X9Y3_RAM2FAB_D1_I1(RAM2FAB_D_I[53]),
        .Tile_X9Y3_RAM2FAB_D1_I2(RAM2FAB_D_I[54]),
        .Tile_X9Y3_RAM2FAB_D1_I3(RAM2FAB_D_I[55]),
        .Tile_X9Y3_RAM2FAB_D2_I0(RAM2FAB_D_I[56]),
        .Tile_X9Y3_RAM2FAB_D2_I1(RAM2FAB_D_I[57]),
        .Tile_X9Y3_RAM2FAB_D2_I2(RAM2FAB_D_I[58]),
        .Tile_X9Y3_RAM2FAB_D2_I3(RAM2FAB_D_I[59]),
        .Tile_X9Y3_RAM2FAB_D3_I0(RAM2FAB_D_I[60]),
        .Tile_X9Y3_RAM2FAB_D3_I1(RAM2FAB_D_I[61]),
        .Tile_X9Y3_RAM2FAB_D3_I2(RAM2FAB_D_I[62]),
        .Tile_X9Y3_RAM2FAB_D3_I3(RAM2FAB_D_I[63]),
        .Tile_X9Y2_RAM2FAB_D0_I0(RAM2FAB_D_I[64]),
        .Tile_X9Y2_RAM2FAB_D0_I1(RAM2FAB_D_I[65]),
        .Tile_X9Y2_RAM2FAB_D0_I2(RAM2FAB_D_I[66]),
        .Tile_X9Y2_RAM2FAB_D0_I3(RAM2FAB_D_I[67]),
        .Tile_X9Y2_RAM2FAB_D1_I0(RAM2FAB_D_I[68]),
        .Tile_X9Y2_RAM2FAB_D1_I1(RAM2FAB_D_I[69]),
        .Tile_X9Y2_RAM2FAB_D1_I2(RAM2FAB_D_I[70]),
        .Tile_X9Y2_RAM2FAB_D1_I3(RAM2FAB_D_I[71]),
        .Tile_X9Y2_RAM2FAB_D2_I0(RAM2FAB_D_I[72]),
        .Tile_X9Y2_RAM2FAB_D2_I1(RAM2FAB_D_I[73]),
        .Tile_X9Y2_RAM2FAB_D2_I2(RAM2FAB_D_I[74]),
        .Tile_X9Y2_RAM2FAB_D2_I3(RAM2FAB_D_I[75]),
        .Tile_X9Y2_RAM2FAB_D3_I0(RAM2FAB_D_I[76]),
        .Tile_X9Y2_RAM2FAB_D3_I1(RAM2FAB_D_I[77]),
        .Tile_X9Y2_RAM2FAB_D3_I2(RAM2FAB_D_I[78]),
        .Tile_X9Y2_RAM2FAB_D3_I3(RAM2FAB_D_I[79]),
        .Tile_X9Y1_RAM2FAB_D0_I0(RAM2FAB_D_I[80]),
        .Tile_X9Y1_RAM2FAB_D0_I1(RAM2FAB_D_I[81]),
        .Tile_X9Y1_RAM2FAB_D0_I2(RAM2FAB_D_I[82]),
        .Tile_X9Y1_RAM2FAB_D0_I3(RAM2FAB_D_I[83]),
        .Tile_X9Y1_RAM2FAB_D1_I0(RAM2FAB_D_I[84]),
        .Tile_X9Y1_RAM2FAB_D1_I1(RAM2FAB_D_I[85]),
        .Tile_X9Y1_RAM2FAB_D1_I2(RAM2FAB_D_I[86]),
        .Tile_X9Y1_RAM2FAB_D1_I3(RAM2FAB_D_I[87]),
        .Tile_X9Y1_RAM2FAB_D2_I0(RAM2FAB_D_I[88]),
        .Tile_X9Y1_RAM2FAB_D2_I1(RAM2FAB_D_I[89]),
        .Tile_X9Y1_RAM2FAB_D2_I2(RAM2FAB_D_I[90]),
        .Tile_X9Y1_RAM2FAB_D2_I3(RAM2FAB_D_I[91]),
        .Tile_X9Y1_RAM2FAB_D3_I0(RAM2FAB_D_I[92]),
        .Tile_X9Y1_RAM2FAB_D3_I1(RAM2FAB_D_I[93]),
        .Tile_X9Y1_RAM2FAB_D3_I2(RAM2FAB_D_I[94]),
        .Tile_X9Y1_RAM2FAB_D3_I3(RAM2FAB_D_I[95]),
        .Tile_X0Y6_B_T_top(T_top[0]),
        .Tile_X0Y6_A_T_top(T_top[1]),
        .Tile_X0Y5_B_T_top(T_top[2]),
        .Tile_X0Y5_A_T_top(T_top[3]),
        .Tile_X0Y4_B_T_top(T_top[4]),
        .Tile_X0Y4_A_T_top(T_top[5]),
        .Tile_X0Y3_B_T_top(T_top[6]),
        .Tile_X0Y3_A_T_top(T_top[7]),
        .Tile_X0Y2_B_T_top(T_top[8]),
        .Tile_X0Y2_A_T_top(T_top[9]),
        .Tile_X0Y1_B_T_top(T_top[10]),
        .Tile_X0Y1_A_T_top(T_top[11]),
        .UserCLK(CLK),
        .FrameData(FrameData),
        .FrameStrobe(FrameSelect)
    );


    BlockRAM_1KB Inst_BlockRAM_0 (
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk(CLK),
        .rd_addr(FAB2RAM_A_O[7:0]),
        .rd_data(RAM2FAB_D_I[31:0]),
        .wr_addr(FAB2RAM_A_O[15:8]),
        .wr_data(FAB2RAM_D_O[31:0]),
        .C0(FAB2RAM_C_O[0]),
        .C1(FAB2RAM_C_O[1]),
        .C2(FAB2RAM_C_O[2]),
        .C3(FAB2RAM_C_O[3]),
        .C4(FAB2RAM_C_O[4]),
        .C5(FAB2RAM_C_O[5])
    );

    BlockRAM_1KB Inst_BlockRAM_1 (
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk(CLK),
        .rd_addr(FAB2RAM_A_O[23:16]),
        .rd_data(RAM2FAB_D_I[63:32]),
        .wr_addr(FAB2RAM_A_O[31:24]),
        .wr_data(FAB2RAM_D_O[63:32]),
        .C0(FAB2RAM_C_O[8]),
        .C1(FAB2RAM_C_O[9]),
        .C2(FAB2RAM_C_O[10]),
        .C3(FAB2RAM_C_O[11]),
        .C4(FAB2RAM_C_O[12]),
        .C5(FAB2RAM_C_O[13])
    );

    BlockRAM_1KB Inst_BlockRAM_2 (
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk(CLK),
        .rd_addr(FAB2RAM_A_O[39:32]),
        .rd_data(RAM2FAB_D_I[95:64]),
        .wr_addr(FAB2RAM_A_O[47:40]),
        .wr_data(FAB2RAM_D_O[95:64]),
        .C0(FAB2RAM_C_O[16]),
        .C1(FAB2RAM_C_O[17]),
        .C2(FAB2RAM_C_O[18]),
        .C3(FAB2RAM_C_O[19]),
        .C4(FAB2RAM_C_O[20]),
        .C5(FAB2RAM_C_O[21])
    );

    assign FrameData = {32'h12345678, FrameRegister, 32'h12345678};
endmodule
/* verilator lint_on UNUSEDSIGNAL */

