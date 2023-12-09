clc;
clear all;
close all;

data = load('117m.mat');
ecg = data.val(1,1:2000);
duration=length(ecg);
figure;
plot(ecg);
% only if it is mitbih dataset
%ecg = resample(ecg,360,125);

fs = 360;  % Adjusted sampling rate
time = 1:length(ecg);
tx = time ./ fs;

baseline = mean(ecg);
flpass=30;
fhpass=0.5;

y1 = lowpass(ecg,flpass,fs);
y1 = highpass(y1,fhpass,fs);    
fprintf("BASELINE: %d", baseline);

waveletType = 'db1';

wt = modwt(y1, 9, waveletType);
wtrec = zeros(size(wt));
wtrec(3:4, :) = wt(3:4, :);
y = imodwt(wtrec, waveletType);
g=abs(y);
avg = mean(g);
figure;
plot(y);
tt = modwt(ecg, 9, waveletType);
twtrec = zeros(size(wt));
twtrec(5:7,:) = tt(5:7, :);
tp = imodwt(twtrec, waveletType);

[~, R_loc] = findpeaks(y, 'MinPeakHeight', 8* avg, 'MinPeakDistance', 100);    

   % [~, R_loc] = findpeaks(y1, 'MinPeakHeight', min_peak_height);
    
    beatPeriod = duration / length(R_loc);
    Ac_R_points = NaN(size(R_loc));
    % Initialize arrays to store P, Q, S, and T points
    P_points = NaN(size(R_loc));
    Q_points = NaN(size(R_loc));
    S_points = NaN(size(R_loc));
    T_points = NaN(size(R_loc));

    R_window_size = 4; % 82 ms
    for i = 1:length(R_loc)
        r_peak=(R_loc(i));
        R_window = y1(max(1, r_peak - R_window_size):min(length(y1), r_peak + R_window_size));
        if y1(r_peak)>0
        [~,actual_r_index]=max(R_window);
        end 
        if  y1(r_peak)<0
        [~,actual_r_index]=min(R_window);
        end 

         if isempty(actual_r_index)
            actal_r_index=0;
         end
       Ac_R_points(i) = max(1, r_peak - R_window_size) + actual_r_index - 1; 
    end 
    % Define the intervals for Q, S, P, and T point detection
    QRS_interval = round(0.10 * fs ); % 82 ms
    P_interval = round(0.22 * fs );  % 220 ms
    T_interval = round(0.350 * fs );  % 440 ms

    % Initialize an array to store RR intervals
    RR_intervals = NaN(size(R_loc) - 1);
    y = abs(y) ;
    figure;
    plot(y);
    % Detect Q, S, P, and T points
    for i = 1:length(R_loc)
        r_peak = (Ac_R_points(i));

        % Detect Q point (smallest amplitude in the 82 ms preceding the R-peak)
        q_window = y(max(1, r_peak - QRS_interval):r_peak-1);
        [~, q_index] = findpeaks (q_window,'NPeaks', 1,'SortStr','descend');
         if isempty(q_index)
            q_index=0;
         end
         % if y1(r_peak)>0
         %     [~,q_index]=min(q_window);
         % end 
         %  if y1(r_peak)<0
         %     [~,q_index]=max(q_window);
         % end 
        Q_points(i) = max(1, r_peak - QRS_interval) + q_index - 1;

        % Detect S point (smallest amplitude in the 82 ms following the R-peak)
        s_window = y(r_peak+1:min(length(y), r_peak + QRS_interval));
        [~, s_index] = findpeaks(s_window,'NPeaks', 1,'SortStr','descend');
         if isempty(s_index)
            s_index=0;
         end
         % if y1(r_peak)>0
         %     [~,s_index]=min(s_window);
         % end 
         %  if y1(r_peak)<0
         %     [~,s_index]=max(s_window);
         % end 

        S_points(i) = r_peak + s_index - 1;

        % Detect P point (biggest amplitude in the 198 ms prior to the Q point)
        p_window = tp(max(1, Q_points(i) - P_interval):Q_points(i)-1);
        [~, p_index] = findpeaks(p_window,'NPeaks', 1,'SortStr','descend');
        % P_point_candidate = max(1, Q_points(i) - P_interval) + p_index - 1;
        % P_points(i) = P_point_candidate;
        if isempty(p_index)
            p_index=0;
        end
         P_points(i) = max(1, Q_points(i) - P_interval) + p_index - 1;

        % if (P_point_candidate) <=  0.1 * (r_peak)
        %     invalid_P_Count = invalid_P_Count + 1;
        % end

        % Detect T point (biggest amplitude in the 398 ms next to the S point)
        t_window = tp(S_points(i)+1:min(length(tp), S_points(i) + T_interval));
       [~, t_index] = findpeaks(t_window,'NPeaks', 1,'SortStr','descend');
        if isempty(t_index)
            t_index=0;
        end
        T_points(i) = S_points(i) + t_index - 1;

        % If this is the first R-peak, skip RR interval calculation
        if i == 1
            continue;
        end

        RR_intervals(i - 1) = Ac_R_points(i) - Ac_R_points(i - 1);
    end

    % Plot ECG with PQRST points
    figure;
    plot(tx, y1, 'r');
    hold on;

    % Plot R peaks
    scatter(tx(round(Ac_R_points)), y1(round(Ac_R_points)), 'ko', 'filled', 'DisplayName', 'R Peaks');

    % Plot P point
    valid_P_points = P_points(~isnan(P_points));
    valid_P_points=nonzeros(valid_P_points);
    scatter(tx(valid_P_points), y1(valid_P_points), 'ro', 'filled', 'DisplayName', 'P Points');

    % Plot Q, S, and T points
    valid_Q_points = Q_points(~isnan(Q_points));
    valid_S_points = S_points(~isnan(S_points));
    valid_T_points = T_points(~isnan(T_points));
    scatter(tx(valid_Q_points), y1(valid_Q_points), 'go', 'filled', 'DisplayName', 'Q Points');
    scatter(tx(valid_S_points), y1(valid_S_points), 'bo', 'filled', 'DisplayName', 'S Points');
    scatter(tx(valid_T_points), y1(valid_T_points), 'co', 'filled', 'DisplayName', 'T Points');


    Q_points = round(Q_points ./2.88);

    % Ground truth Q points
    ground_truth = [128, 536, 945, 1347, 1772, 2183, 2614, 3043, 3465, 3896, 4317, 4737, 5172, 5603, 6034, 6488, 6921, 7368, 7800, 8258, 8699, 9144, 9586, 10016, 10454, 10863, 11283, 11699, 12119, 12564, 13004, 13440, 13887, 14327, 14775, 15211, 15650, 16086, 16515, 16960, 17390, 17825, 18281, 18711, 19163, 19601, 20044, 20476, 20920, 21355, 21794, 22231, 22673, 23108, 23550, 23983, 24423, 24836, 25268, 25690, 26108, 26549, 26973, 27404, 27832, 28270, 28712, 29135, 29580, 29988, 30422, 30847, 31281, 31722, 32167, 32617, 33052, 33500, 33940, 34388, 34819, 35267, 35696, 36121, 36565, 37005, 37441, 37876, 38312, 38736, 39158, 39592, 40021, 40453, 40890, 41328, 41764, 42185, 42627, 43050, 43479, 43901, 44319, 44745, 45163, 45602, 46028, 46459, 46903, 47334, 47763, 48196, 48622, 49065, 49506, 49941, 50373, 50799, 51237, 51656, 52088, 52510, 52918, 53350, 53775, 54202, 54633, 55063, 55497, 55920, 56341, 56760, 57180, 57598, 58039, 58474, 58938, 59377, 59831, 60275, 60720, 61175, 61614, 62067, 62499, 62947, 63373, 63805, 64238, 64655, 65075, 65498, 65915, 66332, 66757, 67187, 67604, 68029, 68462, 68872, 69302, 69725, 70154, 70590, 71008, 71444, 71862, 72294, 72727, 73149, 73590, 74015, 74453, 74886, 75313, 75739, 76156, 76570, 77002, 77414, 77831, 78253, 78661, 79078, 79486, 79905, 80315, 80730, 81160, 81574, 82007, 82427, 82863, 83288, 83712, 84142, 84561, 84979, 85400, 85813, 86239, 86660, 87094, 87528, 87957, 88401, 88828, 89266, 89701, 90124, 90573, 90999, 91441, 91869, 92318, 92752, 93199, 93634, 94073, 94508, 94935, 95370, 95789, 96219, 96641, 97068, 97493, 97910, 98335, 98752, 99173, 99604, 100038, 100471, 100914, 101348, 101792, 102213, 102642, 103072, 103492, 103918, 104343, 104768, 105203, 105630, 106066, 106488, 106921, 107348, 107778, 108200, 108631, 109053, 109487, 109906, 110337, 110757, 111179, 111608, 112023, 112450, 112868, 113289, 113710, 114131, 114570, 114985, 115412, 115835, 116245, 116664, 117086, 117505, 117926, 118345, 118768, 119195, 119615, 120043, 120457, 120887, 121295, 121707, 122126, 122536, 122964, 123378, 123809, 124233, 124646, 125069, 125488, 125908, 126331, 126759, 127181, 127601, 128009, 128432, 128848, 129261, 129677, 130087, 130509, 130925, 131357, 131789, 132209, 132639, 133049, 133469, 133879, 134290, 134718, 135138, 135574, 136002, 136438, 136876, 137297, 137724, 138167, 138597, 139039, 139463, 139904, 140342, 140768, 141214, 141647, 142073, 142490, 142909, 143338, 143751, 144182, 144607, 145046, 145487, 145932, 146369, 146805, 147239, 147673, 148092, 148515, 148936, 149368, 149809, 150241, 150689, 151118, 151558, 151990, 152421, 152861, 153290, 153724, 154167, 154596, 155021, 155450, 155870, 156302, 156713, 157144, 157562, 157992, 158428, 158848, 159280, 159701, 160133, 160558, 160987, 161414, 161825, 162249, 162667, 163096, 163519, 163940, 164359, 164773, 165186, 165610, 166030, 166459, 166892, 167324, 167753, 168179, 168615, 169027, 169447, 169865, 170276, 170704, 171127, 171558, 171972, 172410, 172831, 173241, 173663, 174084, 174520, 174948, 175388, 175823, 176239, 176660, 177070, 177488, 177899, 178313, 178739, 179159, 179592, 180016, 180447, 180873, 181316, 181747, 182189, 182630, 183077, 183520, 183963, 184406, 184829, 185266, 185694, 186133, 186556, 186989, 187414, 187831, 188255, 188680, 189089, 189507, 189916, 190327, 190739, 191147, 191575, 191984, 192409, 192835, 193246, 193675, 194096, 194525, 194941, 195373, 195802, 196209, 196636, 197059, 197494, 197917, 198358, 198781, 199216, 199646, 200076, 200507, 200939, 201373, 201804, 202228, 202659, 203086, 203507, 203931, 204350, 204760, 205186, 205602, 206016, 206426, 206847, 207265, 207686, 208103, 208539, 208961, 209393, 209838, 210269, 210708, 211127, 211557, 211989, 212425, 212868, 213294, 213735, 214169, 214615, 215049, 215488, 215918, 216337, 216764, 217191, 217615, 218046, 218476, 218904, 219332, 219762, 220195, 220613, 221040, 221463, 221882, 222309, 222734, 223174, 223585, 224027, 224446, 224865, 225296, 225725, 226161, 226583, 227018, 227461, 227880, 228308, 228735, 229162, 229587, 230019, 230450, 230891, 231304, 231724, 232119, 232522, 232912, 233305, 233707, 234104, 234519, 234918, 235340, 235766, 236188, 236618, 237039, 237471, 237888, 238323, 238747, 239172, 239597, 240019, 240448, 240859, 241288, 241698, 242122, 242538, 242975, 243403, 243835, 244275, 244692, 245129, 245563, 245990, 246417, 246840, 247280, 247695, 248130, 248555, 248985, 249407, 249838, 250269, 250691, 251113, 251546, 251973, 252408, 252833, 253271, 253690, 254116, 254536, 254952, 255382, 255794, 256212, 256623, 257028, 257430, 257819, 258197, 258566, 258927, 259285, 259590, 259962, 260304, 260636, 260959, 261271, 261836, 262179, 262515, 262863, 263206, 263551, 263909, 264272, 264640, 265016, 265401, 265800, 266213, 266626, 267064, 267496, 267930, 268352, 268786, 269203, 269633, 270060, 270478, 270894, 271286, 271689, 272055, 272433, 272813, 273178, 273560, 273936, 274330, 274743, 275158, 275592, 276024, 276466, 276897, 277345, 277775, 278223, 278662, 279107, 279540, 279984, 280419, 280859, 281298, 281738, 282180, 282615, 283061, 283492, 283935, 284371, 284801, 285237, 285663, 286095, 286503, 286924, 287333, 287742, 288150, 288558, 288986, 289393, 289820, 290239, 290675, 291092, 291522, 291945, 292375, 292817, 293244, 293683, 294104, 294546, 294967, 295410, 295841, 296281, 296712, 297137, 297570, 297983, 298410, 298841, 299257, 299685, 300104, 300534, 300957, 301380, 301809, 302219, 302638, 303050, 303468, 303886, 304300, 304718, 305135, 305556, 305977, 306395, 306816, 307232, 307649, 308054, 308472, 308885, 309316, 309745, 310177, 310612, 311033, 311465, 311890, 312320, 312760, 313190, 313622, 314037, 314475, 314898, 315325, 315758, 316170, 316606, 317034, 317468, 317899, 318320, 318749, 319150, 319576, 319976, 320396, 320805, 321233, 321658, 322072, 322498, 322930, 323358, 323789, 324203, 324630, 325044, 325466, 325902, 326313, 326736, 327153, 327577, 328008, 328437, 328856, 329286, 329724, 330136, 330564, 330982, 331404, 331826, 332235, 332666, 333076, 333501, 333914, 334335, 334761, 335175, 335607, 336027, 336445, 336867, 337276, 337698, 338112, 338538, 338959, 339387, 339822, 340253, 340687, 341118, 341554, 341988, 342424, 342868, 343288, 343722, 344144, 344575, 344997, 345415, 345836, 346247, 346667, 347105, 347516, 347950, 348367, 348798, 349220, 349638, 350060, 350469, 350902, 351316, 351744, 352166, 352593, 353019, 353432, 353858, 354276, 354698, 355124, 355548, 355977, 356389, 356819, 357239, 357658, 358082, 358502, 358929, 359356, 359787, 360218, 360638, 361080, 361490, 361911, 362321, 362747, 363173, 363593, 364024, 364416, 364791, 365165, 365537, 365907, 366271, 366641, 367023, 367412, 367819, 368251, 368695, 369143, 369605, 370040, 370481, 370920, 371382, 371820, 372268, 372704, 373150, 373588, 374032, 374478, 374903, 375342, 375757, 376182, 376595, 377007, 377425, 377824, 378261, 378683, 379111, 379557, 379977, 380414, 380844, 381290, 381742, 382168, 382617, 383066, 383507, 383964, 384390, 384826, 385262, 385708, 386151, 386600, 387048, 387489, 387929, 388370, 388803, 389235, 389665, 390100, 390521, 390955, 391383, 391815, 392235, 392657, 393090, 393500, 393919, 394340, 394769, 395189, 395626, 396054, 396475, 396899, 397314, 397732, 398156, 398575, 398994, 399403, 399828, 400260, 400692, 401142, 401568, 402008, 402432, 402874, 403307, 403750, 404196, 404628, 405071, 405494, 405933, 406345, 406779, 407206, 407620, 408047, 408466, 408889, 409309, 409738, 410171, 410586, 411025, 411456, 411887, 412313, 412735, 413165, 413585, 414002, 414425, 414831, 415264, 415683, 416117, 416545, 416981, 417425, 417847, 418290, 418715, 419142, 419572, 419993, 420427, 420842, 421280, 421702, 422143, 422574, 423005, 423432, 423856, 424281, 424695, 425118, 425550, 425971, 426396, 426814, 427242, 427660, 428071, 428493, 428913, 429327, 429762, 430173, 430598, 431010, 431442, 431870, 432288, 432730, 433152, 433591, 434016, 434458, 434891, 435321, 435759, 436175, 436608, 437028, 437463, 437884, 438303, 438730, 439142, 439562, 439992, 440410, 440833, 441244, 441672, 442085, 442502, 442935, 443347, 443777, 444203, 444638, 445058, 445490, 445923, 446355, 446804, 447233, 447675, 448096, 448531, 448967, 449391, 449826, 450240, 450675, 451100, 451537, 451976, 452406, 452841, 453269, 453701, 454137, 454563, 454988, 455422, 455863, 456286, 456722, 457150, 457580, 458013, 458428, 458854, 459274, 459699, 460136, 460548, 460979, 461394, 461809, 462229, 462634, 463063, 463482, 463907, 464347, 464769, 465200, 465622, 466047, 466467, 466898, 467328, 467746, 468170, 468599, 469023, 469452, 469872, 470295, 470704, 471126, 471551, 471965, 472389, 472803, 473214, 473623, 474041, 474469, 474878, 475311, 475721, 476149, 476569, 477004, 477439, 477857, 478281, 478694, 479119, 479540, 479957, 480378, 480797, 481217, 481639, 482050, 482482, 482907, 483335, 483775, 484196, 484620, 485038, 485469, 485891, 486330, 486764, 487196, 487630, 488046, 488482, 488891, 489321, 489741, 490163, 490591, 491011, 491437, 491850, 492278, 492698, 493108, 493531, 493940, 494369, 494786, 495226, 495658, 496077, 496507, 496924, 497352, 497777, 498198, 498629, 499050, 499479, 499908, 500330, 500762, 501176, 501591, 502011, 502429, 502854, 503261, 503694, 504112, 50452, 602449, 602858, 603288, 603698, 604116, 604536, 604946, 605367, 605765, 606191, 606607, 607012, 607434, 607851, 608274, 608699, 609113, 609541, 609953, 610371, 610804, 611221, 611648, 612066, 612486, 612906, 613319, 613745, 614160, 614578, 615005, 615410, 615835, 616253, 616677, 617106, 617528, 617951, 618360, 618777, 619199, 619621, 620059, 620482, 620922, 621345, 621774, 622205, 622615, 623034, 623460, 623880, 624310, 624719, 625148, 625558, 625978, 626400, 626806, 627227, 627642, 628071, 628499, 628921, 629352, 629761, 630191, 630612, 631043, 631470, 631898, 632332, 632748, 633179, 633601, 634023, 634442, 634863, 635285, 635700, 636122, 636553, 636963, 637395, 637807, 638224, 638642, 639060, 639485, 639896, 640318, 640730, 641135, 641548, 641955, 642378, 642784, 643209, 643633, 644036, 644452, 644863, 645282, 645698, 646110, 646526, 646936, 647346, 647765, 648173, 648594, 649016, 649443, 649871];
    threshold = 2; % Adjust as needed

    correct_count = 0;

    for i = 1:length(P_points)
        match_found = any(abs(P_points(i) - ground_truth) <= threshold);
        if match_found
            correct_count = correct_count + 1;
        end
    end
    
    % Calculate accuracy
    accuracy = (correct_count / length(P_points)) * 100;
    
    disp(['Accuracy: ' num2str(accuracy) '%']);