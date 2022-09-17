## Introduction on FC(C)S/FLIM
[PicoQuant knowledgebase](https://www.picoquant.com/scientific/technical-and-application-notes/category/technical_notes_techniques_and_methods/P8)

[Malacrida et al., 2021](https://www.annualreviews.org/doi/10.1146/annurev-biophys-062920-063631) on the phasor plot

## Prerequisite
This toolkit requires another repository of mine, [readHeader](https://github.com/CreLox/readHeader), to run.

## General workflow
(Note: steps 1-3 are only needed to be done once per experiment.)

1. Open MATLAB. In the Command Window, call the `calculateIRF` function and pick the .fcs file containing the IRF measurement in the pop-up UI. The normalized IRF is then automatically saved into a .mat file with the same filename as the original .fcs input file. Load it to continue later steps.

```MATLAB
>> calculateIRF('Early'); % For the green channel, specify the early pulse.
```

2. Visually examine the IRF curve. Optional: if you see a major prepulse before the main IRF spike, remove it manually by assigning those `IRFProb` values belonging to the prepulse to 0. The reason is explained in [a section below](https://github.com/CreLox/FluorescenceLifetime/blob/master/README.md#prepulse-and-afterpulse-in-the-measured-irf). However, if you do this, make sure to renormalize the `IRFProb`.

```MATLAB
>> plot(25/4096:50/4096:25-25/4096, IRFProb, '.-'); % A ClockFrequency of 20 MHz and an ADCResolution of 4096 were used
   ...
>> % IRFProb = IRFProb / sum(IRFProb); % Normalization again
```

3. Calculate `IRFTransform`. For more details, see [another section below](https://github.com/CreLox/FluorescenceLifetime/blob/master/README.md#phasor-transform-and-autofluorescence-filtering). Save `IRFProb`, `Omega`, and `IRFTransform` into a single .mat file.

```MATLAB
>> Omega = calculateBestOmega(2, 3); % ~ 0.4082, which optimally resolves fluorescence lifetimes in the 2-3 ns range; do not use other values because the empirical standards (hard-coded in the third step of the workflow routine; see below) to identify autofluorescent pixels depend on it.
>> IRFTransform = calculateIRFTransform(IRFProb, 25/4096:50/4096:25-25/4096, Omega); % A ClockFrequency of 20 MHz and an ADCResolution of 4096 were used
```

4.  Load the .mat file containing `IRFProb`, `Omega`, and `IRFTransform` in the third step of the [workflow routine](https://github.com/CreLox/FluorescenceLifetime/blob/master/Workflows/PhasorIntensityFiltersFLIMFitting.m). This workflow routine lays out all the steps in a typical data analysis: intensity thresholding (for localized fluorophores), [phasor plot-based pixel filtering](https://github.com/CreLox/FluorescenceLifetime/blob/master/README.md#phasor-transform-and-autofluorescence-filtering), region exclusion (manual correction), and fitting. Use `Run Section` to perform your analysis in a guided, step-by-step manner.

## Principles

To demonstrate how fluorescence lifetime measurements can quantify the FRET efficiency, consider a large number of donor fluorophore molecules with a lifetime of $τ_0$. In the absence of acceptor fluorophores, the exponential decay $D_0$ of donor fluorescence after pulsed excitation at time zero is

$$D_0(t) = Ce^{-t/τ_0}.$$

The total donor fluorescence signal (which can be measured through FLIM) is

$$S_0=\int_0^{+\infty} D_0(t)dt = Cτ_0,$$

wherein the pre-exponential factor $C$ is a constant determined by the total number and properties of fluorophores, as well as the imaging setup. Without altering any of these conditions, in the presence of acceptor fluorophores and FRET, the possibility that an excited fluorophore stays excited (has not relaxed to the ground state either through the fluorescence-emitting route or the FRET-quenching route) at time $t$ is

$$P=e^{-(1/τ_0 +1/τ')t},$$

wherein $τ'$ ( $=(r/R_0)^6τ_0$; see the derivation of equation 15.2.27 [here](https://chem.libretexts.org/Bookshelves/Physical_and_Theoretical_Chemistry_Textbook_Maps/Time_Dependent_Quantum_Mechanics_and_Spectroscopy_(Tokmakoff)/15%3A_Energy_and_Charge_Transfer/15.02%3A_Forster_Resonance_Energy_Transfer_(FRET))) is the time parameter of FRET (note: although an excited fluorophore can only relax through one route, the two stochastic processes – fluorescence-emitting and FRET-quenching – are independent). Therefore, in the presence of acceptor fluorophores and FRET, the new decay dynamics $D$ of donor fluorescence becomes

$$D(t)=Ce^{-(1/τ_0 +1/τ')t}=Ce^{-(τ_0+τ')t/(τ_0 τ')},$$

The **effective lifetime** of the donor fluorophore (which can be measured through FLIM) becomes

$$τ=\frac{τ_0 τ'}{τ_0+τ'},$$

and the total donor fluorescence signal becomes $S = Cτ$. Therefore, the FRET efficiency

$$\frac{S_0-S}{S_0}=\frac{τ_0-τ}{τ_0}(=\frac{1}{(r/R_0)^6+1}),$$

wherein $τ_0$ and $τ$ can be measured through FLIM. Because the fluorescence lifetime in the absence of quenching is an intrinsic property of a mature fluorescent protein under a certain temperature (see [section 9.4.5.1, Kafle, 2020](https://www.sciencedirect.com/science/article/pii/B9780128148662000099)), the equation above greatly simplifies the FRET efficiency measurement. This equation still applies even if the fluorescence decay must be fitted by a multi-component exponential decay, as long as the fluorescence lifetime is an average value weighted by the corresponding $C$ of each component (see [a section below](https://github.com/CreLox/FluorescenceLifetime/blob/master/README.md#a-note-on-the-multi-component-exponential-fit)).

## Phasor transform and autofluorescence filtering
The phasor transform is a normalized Fourier transform that converts time-resolved emission data into a single point in the complex plane. For a donor fluorophore with an exponential decay $D(t) = Ce^{-t/τ}$ after pulsed excitation at time zero and any positive $\omega$ with a dimension of $s^{-1}$, the phasor transform of $D(t)$ is defined as

$$\mathcal{P}(\omega, D) = (\int_0^{+\infty} e^{i \omega t}D(t)dt)/(\int_0^{+\infty} D(t)dt) = \frac{1}{1+\omega^2\tau^2} + \frac{\omega\tau}{1+\omega^2\tau^2}i.$$

On the complex plane, the corresponding phasor $\frac{1}{1+\omega^2\tau^2} + \frac{\omega\tau}{1+\omega^2\tau^2}i$ is distributed on the **universal semicircle**

$$|z-1/2| = 1/2, \operatorname{Im}(z)>0.$$

For an ensemble of fluorophores with different exponential decay lifetimes, it is easy to derive that the phasor is a linear combination of the phasors of the composing species $\mathcal{P}(\omega, D_m), m = 1, 2, ..., M$, weighted by their corresponding **fractional intensity**:

$$\mathcal{P}(\omega, \sum_{m=0}^{M} D_m) = \sum_{m=0}^{M} (\mathcal{P}(\omega, D_m) \cdot C_m\tau_m / \sum_{l=0}^{M} C_l\tau_l ).$$

Since the fractional intensity $\in (0, 1]$, the phasor of the ensemble is always within the convex hull defined by the phasor(s) of all composing species and is therefore on or within the semicircle. The simplest case wherein the ensemble contains two species with various lifetimes is illustrated below.

<p align="center">
  <img width="540" alt="image" src="https://user-images.githubusercontent.com/18239347/190550027-80257b25-4a5b-4318-9dbe-8da367782316.png">
</p>

The actual FLIM signal $R(t) =$ the normalized instrument response function (IRF) $I(t) \circledast$ the (multi-component) exponential decay $D(t)$ (+ noise). If we ignore the noise, the phasor transform of the raw time-resolved emission data $R(t)$ is then

$$\mathcal{P}(\omega, R) = (\int_0^{+\infty} e^{i \omega t}R(t)dt)/(\int_0^{+\infty} R(t)dt),$$

wherein the denominator

$$\begin{align}\int_0^{+\infty} R(t)dt &= \int_{t=0}^{+\infty} (\int_{T=0}^{t} I(T)D(t-T)dT)dt = \int_{T=0}^{+\infty} I(T)(\int_{t=T}^{+\infty} D(t-T)dt)dT \newline &= \int_{T=0}^{+\infty} I(T)dT\cdot\int_{t=0}^{+\infty} D(t)dt = \int_{t=0}^{+\infty} D(t)dt\end{align}$$

and the numerator

$$\int_0^{+\infty} e^{i \omega t}R(t)dt = \int_0^{+\infty} e^{i \omega t}(I(t) \circledast D(t))dt = \int_0^{+\infty} e^{i \omega t}I(t)dt \cdot \int_0^{+\infty} e^{i \omega t}D(t)dt.$$

Therefore,

$$\mathcal{P}(\omega, D) = \mathcal{P}(\omega, R) / (\int_0^{+\infty} e^{i \omega t}I(t)dt).$$

The `calculateIRFTransform` [function](https://github.com/CreLox/FluorescenceLifetime/blob/master/calculateIRFTransform.m) calculates $\int_0^{+\infty} e^{i \omega t}I(t)dt$. For the actual discrete time-resolved emission data, suppose that the arrival micro-time (after pulsed excitation at time zero) of a series of emission photons $n, n = 1, 2, ..., N$, is $t_n$. The phasor transform of the series is then
$$\mathcal{P}(\omega) = \sum_{n=0}^{N} e^{i \omega t_n}/N.$$

A critical application of the phasor plot in the workflow is to identify pixels with mostly autofluorescence, without performing tedious fitting pixel by pixel. Autofluorescent substances in mammalian organelles typically feature shorter lifetimes than fluorescent proteins chosen for the FLIM experiment do. Reflected on the phasor plot, the phasor transforms of time-resolved emission data registered to pixels with mostly autofluorescence are well separated from those registered to pixels with mostly fluorescent proteins.

## A note on the multi-component exponential fit

> ... Without careful consideration of the nature of the problem, deconvolution as an information-improving device can easily become an exercise in self-delusion. — [Knight and Selinger (1971)](https://www.sciencedirect.com/science/article/pii/0584853971800739)

The multi-component exponential fit is intrinsically flexible. Regarding this, [Grinvald and Steinberg (1974)](https://www.sciencedirect.com/science/article/pii/0003269774903121) raised two educational examples which are reproduced here:

<p align="center">
  <img width="810" alt="image" src="https://user-images.githubusercontent.com/18239347/184480647-87a58ad1-fc0d-4daf-a830-a7bf177ed668.png">
</p>

However, the average lifetime of a **good** multi-component exponential fit weighted by the corresponding $C$ of each component (see the section above) should be conserved, regardless of the actual fitting parameters (because both $S$, the area underneath the curve, and $D(0)$, the intersection point at $t = 0$, should be close for all **good** fits):

$$\bar{\tau} = \frac{\sum C_i \tau_i}{\sum C_i} = \frac{S}{D(0)}.$$

## Prepulse and afterpulse in the measured IRF
Our current protocol uses a mirror on the sample plane to measure the IRF. The emission filter is removed and internal reflection at lenses is observed as a prepulse in the measured IRF. This prepulse is an artifact due to the removal of the emission filter and should be manually removed in postprocessing. Additionally, the avalanche photodiode (APD) detector has an afterpulse feature (see, for example, [Ziarkash et al., 2018](https://www.nature.com/articles/s41598-018-23398-z)). This is intrinsic to the detector and an integral part of the IRF that should NOT be removed in postprocessing.

## Normalization of event counts
Alba is a laser scanning microscopy setup. The amplification factor is determined by the setup and the objective but not by the scale of the FOV set for scanning. Therefore, the power of the excitation light on the sample plane and the corresponding area on the sample plane of the APD detector are not affected by the FOV set for scanning. Because the pixel dwell time is fixed, the event count per **pixel** is directly comparable, regardless of the scale of the FOV set for scanning.

## Acknowledgments
I would like to thank Dr. J. Damon Hoff (from the SMART Center at the Univerisity of Michigan, Ann Arbor) for his suggestions on the manual and his ground-laying contributions to scripts related to the I/O of data files.
