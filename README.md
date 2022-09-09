# Introduction

The code creates a health state transition dataset using the [RAND HRS Longitudinal File](https://www.rand.org/well-being/social-and-behavioral-policy/centers/aging/dataprod/hrs-data.html). The code can also be modifed for other datasets, e.g., Chinese Longitudinal Healthy Longevity Survey (CLHLS).

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
