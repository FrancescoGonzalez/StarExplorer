const starNames = [
  {"name": "HR 2491", "ra": 101.2885408, "dec": -16.71314278, "mag": -1.46},
  {"name": "HR 2326", "ra": 95.9882679, "dec": -52.6954889, "mag": -0.72},
  {"name": "HR 5459", "ra": 219.899707, "dec": -60.835274, "mag": -0.01},
  {"name": "HR 5340", "ra": 213.913315, "dec": 19.17824889, "mag": -0.04},
  {"name": "HR 7001", "ra": 279.2345833, "dec": 38.78444444, "mag": 0.03},
  {"name": "HR 1713", "ra": 78.634489, "dec": -8.2016413, "mag": 0.12},
  {"name": "HR 2943", "ra": 114.82523, "dec": 5.224955, "mag": 0.38},
  {"name": "HR 2061", "ra": 88.7927487, "dec": 7.4067993, "mag": 0.42},
  {"name": "HR 472", "ra": 24.4291176, "dec": -57.2368647, "mag": 0.46},
  {"name": "HR 5267", "ra": 210.955765, "dec": -60.372963, "mag": 0.61},
  {"name": "HR 7557", "ra": 297.6958333, "dec": 8.866388889, "mag": 0.77},
  {"name": "HR 4729", "ra": 186.6284609, "dec": -63.1222442, "mag": 0.77},
  {"name": "HR 1457", "ra": 68.980174, "dec": 16.509201, "mag": 0.85},
  {"name": "HR 6134", "ra": 247.3510417, "dec": -26.43219444, "mag": 0.96},
  {"name": "HR 1708", "ra": 79.17583333, "dec": 46.00027778, "mag": 0.98},
  {"name": "HR 5056", "ra": 201.2981247, "dec": -11.1613397, "mag": 1.04},
  {"name": "HR 2990", "ra": 116.328824, "dec": 28.026127, "mag": 1.14},
  {"name": "HR 8728", "ra": 344.412575, "dec": -29.622055, "mag": 1.16},
  {"name": "HR 7924", "ra": 310.3580352, "dec": 45.2803244, "mag": 1.25},
  {"name": "HR 3982", "ra": 152.092908, "dec": 11.967192, "mag": 1.35},
  {"name": "HR 2618", "ra": 104.6565503, "dec": -28.97205716, "mag": 1.5},
  {"name": "HR 6527", "ra": 263.4029167, "dec": -37.10111111, "mag": 1.62},
  {"name": "HR 4763", "ra": 187.791408, "dec": -57.113186, "mag": 1.63},
  {"name": "HR 1790", "ra": 81.2828309, "dec": 6.3497272, "mag": 1.64},
  {"name": "HR 1791", "ra": 81.572974, "dec": 28.607533, "mag": 1.65},
  {"name": "HR 1903", "ra": 84.0534571, "dec": -1.2018798, "mag": 1.69},
  {"name": "HR 5231", "ra": 208.884817, "dec": -47.2885563, "mag": 1.74},
  {"name": "HR 1948", "ra": 85.1896406, "dec": -1.9425855, "mag": 1.77},
  {"name": "HR 4301", "ra": 165.9313006, "dec": 61.7506487, "mag": 1.79},
  {"name": "HR 6879", "ra": 276.0428331, "dec": -34.38496, "mag": 1.79},
  {"name": "HR 2963", "ra": 114.9325544, "dec": -38.1392791, "mag": 1.83},
  {"name": "HR 5191", "ra": 206.8846738, "dec": 49.3131727, "mag": 1.85},
  {"name": "HR 2421", "ra": 99.4281784, "dec": 16.3993132, "mag": 1.93},
  {"name": "HR 2891", "ra": 113.6493422, "dec": 31.88821, "mag": 1.93},
  {"name": "HR 7790", "ra": 306.4119188, "dec": -56.7349814, "mag": 1.94},
  {"name": "HR 3485", "ra": 131.1760475, "dec": -54.7089895, "mag": 1.96},
  {"name": "HR 434", "ra": 22.54711, "dec": 6.14366, "mag": 1.97},
  {"name": "HR 3748", "ra": 141.8968741, "dec": -8.6584932, "mag": 1.98},
  {"name": "HR 681", "ra": 34.836625, "dec": -2.977055556, "mag": 2.0},
  {"name": "HR 7121", "ra": 283.8164892, "dec": -26.2969502, "mag": 2.02},
  {"name": "HR 74", "ra": 4.85687, "dec": -8.8241128, "mag": 2.04},
  {"name": "HR 2004", "ra": 86.9391287, "dec": -9.669587, "mag": 2.06},
  {"name": "HR 5563", "ra": 222.6763164, "dec": 74.155404, "mag": 2.06},
  {"name": "HR 5288", "ra": 211.670717, "dec": -36.369831, "mag": 2.06},
  {"name": "HR 358", "ra": 18.097149, "dec": -30.802156, "mag": 2.06},
  {"name": "HR 337", "ra": 17.43298634, "dec": 35.6201803, "mag": 2.07},
  {"name": "HR 617", "ra": 31.793286, "dec": 23.462421, "mag": 2.07},
  {"name": "HR 6556", "ra": 263.733621, "dec": 12.560045, "mag": 2.08},
  {"name": "HR 936", "ra": 47.0423174, "dec": 40.9557378, "mag": 2.1},
  {"name": "HR 603", "ra": 30.97616792, "dec": 42.32860083, "mag": 2.1},
  {"name": "HR 4534", "ra": 177.2649611, "dec": 14.57401611, "mag": 2.14},
  {"name": "HR 168", "ra": 10.1270667, "dec": 56.5372604, "mag": 2.15},
  {"name": "HR 3699", "ra": 139.2724102, "dec": -59.2751584, "mag": 2.21},
  {"name": "HR 3207", "ra": 122.383156, "dec": -47.3364749, "mag": 2.21},
  {"name": "HR 1852", "ra": 83.0015924, "dec": -0.2990519, "mag": 2.23},
  {"name": "HR 7796", "ra": 305.5570781, "dec": 40.2566484, "mag": 2.23},
  {"name": "HR 6705", "ra": 269.1515267, "dec": 51.488853, "mag": 2.24},
  {"name": "HR 4860", "ra": 192.109483, "dec": -27.597332, "mag": 2.27},
  {"name": "HR 21", "ra": 2.292041667, "dec": 59.15022222, "mag": 2.28},
  {"name": "HR 5953", "ra": 240.0833287, "dec": -22.6217404, "mag": 2.29},
  {"name": "HR 264", "ra": 14.1774648, "dec": 60.7167671, "mag": 2.47},
  {"name": "HR 99", "ra": 6.570812, "dec": -42.306011, "mag": 2.37},
  {"name": "HR 8308", "ra": 326.0464692, "dec": 9.8749204, "mag": 2.38},
  {"name": "HR 8775", "ra": 345.943512, "dec": 28.082781, "mag": 2.42},
  {"name": "HR 6378", "ra": 257.5946036, "dec": -15.724686, "mag": 2.43},
  {"name": "HR 8781", "ra": 346.1905355, "dec": 15.2051578, "mag": 2.49},
  {"name": "HR 7949", "ra": 311.552782, "dec": 33.97023, "mag": 2.59},
  {"name": "HR 7194", "ra": 285.6528305, "dec": -29.8802034, "mag": 2.6},
  {"name": "HR 5685", "ra": 229.2514346, "dec": -9.3829691, "mag": 2.61},
  {"name": "HR 403", "ra": 21.453736, "dec": 60.235291, "mag": 2.68},
  {"name": "HR 5531", "ra": 222.719767, "dec": -16.041737, "mag": 2.75},
  {"name": "HR 1666", "ra": 76.9625, "dec": -5.086369, "mag": 2.78},
  {"name": "HR 1829", "ra": 82.0613012, "dec": -20.7596275, "mag": 2.84},
  {"name": "HR 4915", "ra": 194.0076708, "dec": 38.31824583, "mag": 2.89},
  {"name": "HR 7417", "ra": 292.6803433, "dec": 27.9596501, "mag": 2.9},
  {"name": "HR 8232", "ra": 322.8897325, "dec": -5.571194, "mag": 2.9},
  {"name": "HR 4757", "ra": 187.466165, "dec": -16.515339, "mag": 2.94},
  {"name": "HR 8414", "ra": 331.4459664, "dec": -0.3198756, "mag": 2.95},
  {"name": "HR 2282", "ra": 95.0783559, "dec": -30.0633324, "mag": 3.0},
  {"name": "HR 7776", "ra": 305.2528909, "dec": -14.781453, "mag": 3.05},
  {"name": "HR 8974", "ra": 354.836826, "dec": 77.632324, "mag": 3.28},
  {"name": "HR 542", "ra": 28.5990438, "dec": 63.6700828, "mag": 3.38},
  {"name": "HR 1136", "ra": 55.812095, "dec": -9.763629, "mag": 3.54},
  {"name": "HR 5291", "ra": 211.09775, "dec": 64.37583333, "mag": 3.65},
  {"name": "HR 8278", "ra": 325.022701, "dec": -16.662312, "mag": 3.69},
  {"name": "HR 1231", "ra": 59.50792028, "dec": -13.50822208, "mag": 3.75},
  {"name": "HR 5062", "ra": 201.3069505, "dec": 54.9879047, "mag": 4.01},
  {"name": "HR 4785", "ra": 188.435594, "dec": 41.357502, "mag": 4.26},
  {"name": "HR 1298", "ra": 62.9666707, "dec": -6.8373057, "mag": 4.29},
  {"name": "HR 226", "ra": 12.4535677, "dec": 41.0788567, "mag": 4.53},
  {"name": "HR 1180", "ra": 57.2968536, "dec": 24.1366292, "mag": 5.05},
  {"name": "HR 1899", "ra": 83.858392, "dec": -5.9099947, "mag": 2.77},
  {"name": "HR 1901", "ra": 83.9145784, "dec": -4.8560495, "mag": 5.31}
];