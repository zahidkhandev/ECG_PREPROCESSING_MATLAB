function [error_code,ppg_feature] = ppg_peak_detector(error_code,sample_time,PPG_Loc,VPG_Loc,APG_Loc,ppg,vpg,apg)
    num_O = PPG_Loc(1);
    num_S = PPG_Loc(2);
    num_N = PPG_Loc(3);
    num_D = PPG_Loc(4);
    num_O_next = PPG_Loc(5);
    
    num_w = VPG_Loc(1);
    num_y = VPG_Loc(2);
    num_z = VPG_Loc(3);
    num_w_next = VPG_Loc(4);
    
    num_a = APG_Loc(1);
    num_b = APG_Loc(2);
    num_c = APG_Loc(3);
    num_d = APG_Loc(4);
    num_e = APG_Loc(5);
    num_b2 = APG_Loc(6);

    ppg_feature.Total = zeros(1,125);
    if error_code == 0
        Tm_Oa = (num_a - num_O) * sample_time;
        Tm_Ow = (num_w - num_O)* sample_time;
        Tm_Ob = (num_b - num_O)* sample_time;
        Tm_OS = (num_S - num_O)* sample_time;
        Tm_Oc = (num_c - num_O)* sample_time;
        Tm_Oy = (num_y - num_O)* sample_time;
        Tm_ON = (num_N - num_O)* sample_time;
        Tm_OD = (num_D - num_O)* sample_time;
        Tss = (num_w_next - num_w)*sample_time;
        Tm_Sc = (num_c-num_S)* sample_time;
        Tm_Sd = (num_d-num_S)* sample_time;
        Tm_Se = (num_e-num_S)* sample_time;
        Tm_SD = (num_D - num_S)* sample_time;
        Tm_ND = (num_D - num_N)* sample_time;
        Tm_bb2 = (num_b2 - num_b)* sample_time;
        Tm_bc = (num_c-num_b)* sample_time;
        Tm_bd = (num_d-num_b)* sample_time;
        Tm_wb = (num_b-num_w)* sample_time;
        Tm_wS = (num_S-num_w)* sample_time;
        Tm_wc = (num_c-num_w)* sample_time;
        Tm_wd = (num_d-num_w)* sample_time;
        Tm_wz = (num_z - num_w)* sample_time;
        Tm_ac = (num_c - num_a)* sample_time;
        
        ppg_feature.TimeSpan(1) = Tm_Oa;
        ppg_feature.TimeSpan(2) = Tm_Ow;
        ppg_feature.TimeSpan(3) = Tm_Ob;
        ppg_feature.TimeSpan(4) = Tm_OS;
        ppg_feature.TimeSpan(5) = Tm_Oc;
        ppg_feature.TimeSpan(6) = Tm_Oy;
        ppg_feature.TimeSpan(7) = Tm_ON;
        ppg_feature.TimeSpan(8) = Tm_OD;
        ppg_feature.TimeSpan(9) = Tss;
        ppg_feature.TimeSpan(10) = Tm_Sc;
        ppg_feature.TimeSpan(11) = Tm_Sd;
        ppg_feature.TimeSpan(12) = Tm_Se;
        ppg_feature.TimeSpan(13) = Tm_SD;
        ppg_feature.TimeSpan(14) = Tm_ND;
        ppg_feature.TimeSpan(15) = Tm_bb2;
        ppg_feature.TimeSpan(16) = Tm_bc;
        ppg_feature.TimeSpan(17) = Tm_bd;
        ppg_feature.TimeSpan(18) = Tm_wb;
        ppg_feature.TimeSpan(19) = Tm_wS;
        ppg_feature.TimeSpan(20) = Tm_wc;
        ppg_feature.TimeSpan(21) = Tm_wd;
        ppg_feature.TimeSpan(22) = Tm_wz;
        ppg_feature.TimeSpan(23) = Tm_ac;

        AMS = ppg(num_S) - ppg(num_0);
        Am_Oa = ppg(num_a) - ppg(num_0);
        Am_Ow = ppg(num_w) - ppg(num_0);
        Am_Ob = ppg(num_b) - ppg(num_0);
        Am_Oc = ppg(num_c) - ppg(num_0);
        Am_Oy = ppg(num_y) - ppg(num_0);
        Am_O02 = ppg(num_O_next) - ppg(num_0);
        Am_OD = ppg(num_D) - ppg(num_0);
        Am_ON = ppg(num_N) - ppg(num_0);
        Am_NS = ppg(num_S) - ppg(num_N);
        
        AI_ON_AMS = Am_ON / AMS;
        AI_OD_AMS = Am_OD / AMS;
        AI_NS_AMS = Am_NS / AMS;
        AI_DS_AMS = (ppg(num_S) - ppg(num_D)) / AMS;


        ppg_feature.Amplitude(1) = AMS;
        ppg_feature.Amplitude(2) = Am_Oa;
        ppg_feature.Amplitude(3) = Am_Ow;
        ppg_feature.Amplitude(4) = Am_Ob;
        ppg_feature.Amplitude(5) = Am_Oc;
        ppg_feature.Amplitude(6) = Am_Oy;
        ppg_feature.Amplitude(7) = Am_O02;
        ppg_feature.Amplitude(8) = Am_OD;
        ppg_feature.Amplitude(9) = Am_ON;
        ppg_feature.Amplitude(10) = Am_NS;
        ppg_feature.Amplitude(11) = AI_ON_AMS;
        ppg_feature.Amplitude(12) = AI_OD_AMS;
        ppg_feature.Amplitude(13) = AI_NS_AMS;
        ppg_feature.Amplitude(14) = AI_DS_AMS;

        W = vpg(num_w);
        y = vpg(num_y);
        Z = vpg(num_z);
        a = apg(num_a);
        b = apg(num_b);
        C = apg(num_c);
        d = apg(num_d);
        e = apg(num_e);
        CC = vpg(num_c);
        dd = vpg(num_d);
        
        rzw = z / w;
        ryw = y / w;
        r_cc_w = cc / w;
        r_dd_w = dd / w;
        
        rba = b / a;
        r_c_a = c / a;
        rda = d / a;
        r_e_a = e / a;
        r_bcde_a = (b - c - d - e) / a;
        r_bcd_a = (b - c - d) / a;

        ppg_feature.VpgApg(1) = w;
        ppg_feature.VpgApg(2) = y;
        ppg_feature.VpgApg(3) = z;
        ppg_feature.VpgApg(4) = a;
        ppg_feature.VpgApg(5) = b;
        ppg_feature.VpgApg(6) = c;
        ppg_feature.VpgApg(7) = d;
        ppg_feature.VpgApg(8) = e;
        ppg_feature.VpgApg(9) = CC;

        ppg_feature.VpgApg(10) = dd;
        ppg_feature.VpgApg(11) = rzw;
        ppg_feature.VpgApg(12) = ryw;
        ppg_feature.VpgApg(13) = r_cc_w;
        ppg_feature.VpgApg(14) = r_dd_w;
        ppg_feature.VpgApg(15) = rba;
        ppg_feature.VpgApg(16) = r_c_a;
        ppg_feature.VpgApg(17) = rda;
        ppg_feature.VpgApg(18) = r_e_a;
        ppg_feature.VpgApg(19) = r_bcde_a;
        ppg_feature.VpgApg(20) = r_bcd_a;

    end
    
end