% Load images and scale them down by 50

HE_imgs = dir('./Assignment-2-Data/Collection 1/HE/*.bmp');   
p63AMACR_imgs = dir('./Assignment-2-Data/Collection 1/p63AMACR/*.bmp');

for i=1:length(HE_imgs)
   HE_images{i} = imresize(imread(fullfile(HE_imgs(i).folder, HE_imgs(i).name)), 0.5);
   p63AMACR_images{i} = imresize(imread(fullfile(p63AMACR_imgs(i).folder, p63AMACR_imgs(i).name)), 0.5);
end
%%

%i = 29;
%subplot(1,2,1)
%imshow(rgb2gray(HE_images{i}))
%subplot(1,2,2)
%imshow(rgb2gray(p63AMACR_images{i}))


im=1
p1x=[286, 225]; p1y=[292, 211]
p2x=[346, 396];p2y=[360,382]
p3x=[497, 299];p3y=[510, 273]
p4x=[239, 427];p4y=[258, 418]
p5x=[61, 299];p5y=[73, 309]

manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';
%%

im=2
p1x=[257, 140];p1y=[253, 139]
p2x=[472, 213];p2y=[479, 188]
p3x=[318,462];p3y=[354, 457]
p4x=[294, 54];p4y=[283, 47]
p5x=[413,315];p5y=[427, 301]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=3
p1x=[432, 272];p1y=[433, 240]
p2x=[389, 376];p2y=[397, 356]
p3x=[211, 305];p3y=[213, 301]
p4x=[315, 94];p4y=[299,69]
p5x=[131, 453];p5y=[152, 460]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=4
p1x=[334, 161];p1y=[226, 154]
p2x=[232, 308];p2y=[238, 298]
p3x=[149, 391];p3y=[170, 399]
p4x=[330, 443];p4y=[354, 430]
p5x=[205, 100];p5y=[182, 102]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=5
p1x=[219, 346];p1y=[233, 351]
p2x=[170, 390];p2y=[188, 407]
p3x=[282, 124];p3y=[277, 125]
p4x=[285, 43];p4y=[266,43]
p5x=[521, 208];p5y=[525, 232]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=6
p1x=[132,366];p1y=[147, 369]
p2x=[367, 261];p2y=[363, 244]
p3x=[147, 310];p3y=[160, 315]
p4x=[122, 187];p4y=[119, 193]
p5x=[267, 32];p5y=[238, 28]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=7
p1x=[300, 315];p1y=[302, 300]
p2x=[479, 366];p2y=[480, 356]
p3x=[494, 266];p3y=[480, 206]
p4x=[71, 190];p4y=[55, 191]
p5x=[351, 65];p5y=[325, 54]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=8
p1x=[89, 98];p1y=[121, 122]
p2x=[48, 399];p2y=[109, 415]
p3x=[346, 141];p3y=[381, 132]
p4x=[467, 300];p4y=[413, 317]
p5x=[476, 333];p5y=[534, 328]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=9
p1x=[160, 118];p1y=[154, 132]
p2x=[499, 185];p2y=[513, 173]
p3x=[392, 348];p3y=[409, 341]
p4x=[191, 481];p4y=[210, 496]
p5x=[481, 264];p5y=[493, 262]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=10
p1x=[71, 233];p1y=[76, 256]
p2x=[344, 389];p2y=[389, 400]
p3x=[275, 481];p3y=[294, 494]
p4x=[242, 62];p4y=[254, 69]
p5x=[410, 399];p5y=[422, 405]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=11
p1x=[127, 284];p1y=[144, 295]
p2x=[413, 328];p2y=[432, 333]
p3x=[481, 233];p3y=[490, 227]
p4x=[270, 442];p4y=[297, 453]
p5x=[132, 412];p5y=[134, 435]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=12
p1x=[229, 488];p1y=[233, 499]
p2x=[410, 473];p2y=[406, 476]
p3x=[106, 353];p3y=[111, 374]
p4x=[379, 116];p4y=[348, 112]
p5x=[535, 136];p5y=[508, 125]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=13
p1x=[425, 164];p1y=[429, 173]
p2x=[451, 356];p2y=[462, 364]
p3x=[114, 175];p3y=[126, 211]
p4x=[231, 455];p4y=[254, 478]
p5x=[420, 75];p5y=[424, 97]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=14
p1x=[382, 463];p1y=[358, 425]
p2x=[196, 473];p2y=[205, 491]
p3x=[318, 95];p3y=[305, 107]
p4x=[372, 537];p4y=[381, 524]
p5x=[331, 113];p5y=[315, 120]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=15
p1x=[191, 289];p1y=[192, 305]
p2x=[244, 493];p2y=[253, 498]
p3x=[390, 113];p3y=[383, 135]
p4x=[50, 292];p4y=[47, 316]
p5x=[420, 470];p5y=[423, 481]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=16
p1x=[191, 146];p1y=[200, 153]
p2x=[152, 203];p2y=[167, 199]
p3x=[231, 493];p3y=[269, 496]
p4x=[520, 312];p4y=[550, 298]
p5x=[484, 373];p5y=[517, 364]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=17
p1x=[157, 159];p1y=[162, 186]
p2x=[78, 149];p2y=[83, 176]
p3x=[507, 353];p3y=[522, 359]
p4x=[208, 116];p4y=[210, 135]
p5x=[525, 203];p5y=[525, 232]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=18
p1x=[30, 256];p1y=[27, 275]
p2x=[231, 14];p2y=[230, 29]
p3x=[548, 251];p3y=[568, 224]
p4x=[96, 427];p4y=[91, 455]
p5x=[258, 261];p5y=[267, 277]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=19
p1x=[157, 384];p1y=[202, 397]
p2x=[277, 233];p2y=[307, 232]
p3x=[400, 130];p3y=[436, 305]
p4x=[323, 470];p4y=[368, 473]
p5x=[73, 396];p5y=[114, 412]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=20
p1x=[318, 269];p1y=[312, 290]
p2x=[397, 50];p2y=[403, 59]
p3x=[341, 493];p3y=[342, 521]
p4x=[104, 243];p4y=[88, 277]
p5x=[509, 363];p5y=[507, 366]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=21
p1x=[522, 185];p1y=[528, 173]
p2x=[395, 205];p2y=[403, 199]
p3x=[216, 427];p3y=[228, 443]
p4x=[535, 256];p4y=[550, 239]
p5x=[155, 103];p5y=[152, 117]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=22
p1x=[339, 251];p1y=[307, 244]
p2x=[231, 291];p2y=[213, 397]
p3x=[160, 284];p3y=[129, 290]
p4x=[320, 386];p4y=[408, 374]
p5x=[231, 463];p5y=[223, 468]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=23
p1x=[293, 266];p1y=[329, 289]
p2x=[270, 303];p2y=[313, 332]
p3x=[245, 324];p3y=[294, 361]
p4x=[186, 322];p4y=[236, 367]
p5x=[163, 317];p5y=[212, 372]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=24
p1x=[342, 349];p1y=[317, 359]
p2x=[276, 293];p2y=[258, 310]
p3x=[249, 216];p3y=[230, 234]
p4x=[241, 141];p4y=[209, 157]
p5x=[416, 208];p5y=[394, 218]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=25
p1x=[302, 26];p1y=[281, 28]
p2x=[374, 385];p2y=[376, 382]
p3x=[483, 287];p3y=[481, 374]
p4x=[475, 191];p4y=[465, 177]
p5x=[113, 406];p5y=[120, 431]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=26
p1x=[503, 142];p1y=[522, 174]
p2x=[98, 91];p2y=[104, 149]
p3x=[156, 339];p3y=[168, 400]
p4x=[443, 299];p4y=[455, 343]
p5x=[301, 372];p5y=[319, 428]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=27
p1x=[415, 101];p1y=[401, 118]
p2x=[465, 223];p2y=[465, 231]
p3x=[420, 402];p3y=[425, 420]
p4x=[311, 433];p4y=[327, 440]
p5x=[47, 296];p5y=[43, 331]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=28
p1x=[364, 43];p1y=[350, 33]
p2x=[476, 117];p2y=[476, 105]
p3x=[268, 269];p3y=[286, 269]
p4x=[346, 421];p4y=[368, 431]
p5x=[68, 269];p5y=[79, 292]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';

im=29
p1x=[60, 217];p1y=[43, 242]
p2x=[145, 525];p2y=[132, 542]
p3x=[58, 331];p3y=[53, 360]
p4x=[446, 74];p4y=[445, 70]
p5x=[501, 97];p5y=[463, 101]
manual_points_x{im} = [p1x; p2x; p3x; p4x; p5x]';
manual_points_y{im} = [p1y; p2y; p3y; p4y; p5y]';
