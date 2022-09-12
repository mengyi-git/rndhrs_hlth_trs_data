# Introduction

The code creates a health state transition dataset using the [RAND HRS Longitudinal File](https://www.rand.org/well-being/social-and-behavioral-policy/centers/aging/dataprod/hrs-data.html). The code can also be modifed for other datasets, e.g., Chinese Longitudinal Healthy Longevity Survey (CLHLS). 

Below is an excerpt of the output.

|WAVE|WAVE2|RxYEAR|RxYEAR2|RxHSTATE|RxHSTATE2|RxAGE      |RxAGE2     |
|----|-----|------|-------|--------|---------|-----------|-----------|
|4   |5    |1998  |2000   |1       |1        |63.6659822 |65.41546886|
|5   |6    |2000  |2001   |1       |4        |65.41546886|67.1266256 |
|4   |5    |1998  |2000   |1       |1        |59.58110883|61.49760438|
|5   |6    |2000  |2002   |1       |1        |61.49760438|63.58110883|
|6   |7    |2002  |2004   |1       |1        |63.58110883|65.83162218|
|7   |8    |2004  |2006   |1       |1        |65.83162218|67.49623546|
|8   |9    |2006  |2008   |1       |1        |67.49623546|69.41820671|
|9   |10   |2008  |2010   |1       |2        |69.41820671|72         |
|10  |11   |2010  |2012   |2       |1        |72         |73.83162218|
|11  |12   |2012  |2014   |1       |2        |73.83162218|75.66324435|
|12  |13   |2014  |2015   |2       |4        |75.66324435|77.12525667|


# How to use the code

Download the RAND HRS Longitudinal File from [https://hrsdata.isr.umich.edu/data-products/rand](https://hrsdata.isr.umich.edu/data-products/rand). Select `SAS dataset` if you want to run the SAS code.

![image](https://user-images.githubusercontent.com/40621074/189437728-e736e3bb-3c8a-4ef9-b4aa-ac289ca2c544.png)

Open `main.sas` and change the following SAS macro variables.
- `DIR` is your home directory. `VERSION` and `PROJECT` are two folders in the home directory.
  - RAND HRS Longitudinal File is saved in the folder `DIR\VERSION`.
  - The SAS code, including the `sas_macro` folder, is saved in the folder `DIR\PROJECT`.
    - Since multiple projects can use the same dataset, I separate the project folder from the one that saves the downloaded RAND HRS Longitudinal File.
- `FD_STATE` represents the functional disabled state and `DEAD_STATE` represents the dead state.
  - The code defines the health state based on activities of daily living. You can re-define the health states.

Create a `data` folder in `DIR\PROJECT`. The intermediate datasets are saved in the `data` folder.

Open `codeRaVars.sas` and modify the list of time-independent variables you want to keep.

Open `codeRxSufxlst.sas` and modify the list of time-dependent variables you want to keep.

Run `main.sas`.

## SAS macro functions

The SAS macro functions in the folder `sas_macro` are created based on various sources. More details can be found at [https://github.com/mengyi-git/sas_macro](https://github.com/mengyi-git/sas_macro).

# Questions and comments
If you have trouble running the code or have better ideas to improve the code, please [log an issue](https://github.com/mengyi-git/rndhrs_hlth_trs_data/issues).
